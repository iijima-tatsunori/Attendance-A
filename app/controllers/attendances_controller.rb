class AttendancesController < ApplicationController
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_info,
                                  :request_month_apply, :request_overtime, :overtime_superior_reply,
                                  :request_overtime_reply, :monthly_confirmation_form, :apply_monthly_confirmation,
                                  :change_apply_form, :request_month_apply
                                  ]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overtime_info, :request_overtime]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_overtime_info, :request_overtime]
  
  
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました、やり直してください。"
  INVALID_MSG = "無効な入力データがあった為、更新をキャンセルしました。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  # 1ヶ月の勤怠申請提出
  def request_month_apply
    if selected_superior?
      month_apply_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
        item[:superior_name] = User.find(item[:superior_id]).name
        attendance.update_attributes!(item)
        @month_apply = item[:month_apply].to_date.strftime("%-m")
        @superior = item[:superior_name]
      end
      flash[:success] = "#{@user.name}の#{@month_apply}月分勤怠申請を、#{@superior}へ提出しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "申請先の上長を選択してください。"
      redirect_to user_url(date: params[:date])
    end
  end
  
  
  def monthly_confirmation_form
    @users = monthly_applying_employee
  end
  
  def apply_monthly_confirmation
    month_reply_params.each do |id, item|
      if apply_confirmed_invalid?(item[:status], item[:month_check])
      attendance = Attendance.find(id)
      attendance.update_attributes(item)
        if item[:status] == "否認"
          item[:month_approval] = 2
          item[:month_check] = "0"
          attendance.update_attributes(item)
        end
      end
    end
    flash[:success] = "１ヶ月勤怠申請の決済を更新しました。"
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "エラーが発生した為、１ヶ月勤怠申請の更新がキャンセルされました。"
    redirect_back(fallback_location: root_path)
  end
  
  
  
  def edit_one_month
    @superiors = superior_without_me
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      if attendances_invalid?
        
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          if item[:change_superior_id].present?
            attendance.update_attributes!(item)
            attendance.update_attributes!(change_superior_name: User.find(item[:change_superior_id]).name)
          end
        end
        flash[:success] = "1ヶ月分の勤怠変更を申請しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "#{INVALID_MSG}#{@msg}"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "#{INVALID_MSG}#{@msg}"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def change_apply_form
    @users = change_apply_employee
  end
  
  def request_month_apply
  end
  
  
  
  
  
  def edit_overtime_info
    @superiors = superior_without_me
  end
  
  def request_overtime
    request_overtime_params.each do |id, item|
      if selected_overtime_superior?
        attendance = Attendance.find(id)
        attendance.update_attributes(item) unless time_select_invalid?(item)
          if attendance.next_day == true
            next_day_times(@user.designated_work_end_time, attendance.finished_plan_at)
          else
            overworking_times(@user.designated_work_end_time, attendance.finished_plan_at)
          end
        attendance.update_attributes(overtime_hours: @total_time, overtime_superior_name: User.find(item[:overtime_superior_id]).name)
        
        flash[:success] = "#{attendance.overtime_superior_name}に残業申請を送信しました。"
        redirect_back(fallback_location: root_path)
      else
        msg_a = "申請先上長を選択してください。" if item[:overtime_superior_id].blank?
        msg_b = "業務処理内容を入力してください。" if item[:business_process_content].blank?
        flash[:danger] = "#{msg_a}#{msg_b}"
        redirect_back(fallback_location: root_path)
      end
      
    end
  end
  
  
  def overtime_superior_reply
    @users = overtime_applying_employee
  end
  
  def request_overtime_reply
    reply_overtime_params.each do |id, item|
      if apply_confirmed_invalid?(item[:overtime_status], item[:overtime_check])
        attendance = Attendance.find(id)
        attendance.update_attributes(item) unless time_select_invalid?(item)
        if item[:overtime_status] == "否認"
           item[:overtime_apploval] = 2
           item[:overtime_check] = "0"
           attendance.update_attributes(item)
        end
      end
    end
    flash[:success] = "残業申請を返信しました。"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "エラーが発生した為、残業申請の変更がキャンセルされました。"
    redirect_to root_path
  end
  
  private
  
  # 1ヶ月の勤怠申請
  def month_apply_params
    params.permit(attendances: [:superior_id, :superior_name, :status, :month_apply, :month_approval, :month_check])[:attendances]
  end
  
  # 勤怠申請承認
  def month_reply_params
    params.permit(attendances: [:status, :month_approval, :month_check])[:attendances]
  end
  
  
  
  
  def attendances_params
    params.require(:user).permit(attendances: [:started_at,
                                               :finished_at,
                                               :note,
                                               :changed_started_at,
                                               :changed_finished_at,
                                               :change_next_day,
                                               :change_status,
                                               :change_superior_id,
                                               :change_approval,
                                               :change_check,
                                               :calendar_day
                                               ])[:attendances]
  end
  
  def request_overtime_params
    params.require(:user).permit(attendances: [:finished_plan_at,
                                               :business_process_content,
                                               :next_day,
                                               :overtime_superior_id,
                                               :overtime_hours,
                                               :overtime_status,
                                               :overtime_apploval,
                                               :overtime_check])[:attendances]
  end
  
  def reply_overtime_params
    params.require(:user).permit(attendances: [:overtime_status,
                                               :overtime_apploval,
                                               :overtime_check])[:attendances]
  end
  
  # beforeフィルター
  
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "権限がありません。"
      redirect_to(root_url)
    end
  end
  
end
