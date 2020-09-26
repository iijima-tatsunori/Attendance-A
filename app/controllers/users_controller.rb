require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_user, only: [:edit, :update, :index, :destroy, :edit_basic_info, :update_basic_info, :coming]
  before_action :set_one_month, only: :show
  before_action :invalid_admin_user, only: :show
  
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
    @csv_export = @user.attendances.where(change_approval: 3).order(:worked_on)
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@csv_export)
      end
    end
  end
  
  def send_attendances_csv(csv_export)
    csv_data = CSV.generate do |csv|
      header = %w(日付 変更前出社時間 変更前退社時間 変更後出社時間 変更後退社時間 承認者)
      csv << header

      @csv_export.each do |attendance|
        values = [attendance.worked_on,
                  attendance.started_at&.strftime("%R"),
                  attendance.finished_at&.strftime("%R"),
                  attendance.changed_started_at&.strftime("%R"),
                  attendance.changed_finished_at&.strftime("%R"),
                  attendance.change_superior_name
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
