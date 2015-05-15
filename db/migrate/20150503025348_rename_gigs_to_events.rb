class RenameGigsToEvents < ActiveRecord::Migration
  def change
    rename_table :gigs, :events
  end
end
