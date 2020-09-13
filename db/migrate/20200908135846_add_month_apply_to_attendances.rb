class AddMonthApplyToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_apply, :datetime
    add_column :attendances, :month_approval, :integer, default: 1
    add_column :attendances, :month_check, :string, default: "0"
  end
end
