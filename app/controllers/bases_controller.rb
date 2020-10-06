class BasesController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :index, :edit, :update, :destroy,]
  before_action :set_base, only: [:edit, :update, :destroy]
  before_action :admin_user, only: [:new, :create, :index, :edit, :update, :destroy,]
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点登録完了しました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点登録失敗しました。"
      render :new
    end
  end
  
  def index
    @bases = Base.all
  end

  def edit
  end
  
  def update
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_url
    else
      render :edit
    end
  end
  
  def destroy
    @base.destroy
    flash[:success] = "拠点情報を一件削除しました。"
    redirect_to bases_url
  end
  
  
  private
  
  def base_params
    params.require(:base).permit(:base_number, :base_name, :attendance_type)
  end
  
  def set_base
    @base = Base.find(params[:id])
  end
  
  
  
end