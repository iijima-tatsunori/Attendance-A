class AddApplovalConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :apploval_confirmation, :string
  end
end
