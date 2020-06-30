module AttendancesHelper
  
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれも当てはまらなかった場合はfalseを返します。
    return false
  end
  
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def format_hour(time)
    format("%.2d",(time.hour))
  end

  
  def format_min(time)
    format("%.2d",(((time.min)/15) * 15))
  end
  
  
  def overtime_request(scheduled_end_time, finished_at, next_day)
    if next_day == true
      format("%.2f", ((((scheduled_end_time.hour - finished_at.hour)*60 + (scheduled_end_time.min - finished_at.min)) / 60.0) + 24))
    else
      format("%.2f", ((((scheduled_end_time.hour - finished_at.hour)*60 + (scheduled_end_time.min - finished_at.min)) / 60.0)))
    end
  end
end