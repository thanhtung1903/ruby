class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    # mean is add  feature and rule into email help search faster + unique: true
    add_index :users, :email, unique: true
  end
end
