class AddOvertimeApplovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_apploval, :integer, default: 1
  end
end
