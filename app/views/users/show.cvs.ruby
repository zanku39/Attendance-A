show.csv.ruby
require 'csv'
CSV.generate do |csv|
  csv << ["勤怠情報"]
  csv << []
  column_names = %w(日付 出社時間 退社時間 備考)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on.strftime("%m/%d"),
      attendance.started_at,
      attendance.finished_at,
      attendance.note
    ]
    csv << column_values  
  end
end