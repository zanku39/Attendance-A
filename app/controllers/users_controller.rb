class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update_show, :show_month_reply, :show_confirmation, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :index1, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :index, :index1,]
  before_action :set_one_month, only: :show
  before_action :admin, only: :show
  
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
    elsif File.extname(params[:file].original_filename) != ".csv"
      flash[:danger] = 'csvファイルのみ読み込み可能です'
     redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "ユーザー情報をインポートしました。"
      redirect_to users_url
    end
  end
  

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overwork_notices = Attendance.where(status: "申請中", confirmation: current_user.name).count
    @change_notices = Attendance.where(change_status: "申請中", change_confirmation: current_user.name).count
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @month_notices = Attendance.where(month_status: "申請中", month_confirmation: current_user.name).count
    @month_confirmation = @user.attendances.find_by(worked_on: @first_day)
    #csv処理
    respond_to do |format|
      format.html do
        #html用の処理を書く
      end
      format.csv do
        #csv用の処理を書く
        send_data render_to_string, filename: "勤怠データ.csv", type: :csv
      end
    end
    #send_data render_to_string, filename: "attendances.csv", type: :csv
  end
  
  
  def update_show
    if params[:user][:month_confirmation].blank?
      flash[:danger] = "上長を選択して下さい。" 
      redirect_to @user and return
    end
      attendance = @user.attendances.find_by(worked_on: params[:user][:first_day])
      params[:user][:month_status] = "申請中"
      attendance.update_attributes(month_params)
      flash[:success] = "1ヶ月分の勤怠を申請しました。"
      redirect_to @user
  end
  
  def show_month_reply
    @attendances = Attendance.where(month_confirmation: current_user.name, month_status: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_show_month_reply
    r1 = 0
    r2 = 0
    r3 = 0
    ActiveRecord::Base.transaction do
        @user = User.find(params[:id])
        month_reply_params.each do |id, item|
          if (item[:fix] == "1") && (item[:month_status] == "なし" || item[:month_status] == "承認" || item[:month_status] == "否認")
          attendance = Attendance.find(id)
            if item[:month_status] == "なし"
              r1 += 1
              item[:month_status] = nil
            elsif item[:month_status] == "承認"
              r2 += 1
            elsif item[:month_status] == "否認"
              r3 += 1
            end
            item[:fix] = "0"
          attendance.update_attributes!(item)
          end
        end
      end
      flash[:success] = "残業申請の#{r1}件なし 承認#{r2}件承認 否認#{r3}件否認"
      redirect_to user_url(@user)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、変更をキャンセルしました。"
    redirect_to user_url(@user)
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
  
  def show_confirmation
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @worked_sum = @attendances.where.not(started_at: nil).count
    @month_confirmation = @user.attendances.find_by(worked_on: @first_day)
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def month_params
      params.require(:user).permit(:month_confirmation, :month_status)
    end
    
    def month_reply_params
      params.require(:user).permit(attendances: [:month_status, :fix])[:attendances]
    end
end