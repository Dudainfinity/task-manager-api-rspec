FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { Faker::Lorem.sentence }
    user
  end
end
