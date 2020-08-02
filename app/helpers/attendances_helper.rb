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
  
  
  def overtime_request(scheduled_end_time, designated_work_end_time, next_day, started_at)
    if started_at.present? && ((started_at.hour > designated_work_end_time.hour) || ((started_at.hour == designated_work_end_time.hour) && (started_at.min > designated_work_end_time.min)))
      if next_day == true
        format("%.2f", ((((scheduled_end_time.hour - started_at.hour)*60 + (scheduled_end_time.min - started_at.min)) / 60.0) + 24))
      else
        format("%.2f", ((((scheduled_end_time.hour - started_at.hour)*60 + (scheduled_end_time.min - started_at.min)) / 60.0)))
      end
    else
      if next_day == true
        format("%.2f", ((((scheduled_end_time.hour - designated_work_end_time.hour)*60 + (scheduled_end_time.min - designated_work_end_time.min)) / 60.0) + 24))
      else
        format("%.2f", ((((scheduled_end_time.hour - designated_work_end_time.hour)*60 + (scheduled_end_time.min - designated_work_end_time.min)) / 60.0)))
      end
    end
  end
  
  def change_month(change_started_at, change_finished_at, tomorrow)
    if tomorrow == true
      format("%.2f", ((((change_finished_at.hour - change_started_at.hour)*60 + (change_finished_at.min - change_started_at.min)) / 60.0) + 24))
    else
      format("%.2f", ((((change_finished_at.hour - change_started_at.hour)*60 + (change_finished_at.min - change_started_at.min)) / 60.0)))
    end
  end
end