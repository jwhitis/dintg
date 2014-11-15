class AddUserReferenceToTokens < ActiveRecord::Migration
  def change
    add_reference :tokens, :user, index: true
  end
end
