class AddOvertimeCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_check, :string, default: "1"
  end
end
