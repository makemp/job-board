FactoryBot.define do
  factory :ahoy_visit, class: "Ahoy::Visit" do
    visit_token { SecureRandom.uuid }
    visitor_token { SecureRandom.uuid }
    user_id { nil }
    ip { "127.0.0.1" }
    user_agent { "RSpec" }
    referrer { nil }
    referring_domain { nil }
    landing_page { "/" }
    browser { "Chrome" }
    os { "Mac OS" }
    device_type { "Desktop" }
    country { "US" }
    region { "" }
    city { "" }
    latitude { 0.0 }
    longitude { 0.0 }
    utm_source { nil }
    utm_medium { nil }
    utm_term { nil }
    utm_content { nil }
    utm_campaign { nil }
    app_version { "1.0" }
    os_version { "10.15" }
    platform { "web" }
    started_at { Time.current }
  end
end
