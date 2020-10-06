module AttendancesHelper
  
  
  
  # 1ヶ月の勤怠申請用
  def set_one_month_apply
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # １ヶ月申請フォームのステータス表示
  def apply_status(status)
    case status
    when "申請中"
      "に申請中"
    when "承認"
      "から承認済"
    when "否認"
      "から否認"
    else
      "未"
    end
  end
  
  def apply_btn_status(status)
    case status
      when "申請中"
        "申請先を変更"
      when "承認"
        "再申請"
      when "否認"
        "再申請"
    else
      "申請"
    end
  end
  
  # 勤怠変更申請のステータス表示
  def change_status_text(status)
    case status
    when "申請中"
      "に勤怠編集申請中"
    when "否認"
      "に勤怠編集否認"
    when "承認"
      "に勤怠編集承認︎︎"
    when "なし"
    else
    end
  end
  
  def change_apply_status(status)
    case status
      when "申請中"
        "申請中"
      when "承認"
        "承認済"
      when "否認"
        "否認"
    else
      "申請"
    end
  end
  
  
  # 1ヶ月勤怠申請先の上長の選択されているか？
  def selected_superior?
    superior = true
    month_apply_params.each do |id, item|
      if item[:superior_id].blank? && [:month_apply].present?
        superior = false
      elsif item[:superior_id].present? && [:month_apply].present?
        superior = true
        break
      end
    end
    superior
  end
  
  def superior_add_me
    User.where(superior: true)
  end
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return "出勤" if attendance.started_at.nil?
      return "退勤" if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  def time_select_invalid?(item)
    item[:change_superior_id].present? && item["started_at(4i)"] == "" && item["started_at(5i)"] == "" && item["finished_at(4i)"] == "" && item["finished_at(5i)"] == ""
  end
  
  def overtime_time_select_invalid?(item)
    item[:overtime_superior_id].present? && item["finished_plan_at(4i)"] == "" && item["finished_plan_at(5i)"] == "" 
  end
  
  def attendances_invalid?
    attendances = true
      attendances_params.each do |id, item|
        if item[:change_superior_id].blank?
          next
        elsif item[:change_superior_id].present? && item[:note].blank?
          attendances = false
          if item[:note].blank?
            @msg = "備考を入力してください。"
          end
          break
        elsif item[:change_superior_id].present? && item[:note].present? && item['changed_started_at(4i)'] == "" && item['changed_started_at(5i)'] == "" && item['changed_finished_at(4i)'] == "" && item['changed_finished_at(5i)'] == ""
          attendances = false
          break
        elsif item[:change_superior_id].present? && item[:note].present? && item['changed_started_at(4i)'] == "" || item['changed_started_at(5i)'] == "" || item['changed_finished_at(4i)'] == "" || item['changed_finished_at(5i)'] == ""
          attendances = false
          break
        elsif item['changed_started_at(4i)'] > item['changed_finished_at(4i)'] && item[:change_next_day] == "0"
          attendances = false
        break
        elsif
          item['changed_started_at(4i)'] == item['changed_finished_at(4i)'] && item['changed_started_at(5i)'] > item['changed_finished_at(5i)'] && item[:change_next_day] == "0"
          attendances = false
          break
        end
      end
    return attendances
  end
  
  
  
  def change_working_times(start, finish, next_day)
    if next_day == "1"
      hour = (24 - start.hour) + finish.hour
      min = finish.min - start.min
      @change_total_working_time = hour + min / 60.00
    elsif
      hour = finish.hour - start.hour
      min = finish.min - start.min
      @change_total_working_time = hour + min / 60.00
    end
  end
  
  
  
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def next_day_times(finish, finished_plan)
    hour = (24 - finish.hour) + finished_plan.hour
    min = finished_plan.min + finish.min
    @total_time = hour + min / 60.00
  end
  
  
  def overworking_times(finish, finished_plan)
    hour = finished_plan.hour - finish.hour
    min = finished_plan.min - finish.min
    @total_time = hour + min / 60.00
  end
  
  # @usersに代入する申請従業員
  def overtime_applying_employee
    User.joins(:attendances).where.not(attendances: {overtime_superior_id: nil}).where(attendances: {overtime_apploval: 2}).distinct
  end
  def monthly_applying_employee
    User.joins(:attendances).where.not(attendances: {superior_id: nil}).where(attendances: {month_approval: 2}).distinct
  end
  def change_apply_employee
    User.joins(:attendances).where.not(attendances: {change_superior_id: nil}).where(attendances: {change_approval: 2}).distinct
  end
  
  
  # 上長に各種申請が来ているか
  def has_overtime_apply
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"})
  end
  def has_month_apply
    User.joins(:attendances).where(attendances: {superior_id: current_user.id}).where(attendances: {status: "申請中"})
  end
  def has_change_apply
    User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end
  
  
  
  def superior_without_me
    User.where(superior: true).where.not(id: current_user.id)
  end
  
  # 残業申請先の上長ユーザーの選択がされているか？ && 残業処理内容が入力されているか？
  def selected_overtime_superior?
    superior = true
    request_overtime_params.each do |id, item|
      if item[:business_process_content].blank? || item[:overtime_superior_id].blank? || item["finished_plan_at(4i)"] == "" || item["finished_plan_at(5i)"] == "" 
        superior = false
        break
      end
    end
    return superior
  end
  
  def apply_confirmed_invalid?(status, check)
    if (status == "承認" || status == "否認" || status == "なし") && check == "1"
      confirmed = true
    else
      confirmed = false
    end
    confirmed
  end
  
  
  
  
  
  
  
end
