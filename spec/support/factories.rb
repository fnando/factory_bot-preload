# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) {|n| "john#{n}@doe.com" }

  factory :user do
    name { "John Doe" }
    email { generate(:email) }
  end

  factory :skill do
    user { users(:john) }
  end

  factory :preload do
    name { "My Preload" }
  end

  preload do
    factory(:john) { create(:user) }
    factory(:ruby) { create(:skill, user: users(:john)) }
    factory(:my)   { create(:preload) }
  end
end
