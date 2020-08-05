class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on #日付
      t.datetime :before_started_at #変更前出社時間
      t.datetime :before_finished_at #変更前退社時間
      t.datetime :started_at #出社時間
      t.datetime :finished_at #退社時間
      t.datetime :change_started_at #変更用出社時間
      t.datetime :change_finished_at #変更用退社時間
      t.string :note #備考
      t.datetime :scheduled_end_time #終了予定時間
      t.boolean :next_day #翌日
      t.boolean :tomorrow #翌日
      t.boolean :day_after #翌日
      t.string :business_outline #業務処理内容
      t.string :confirmation #残業申請用指示者確認（上長）
      t.string :change_confirmation #変更用指示者確認（上長)
      t.boolean :fix, default: false #変更のチェックボタン
      t.string :status #残業用の状態
      t.string :change_status #変更用状態
      t.date :change_date #変更日
      t.string :month_confirmation #１ヶ月指示者確認（上長）
      t.string :month_status #１ヶ月状態
      
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
