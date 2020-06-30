# coding: utf-8


User.create!(name: "管理者",
             email: "sample@email.com",
             affiliation: "管理",
             employee_number: "1",
             uid: "1",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "上長A",
             email: "samplea@email.com",
             affiliation: "管理",
             employee_number: "2",
             uid: "2",
             password: "password",
             password_confirmation: "password",
             superior: true)
             
User.create!(name: "上長B",
             email: "sampleb@email.com",
             affiliation: "管理",
             employee_number: "3",
             uid: "3",
             password: "password",
             password_confirmation: "password",
             superior: true)
             
User.create!(name: "テスト",
             email: "samplec@email.com",
             affiliation: "フリーランス部",
             employee_number: "4",
             uid: "4",
             password: "password",
             password_confirmation: "password")
             
             
60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  affiliation = "フリーランス部"
  employee_number = "#{n+1}"
  uid = "#{n+1}"
  password = "password"
  User.create!(name: name,
               email: email,
               affiliation: affiliation,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password)
end
               

Office.create!(base_number: "1",
             base: "東京",
             work: "出勤")
             
Office.create!(base_number: "2",
             base: "福岡",
             work: "出勤")
             
Office.create!(base_number: "3",
             base: "名古屋",
             work: "出勤")