class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  
  def index
   @users = User.all
   #検索処理
   if params[:search]
      @users = User.where('LOWER(name) LIKE ?', "%#{params[:search][:name].downcase}%").paginate(page: params[:page])
   else
      @users = User.paginate(page: params[:page])
   end
  end

  
  def import
    if params[:csv_file].present? && 
       params[:cvs_file].original_filename && 
       File.extname(params[:cvs_file].original_filename) == ".csv" # パラメータのoriginal_filenameでチェック
      # 例外を捕捉してエラーが起きないようにする
      begin
        num = Cost.import(params[:csv_file])
        redirect_to action: 'index', notice: "#{ num.to_s }件のデータ情報を追加/更新しました"
        return false # 失敗しなければここまで来る。double render error対策にreturn falseして終了
      rescue # 途中でエラー(CSVのnewでエラーが起きたら)ここに飛ぶ
        # 特別な後片付けは必要なさそうなので、そのまま。
        # エラーの種類が特定できるなら、rescueの引数で切り分けてメッセージをflashに入れるとかのOK
      end
    end
    # パラメータの条件ではねられたり、途中でエラーが起きたりした時はここまで来る
    redirect_to action: 'index', error: '読み込むCSVを選択してください'
  end
  

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    #csv処理
    respond_to do |format|
     format.html do
        #html用の処理を書く
     end
     format.csv do
        #csv用の処理を書く
        send_data render_to_string, filename: "(ファイル名).csv", type: :csv
     end
    end
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

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
end