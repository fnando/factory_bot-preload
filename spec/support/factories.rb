Factory.define :user do |f|
  f.name "John Doe"
  f.email { Factory.next(:email) }
end

Factory.sequence :email do |i|
  "john#{i}@doe.com"
end

Factory.define :skill do |f|
  f.association :user
end