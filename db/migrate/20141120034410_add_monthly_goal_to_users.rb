class AddMonthlyGoalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :monthly_goal, :decimal, precision: 8, scale: 2
  end
end
