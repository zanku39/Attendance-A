class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :attendances_invalid?, only: :update_one_month

  
  
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
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

  def edit_one_month
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      if attendances_invalid?
        attendances_params.each do |id, item|
          if item[:tomorrow] == "0" && (item[:change_started_at] > item[:change_finished_at])
            flash[:danger] = "出社または退社の時間に問題のところがあります。" 
            redirect_to @user and return
          elsif item[:change_started_at].present? && item[:change_finished_at].blank? && (item[:change_started_at].blank? && item[:change_finished_at].present?)
            flash[:danger] = "出社または退社の時間に問題のところがあります。" 
            redirect_to @user and return
          elsif item[:change_started_at].present? && item[:change_finished_at].present? && item[:change_confirmation].present?
            item[:change_status] = "申請中"
            attendance = Attendance.find(id)
            attendance.update_attributes!(item)
          end
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
      end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_overtime_request
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_overtime_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if params[:attendance][:scheduled_end_time].blank?
      flash[:danger] = "終了予定時間を記入して下さい" 
      redirect_to @user and return
    elsif params[:attendance][:business_outline].blank?
      flash[:danger] = "業務処理内容を記入して下さい。" 
      redirect_to @user and return
    elsif params[:attendance][:confirmation].blank?
      flash[:danger] = "上長を選択して下さい。" 
      redirect_to @user and return
    end
      @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請しました。"
      redirect_to @user
  end
  
  def edit_overtime_reply
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(confirmation: current_user.name, status: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_overtime_reply
    r1 = 0
    r2 = 0
    r3 = 0
    ActiveRecord::Base.transaction do
        @user = User.find(params[:user_id])
        #@attendances = Attendance.where(confirmation: current_user.name, status: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
        reply_params.each do |id, item|
          if (item[:fix] == "1") && (item[:status] == "なし" || item[:status] == "承認" || item[:status] == "否認")
          attendance = Attendance.find(id)
            if item[:status] == "なし"
              r1 += 1
              attendance.scheduled_end_time = nil
              attendance.business_outline = nil
              item[:status] = nil
            elsif item[:status] == "承認"
              r2 += 1
            elsif item[:status] == "否認"
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
  
  def edit_month_reply
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(change_confirmation: current_user.name, change_status: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_month_reply
    r1 = 0
    r2 = 0
    r3 = 0
    ActiveRecord::Base.transaction do
        @user = User.find(params[:user_id])
        #@attendances = Attendance.where(change_confirmation: current_user.name, change_status: "申請中").order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
        attendances_reply.each do |id, item|
          if (item[:fix] == "1") && (item[:change_status] == "なし" || item[:change_status] == "承認" || item[:change_status] == "否認")
          attendance = Attendance.find(id)
            if item[:change_status] == "なし"
              r1 += 1
              attendance.change_started_at = nil
              attendance.change_finished_at = nil
              attendance.note = nil
              item[:change_status] = nil
            elsif item[:change_status] == "承認"
              r2 += 1
              if attendance.before_started_at.blank?
                attendance.before_started_at = attendance.started_at
              end
              if attendance.before_finished_at.blank?
                attendance.before_finished_at = attendance.finished_at
              end
              attendance.started_at = attendance.change_started_at
              attendance.finished_at = attendance.change_finished_at
              attendance.change_date = Date.current
            elsif item[:change_status] == "否認"
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
  
  def approved
    @user = User.find(params[:user_id])
    @logs = @user.attendances.where(change_status: "承認").order(worked_on: "ASC")
  end
  
  private
  
  
    # １ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:change_started_at, :change_finished_at, :tomorrow, :note, :change_confirmation, :change_status])[:attendances]
    end
    
    def attendances_reply
      params.require(:user).permit(attendances: [:change_status, :fix])[:attendances]
    end
    
    def overtime_params
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_outline, :confirmation, :status)
    end
    
    def reply_params
      params.require(:user).permit(attendances: [:status, :fix])[:attendances]
    end
    
    # beforeフィルター
    
    
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
    
    def attendances_invalid?
      attendances_params.each do |id, item|
        if item[:started_at].present? && item[:finished_at].blank?
          flash[:danger] = "退社時間が入力されてません。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date])
        elsif item[:finished_at].present? && item[:started_at].blank?
          flash[:danger] = "出社時間が入力されてません。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date])
        end
      end
    end
end