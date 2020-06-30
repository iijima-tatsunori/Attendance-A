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
             admin: true)

User.create!(name: "社長",
             email: "president@email.com",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "支店長",
             email: "manager@email.com",
             password: "password",
             password_confirmation: "password")

User.create!(name: "一般　仁",
             email: "general-1@email.com",
             password: "password",
             password_confirmation: "password")
             
User.create!(name: "遅刻田　寝流与",
             email: "general-2@email.com",
             password: "password",
             password_confirmation: "password")
