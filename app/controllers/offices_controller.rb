class OfficesController < ApplicationController
  
  #before_action :set_user, only: [:new, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit, :update]

  def index
    @offices = Office.all
  end
  
  def new
    @office = Office.new
  end
  
  def create
    if (params[:office][:work] != "出勤") && (params[:office][:work] != "退勤")
      flash[:danger] = "出勤退勤以外は入力できません。" 
    else
      @office = Office.new(base_params)
      if @office.save
        flash[:success] = "拠点情報を追加しました。"
      else
        flash[:danger] = "拠点情報の修正は失敗しました。"
      end
    end
    redirect_to offices_url
  end
  
  def edit
    @office = Office.find(params[:id])
  end
  
  def update
    @office = Office.find(params[:id])
    if (params[:office][:work] != "出勤") && (params[:office][:work] != "退勤")
      flash[:danger] = "出勤退勤以外は入力できません。" 
    else
      if @office.update_attributes(base_params)
        flash[:success] = "拠点情報を修正しました。"
      else
        flash[:danger] = "拠点情報の修正は失敗しました。" 
      end
    end
    redirect_to offices_url
  end
  
  def destroy
    @office = Office.find(params[:id])
    @office.destroy
    flash[:success] = "拠点情報のデータを削除しました。"
    redirect_to offices_url
  end
  
  
  private
  
    def base_params
      params.require(:office).permit(:base_number, :base, :work)
    end
end
