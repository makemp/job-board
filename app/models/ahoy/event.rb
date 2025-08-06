require_relative "../analytics_record"
class Ahoy::Event < AnalyticsRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
end
