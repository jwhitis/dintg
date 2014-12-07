class AddGoogleIdToGigs < ActiveRecord::Migration
  def change
    add_column :gigs, :google_id, :string, null: false, default: ""
  end
end
