class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.string :note
      t.references :user, foreign_key: true
      t.datetime :scheduled_end_time
      t.boolean :next_day, default: false
      t.string :business_outline
      t.string :confirmation

      t.timestamps
    end
  end
end
