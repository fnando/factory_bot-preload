FactoryGirl.define do
  factory :user do |f|
    f.name "John Doe"
    f.sequence(:email) {|n| "john#{n}@doe.com"}
  end

  factory :skill do |f|
    f.association :user
  end

  preload do
    factory(:john) { Factory(:user) }
    factory(:ruby) { Factory(:skill, :user => users(:john)) }
  end
end
