FactoryGirl.define do
  factory :artist do |f|
    f.name "Sid Vicious"
  end

  preload do
    factory(:sid) { create(:artist) }
  end
end

