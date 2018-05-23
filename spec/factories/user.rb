FactoryBot.define do
  factory :user do
    name  { FFaker::Name.name }
    email { FFaker::Internet.email }

    trait :admin do
      role 'admin'
    end

    trait :user do
      role 'user'
    end
  end
end
