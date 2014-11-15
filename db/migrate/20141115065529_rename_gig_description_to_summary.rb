class RenameGigDescriptionToSummary < ActiveRecord::Migration
  def change
    rename_column :gigs, :description, :summary
  end
end
