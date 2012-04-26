FactoryGirl.define do
  factory :user do |f|
    f.name "John Doe"
    f.sequence(:email) {|n| "john#{n}@doe.com"}
  end

  factory :skill do |f|
    f.association :user
  end

  factory :preload do |f|
    f.name "My Preload"
  end

  preload do
    factory(:john) { create(:user) }
    factory(:ruby) { create(:skill, :user => users(:john)) }
    factory(:my)   { create(:preload) }
  end
end
