class AddOvertimeSuperiorNameToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_superior_name, :string
  end
end
