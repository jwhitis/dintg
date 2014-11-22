class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :calendar_id
      t.decimal :monthly_goal, precision: 8, scale: 2
      t.boolean :exclude_unpaid, null: false, default: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
