# gem faker.different of create! and create method is it raises an exception for
# an invalid user instead return false. makes debugger easier than silent errors
User.create!(
  name:  "Huỳnh Thanh Tùng", email: "thanhtungcnttk13@gmail.com", password: "123qweasd",
  password_confirmation: "123qweasd", admin: true, activated: true,
  activated_at: Time.zone.now
)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(
    name: name, email: email, password: password,
    password_confirmation: password, activated: true, activated_at: Time.zone.now
  )
end

users = User.order(:created_at).take 6
50.times do
  content = Faker::Lorem.sentence 5
  users.each {|user| user.microposts.create! content: content}
end

# Following relationships
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each {|followed| user.follow followed}
followers.each {|follower| follower.follow user}
