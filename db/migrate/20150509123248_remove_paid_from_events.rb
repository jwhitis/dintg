class RemovePaidFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :paid, :boolean, default: false, null: false
  end
end
