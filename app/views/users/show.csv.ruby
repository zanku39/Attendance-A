require 'csv'
require 'date'

CSV.generate do |csv|
    csv_column_names = %w(日付 出社時間 退社時間 備考)
    csv << csv_column_names
    @attendances.each do |attendance|
    column_values = [
        attendance.worked_on.to_s(:date),
        if attendance.started_at.present?
            attendance.started_at.strftime("%R")
        end,
        if attendance.finished_at.present?
            attendance.finished_at.strftime("%R")
        end,
    ]
    csv << column_values
    end
end