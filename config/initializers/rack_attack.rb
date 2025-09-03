# Ruby
class Rack::Attack
  # Use Redis (ensure Rails.cache uses Redis in production)
  # Example (in production): config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
  # Rack::Attack uses Rails.cache by default.

  # Helper: stable remote IP behind proxies/CDNs
  def self.remote_ip(req)
    (req.get_header("action_dispatch.remote_ip") || req.ip).to_s
  end

  # Helper: broader static/framework paths to skip from generic throttles
  STATIC_PATHS = %w[/assets /packs /favicon.ico /robots.txt /apple-touch-icon /service-worker.js /manifest.json /rails/active_storage].freeze
  def self.static_path?(req)
    STATIC_PATHS.any? { |p| req.path.start_with?(p) }
  end

  # Safelist health checks and explicitly allowed IPs
  safelist("healthchecks-and-allowlist") do |req|
    req.path == "/up" || req.path == "/healthz" ||
      ENV.fetch("RACK_ATTACK_ALLOWLIST_IPS", "").split(",").map!(&:strip).include?(remote_ip(req))
  end

  # Global request throttle (exclude static)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    remote_ip(req) unless static_path?(req)
  end

  # Write operations throttle
  throttle("write_ops/ip", limit: 60, period: 5.minutes) do |req|
    if %w[POST PUT PATCH DELETE].include?(req.request_method)
      remote_ip(req)
    end
  end

  # Rapid writes
  throttle("rapid_writes/ip", limit: 10, period: 1.minute) do |req|
    if %w[POST PUT PATCH DELETE].include?(req.request_method)
      remote_ip(req)
    end
  end

  # Login throttles (already present)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/employers/sign_in" && req.post?
  end

  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/employers/sign_in" && req.post?
      req.params["email"].to_s.downcase.gsub(/\s+/, "").presence
    end
  end

  # Webhooks: either safelist by path or set a generous separate throttle
  # Prefer verifying signatures in controllers; here we just avoid tripping global limits.
  throttle("webhooks/ip", limit: 300, period: 1.minute) do |req|
    remote_ip(req) if req.path.start_with?("/webhooks/") && req.post?
  end

  # Sensitive endpoints beyond login (customize paths)
  # Sign up
  throttle("signup/ip", limit: 5, period: 1.minute) do |req|
    remote_ip(req) if req.path == "/employers" && req.post?
  end
  # Password reset
  throttle("password_reset/ip", limit: 5, period: 1.minute) do |req|
    remote_ip(req) if req.path == "/employers/password" && req.post?
  end
  throttle("password_reset/email", limit: 5, period: 10.minutes) do |req|
    if req.path == "/employers/password" && req.post?
      req.params["email"].to_s.downcase.gsub(/\s+/, "").presence
    end
  end
  # Contact or other public forms (adjust paths as needed)
  throttle("form_submissions/ip", limit: 20, period: 10.minutes) do |req|
    remote_ip(req) if req.path.start_with?("/contact", "/feedback") && req.post?
  end

  # Fail2Ban: ban obvious bots tripping honeypots in forms
  def self.honeypot_present?(req)
    # Works for flat or nested params; checks keys that end with given_name/family_name
    req.params.any? do |k, v|
      key = k.to_s
      val = v.is_a?(Hash) ? v.values.join : v.to_s
      key.match?(/given_name\]?$|family_name\]?$/) && val.strip != ""
    end
  end

  blocklist("fail2ban-honeypot") do |req|
    Rack::Attack::Fail2Ban.filter("honeypot-#{remote_ip(req)}",
      maxretry: 1, findtime: 10.minutes, bantime: 1.hour) do
      %w[POST PUT PATCH].include?(req.request_method) && honeypot_present?(req)
    end
  end

  # Optional: custom 429 for API vs HTML
  self.throttled_responder = lambda do |env|
    path = env["PATH_INFO"].to_s
    if path.start_with?("/api")
      [429, {"Content-Type" => "application/json"}, [{error: "Too Many Requests"}.to_json]]
    else
      [429, {"Content-Type" => "text/plain"}, ["Too Many Requests"]]
    end
  end

  # Optional: basic telemetry
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, id, payload|
    req = payload[:request]
    Rails.logger.warn("rack.attack #{payload[:match_type]} #{payload[:name]} ip=#{req.ip} path=#{req.path}")
  end
end
