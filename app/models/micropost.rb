class Micropost < ApplicationRecord
  belongs_to :user
  default_scope ->{order created_at: :desc} # newest to oldest
  mount_uploader :picture, PictureUploader
  # tell CarrierWave to associate image with model, ues attribute and class name
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size # to call a custom validation

  private

  # Validates the size of an uploaded picture.
  def picture_size
    return if picture.size <= 5.megabytes
    errors.add(:picture, t("model.micropost.picture_size.error"))
  end
end
