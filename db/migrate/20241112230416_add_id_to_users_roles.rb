class AddIdToUsersRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :users_roles, :id, :primary_key
  end
end