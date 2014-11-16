class AddUserReferenceToGigs < ActiveRecord::Migration
  def change
    add_reference :gigs, :user, index: true
  end
end
