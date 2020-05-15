class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :employee_number
      t.string :uid
      t.string :affiliation
      t.time :basic_work_time, default: Time.current.change(hour: 8, min: 0, sec: 0)
      t.time :designated_work_start_time, default: Time.current.change(hour: 9, min: 0, sec: 0)
      t.time :designated_work_end_time, default: Time.current.change(hour: 18, min: 0, sec: 0)
      
      t.timestamps
    end
  end
end
