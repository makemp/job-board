# == Schema Information
#
# Table name: ahoy_events
#
#  id         :integer          not null, primary key
#  name       :string
#  properties :json
#  time       :datetime
#  visit_id   :integer
#
# Indexes
#
#  index_ahoy_events_on_name_and_time  (name,time)
#  index_ahoy_events_on_properties     (properties)
#  index_ahoy_events_on_visit_id       (visit_id)
#
require_relative "../analytics_record"
class Ahoy::Event < AnalyticsRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
end
