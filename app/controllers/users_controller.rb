class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :index1,]
  before_action :set_one_month, only: :show
  
  def index
   if params[:search]
      @users = User.whereRaw('LOWER(name) LIKE ?', "%#{params[:search][:name].downcase}%").paginate(page: params[:page])
   else
      @users = User.paginate(page: params[:page])
   end
  end
  
  def index1
    @users = User.joins(:attendances).where("attendances.finished_at": nil).where.not("attendances.started_at": nil)
  end
  
  
  def import
    if params[:file].blank?
      flash[:danger] = "csvファイルが選択されていません。"
      redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "ユーザー情報をインポートしました。"
      redirect_to users_url
    end
  end
  

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    #user = User.find_by(id: current_user)
    #@first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    #@last_day = @first_day.end_of_month
    #@attendances = user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    #send_data render_to_string, filename: "attendances.csv", type: :csv
  end


  def new
    @user = User.new
  end
  
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
       flash[:success] = "ユーザー情報を更新しました。"
       redirect_to @user
    else
      render :edit      
    end
  end
  
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def edit_overtime_request
    @user = User.find(params[:id])
    @attendance = @user.attendances.find(params[:id])
    @superior = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_overtime_request
    @user = User.find(params[:id])
    @attendance = @user.attendances.find(params[:id])
    if @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請しました。"
    else
      params[:attendance][:business_outline].blank? || params[:attendance][:confirmation].blank?
      flash[:danger] = "残業申請に失敗しました。"
    end
    redirect_to @user
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number)
    end
    
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def overtime_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day, :business_outline, :confirmation])[:attendances]
    end
end