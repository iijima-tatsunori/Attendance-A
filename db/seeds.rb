# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# coding: utf-8

User.create!(name: "管理者",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "自由人",
             employee_number: 1,
             admin: true)

User.create!(name: "上長1",
             email: "superior1@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス部",
             employee_number: 2,
             superior: true)
             
User.create!(name: "上長2",
             email: "superior2@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス部",
             employee_number: 3,
             superior: true)

User.create!(name: "一般1",
             email: "general1@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス部",
             employee_number: 4)
             
User.create!(name: "一般2",
             email: "general2@email.com",
             password: "password",
             password_confirmation: "password",
             affiliation: "フリーランス部",
             employee_number: 5)
