class AddOrganizationToOauthApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_applications, :organization_id, :bigint
    add_column :oauth_applications, :sub_organization_id, :bigint
    add_column :oauth_applications, :organization_name, :string
    add_column :oauth_applications, :sub_organization_name, :string
    add_column :oauth_applications, :app_type, :string, default: 'reader'
    
    add_index :oauth_applications, :organization_id
    add_index :oauth_applications, :sub_organization_id
    add_index :oauth_applications, :app_type
  end
end
