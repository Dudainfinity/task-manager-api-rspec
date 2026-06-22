FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    description { Faker::Lorem.sentence }
    status { :todo }
    priority { :medium }
    due_date { nil }
    project

    trait :done do
      status { :done }
      completed_at { Time.current }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :overdue do
      status { :todo }
      due_date { Date.current - 2 }
    end

    trait :high_priority do
      priority { :high }
    end
  end
end
