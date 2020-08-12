require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_user, only: [:edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  
  
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
    
    @worked_sum = @attendances.where.not(started_at: nil).count
    @users = User.all
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_users_csv(@users)
      end
    end
  end
  
  def send_users_csv(users)
    csv_data = CSV.generate do |csv|
      header = %w(name email affiliation employee_number uid basic_work_time designated_work_start_time designated_work_start_time superior admin password)
      csv << header

      @users.each do |user|
        values = [user.name,
                  user.email,
                  user.affiliation,
                  user.employee_number,
                  user.uid,
                  l(user.basic_work_time, format: :time),
                  l(user.designated_work_start_time, format: :time),
                  l(user.designated_work_end_time, format: :time),
                  user.superior,
                  user.admin,
                  user.password]
        csv << values
      end

    end
    send_data(csv_data, filename: "users.csv")
  end
  
  def index
    @users = User.all
  end
  
  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    redirect_to users_url
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
