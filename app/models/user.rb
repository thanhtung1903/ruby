class User < ApplicationRecord
  # dependent microposts to be destroyed when the user itself is destroyed
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
    foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
    foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true
  def self.digest string
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create string, cost: cost
  end

  def self.new_token #  create a token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    # save digest of token into DB bypass validates
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attributes remember_digest: nil
  end

  # Activates an account.
  def activate
    update_attributes activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def self.select_user_activated
    User.where activated: true
  end

  # Sets the reset_token and update reset_digest attributes into DB
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    # default following_ids return a array followed user'id = user.following.map(&:id)
    # but it's bad with 5000 followed user because user.following is a array and
    # map with get each element of array. so use sql command to faster. but id
    # not avalible in eveytime so need to pass into following_ids + user_id in
    # where command also need to pass in, so use :user_id for both
    following_ids = "SELECT followed_id FROM relationships
      WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id",
      user_id: id) # self.id
  end

  def follow other_user
    following << other_user # add element into array
  end

  # Unfollows a user.
  def unfollow other_user
    following.delete other_user # delete element out of array
  end

  # Returns true if the current user is following the other user.
  def following? other_user
    following.include? other_user # check array are there include other_user?
  end

  def followers? other_user
    followers.include? other_user # check array are there include other_user?
  end

  private

  # Converts email to all lower-case - standard for email in DB
  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest # called by before_create so auto save into DB
    self.activation_token  = User.new_token # vitrual abttribute
    self.activation_digest = User.digest activation_token # abttribute in DB
  end
end
