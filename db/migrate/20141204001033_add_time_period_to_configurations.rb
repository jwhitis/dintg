class AddTimePeriodToConfigurations < ActiveRecord::Migration
  def change
    add_column :configurations, :time_period, :string, null: false, default: "month"
  end
end
