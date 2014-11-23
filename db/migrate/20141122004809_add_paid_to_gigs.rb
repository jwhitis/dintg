class AddPaidToGigs < ActiveRecord::Migration
  def change
    add_column :gigs, :paid, :boolean, null: false, default: false
  end
end
