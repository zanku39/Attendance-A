require 'csv'
require 'date'

CSV.generate do |csv|
    csv_column_names = %w(日付 曜日 出社時間 退社時間)
    csv << csv_column_names
    @attendances.each do |attendance|
      csv_column_values = [
        attendance.worked_on.strftime("%Y/%m/%d"),
        $days_of_the_week[attendance.worked_on.wday],
        if attendance.started_at.present?
          l(attendance.started_at.floor_to(60*15), format: :time)
        else
          ""
        end,
        if attendance.finished_at.present?
          l(attendance.finished_at.floor_to(60*15), format: :time)
        else
          ""
        end
      ]
      csv << csv_column_values
    end
end