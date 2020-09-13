class AddOvertimeSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_superior_id, :integer
  end
end
