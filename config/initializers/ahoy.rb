# --- Standard Ahoy Configuration ---

# Set to true for JavaScript tracking if you are using the Ahoy.js library
Ahoy.api = false

Ahoy.geocode = true
Ahoy.job_queue = :low_priority

class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    begin
      ip = request.env["HTTP_X_FORWARDED_FOR"].presence
      data[:ip] = if ip
        Ahoy.mask_ip(ip.split(",").first.strip)
      else
        Rails.logger.warn("Ahoy: could not get remote IP from HTTP_X_FORWARDED_FOR. No HTTP_X_FORWARDED_FOR header")
        request.remote_ip
      end
    rescue => e
      Rails.logger.warn("Ahoy: could not get remote IP from HTTP_X_FORWARDED_FOR. Message: #{e.message}")
      data[:ip] = request.remote_ip
    end
    super
  end

  def authenticate(_)
    # do not track
  end
end

# GDPR compliance

Ahoy.cookies = :none

module Ahoy
  class GeocodeV2Job < ActiveJob::Base
    queue_as { Ahoy.job_queue }

    def perform(visit_token, ip)
      location =
        begin
          Geocoder.search(ip).first
        rescue NameError
          raise "Add the geocoder gem to your Gemfile to use geocoding"
        rescue => e
          Ahoy.log "Geocode error: #{e.class.name}: #{e.message}"
          nil
        end

      if location && location.country.present?
        data = {
          country: location.country,
          country_code: location.try(:country_code).presence,
          region: location.try(:state).presence,
          city: location.try(:city).presence
          # postal_code: location.try(:postal_code).presence,
          # latitude: location.try(:latitude).presence,
          # longitude: location.try(:longitude).presence
        }

        Ahoy::Tracker.new(visit_token: visit_token).geocode(data)
      end
    end
  end
end
