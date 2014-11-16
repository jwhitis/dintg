class RemovePasswordColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :encrypted_password, :string, null: false, default: ""
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
  end
end
