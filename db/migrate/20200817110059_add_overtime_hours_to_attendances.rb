class AddOvertimeHoursToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_hours, :string
  end
end
