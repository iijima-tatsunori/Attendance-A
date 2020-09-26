class AddChangedStartedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :changed_started_at, :datetime
    add_column :attendances, :changed_finished_at, :datetime
    add_column :attendances, :change_next_day, :string, default: "0"
    add_column :attendances, :change_superior_id, :integer
    add_column :attendances, :change_status, :string
    add_column :attendances, :change_check, :string, default: "0"
    add_column :attendances, :change_approval, :integer, default: 1
  end
end
