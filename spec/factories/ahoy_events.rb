FactoryBot.define do
  factory :ahoy_event, class: "Ahoy::Event" do
    association :visit, factory: :ahoy_visit
    name { "event_name" }
    properties { {} }
    time { Time.current }
    user { nil }
  end
end
