FactoryBot.define do
  factory :cart do
    total_price { 0 }
    last_interaction_at { Time.current }

    trait :abandoned do
      abandoned_at { Time.current }
    end

    trait :old_abandoned do
      abandoned_at { 8.days.ago }
    end

    trait :inactive do
      last_interaction_at { 5.hours.ago }
    end
  end
end
