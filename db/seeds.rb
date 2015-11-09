# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if AdminUser.count == 0
  AdminUser.create!(email: 'doi@level-five.jp', password: 'password', password_confirmation: 'password')
  AdminUser.create!(email: 'daisuke.satoh@level-five.jp', password: 'password', password_confirmation: 'password')
end

seeds = ['Endpoint']
seeds.each do |table|
  Model = Object.const_get(table)
  Model.delete_all
  csv = CSV.readlines("db/seeds_data/%s.csv" % table.underscore.pluralize)
  columns = csv.shift
  csv.each do |row|
    data = {}
    columns.each_with_index do |column, index|
      data[column] = row[index]
    end
    Model.create!(data)
  end
end
