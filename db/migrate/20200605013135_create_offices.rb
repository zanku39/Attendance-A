class CreateOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :offices do |t|
      t.integer :base_number
      t.string :base, default: "拠点A"
      t.string :work, default: "出勤"
      t.string :budget_d

      t.timestamps
    end
  end
end
