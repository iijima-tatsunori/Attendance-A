require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :show_change,:show_overtime, :show_one_month,
                                  :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :basic_edit]
                                  
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :coming, :update_basic_info, :basic_edit]
  before_action :admin_user, only: [:edit, :update, :index, :destroy, :edit_basic_info, :update_basic_info, :coming, :basic_edit]
  before_action :set_one_month, only: [:show, :show_one_month]
  before_action :re_set_one_month, only: [:show_change, :show_overtime]
  before_action :invalid_admin_user, only: [:show, :show_change, :show_overtime, :show_one_month]
  before_action :uncorrect_user, only: [:show_change, :show_overtime, :show_one_month]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def show
    @superiors = superior_without_me
    @superiors_all = superior_add_me
    @month = set_one_month_apply
    @worked_sum = @attendances.where.not(started_at: nil).count
    
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@attendances)
      end
    end
  end
  
  def show_change
    @superiors = superior_without_me
    @users = change_apply_employee
    @superiors_all = superior_add_me
    @month = set_one_month_apply
    @worked_sum = @attendances.where.not(started_at: nil).count
    if params[:date]
      @date = Date.parse(params[:date])
    else 
      @date = Date.today
    end
  end
  
  def show_overtime
    @superiors = superior_without_me
    @users = overtime_applying_employee
    @superiors_all = superior_add_me
    @month = set_one_month_apply
    @worked_sum = @attendances.where.not(started_at: nil).count
    if params[:date]
      @date = Date.parse(params[:date])
    else 
      @date = Date.today
    end
  end
  
  def show_one_month
    @superiors = superior_without_me
    @users = monthly_applying_employee
    @superiors_all = superior_add_me
    @month = set_one_month_apply
    @worked_sum = @attendances.where.not(started_at: nil).count
    if params[:date]
      @date = Date.parse(params[:date])
    else 
      @date = Date.today
    end
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  def send_attendances_csv(attendances)
    csv_data = CSV.generate do |csv|
      header = %w(日付 出社時間 退社時間)
      csv << header

      @attendances.each do |day|
        values = [l(day.worked_on, format: :short),
                  (day.changed_started_at.floor_to(15.minutes)&.strftime("%R") if day.changed_started_at.present? && day.change_status != "申請中" && day.change_status != "否認" && day.change_status != "なし" && day.status != "なし"),
                  (day.changed_finished_at.floor_to(15.minutes)&.strftime("%R") if day.changed_finished_at.present? && day.change_status != "申請中" && day.change_status != "否認" && day.change_status != "なし" && day.status != "なし")
                  ]
        csv << values
      end

    end
    send_data(csv_data, filename: "attendances.csv")
  end
  
  def index
    @users = User.where.not(admin: true)
  end
  
  def import
    if params[:csv_file].blank?
      flash[:danger] = "csvファイルを選択して下さい。"
      redirect_to users_url
    else
      num = User.import(params[:csv_file])
      if num > 0
        flash[:success] = "新規作成に成功しました。"
        redirect_to users_url
      else
        flash[:danger] = "読み込みエラーが発生しました。"
      end
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      
      if current_user.admin?
        redirect_to users_url
      else
        redirect_to @user
      end
      
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def coming
    @in_working_users = User.in_working_users
  end
  
  def basic_edit
  end
  
  
  
  
  private
  
    def user_params
      params.require(:user).permit(:name,
                                  :email,
                                  :affiliation,
                                  :employee_number,
                                  :uid,
                                  :basic_work_time,
                                  :designated_work_start_time,
                                  :designated_work_end_time,
                                  :password,
                                  :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_time, :work_time)
    end
    
  
end
