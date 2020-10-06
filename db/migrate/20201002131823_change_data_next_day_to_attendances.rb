class ChangeDataNextDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    change_column :attendances, :next_day, :string, default: "0"
  end
end
