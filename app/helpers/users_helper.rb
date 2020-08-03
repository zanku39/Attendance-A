module UsersHelper

  # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  
  def company_time(started_at, finished_at, tomorrow)
    if tomorrow == true
      format("%.2f", ((((finished_at.hour - started_at.hour)*60 + (finished_at.min - started_at.min)) / 60.0) + 24))
    else
      format("%.2f", ((((finished_at.hour - started_at.hour)*60 + (finished_at.min - started_at.min)) / 60.0)))
    end
  end
end