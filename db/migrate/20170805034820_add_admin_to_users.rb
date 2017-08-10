class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    # the boolean nature of the admin attribute and automatically adds admin?
    add_column :users, :admin, :boolean,default: false
  end
end
