class RemoveConfigurationColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :calendar_id, :string
    remove_column :users, :monthly_goal, :decimal, precision: 8, scale: 2
  end
end
