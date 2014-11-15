class CreateGigs < ActiveRecord::Migration
  def change
    create_table :gigs do |t|
      t.decimal :pay, precision: 8, scale: 2
      t.text :description
      t.text :location
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
