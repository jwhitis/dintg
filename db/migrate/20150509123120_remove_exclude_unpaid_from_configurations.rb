class RemoveExcludeUnpaidFromConfigurations < ActiveRecord::Migration
  def change
    remove_column :configurations, :exclude_unpaid, :boolean, default: false, null: false
  end
end
