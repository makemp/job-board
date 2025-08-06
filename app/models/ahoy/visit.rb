require_relative "../analytics_record"
class Ahoy::Visit < AnalyticsRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
end
