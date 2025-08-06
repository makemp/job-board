# --- Standard Ahoy Configuration ---

# Set to true for JavaScript tracking if you are using the Ahoy.js library
Ahoy.api = false

# GDPR compliance
Ahoy.mask_ips = true
Ahoy.cookies = :none

Ahoy.geocode = true
Ahoy.job_queue = :low_priority

class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    data[:ip] = request.env["HTTP_CF_CONNECTING_IP"] || request.remote_ip
    super
  end

  def authenticate(_)
    # do not track
  end
end
