# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)



users = []
users.push(FactoryBot.create(:user, firstname: 'hama', lastname: 'safi', access_level: :super_admin, email: 'hmmshl@gmail.com', password: 'Admin12345')) if User.where(email: 'hmmshl@gmail.com').blank?

# Create 50 tags
50.times { FactoryBot.create(:tag) }
50.times { FactoryBot.create(:note_tag) }

# Create 3 users
users = users + FactoryBot.create_list(:user, 20, password: 'Admin12345')


# Create 10 notes for each user
users.each do |user|
  FactoryBot.create_list(:note, 10, owner: user)
end

p "email:" + "hmmshl@gmail.com"
p "password :" + "Admin12345"