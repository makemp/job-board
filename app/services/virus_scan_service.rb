class VirusScanService
  SCANNER_URL = "https://antivirus-staging.fly.dev/v2/scan".freeze

  def initialize(file_path)
    @file_path = file_path
  end

  def call(retries: 5)
    unless File.exist?(file_path)
      Rails.logger.warn("File not found: #{file_path}. Skipping virus scan.")
      return true
    end

    uri = URI.parse(SCANNER_URL)
    request = Net::HTTP::Post.new(uri)

    api_key = ENV["ANTIVIRUS_API_KEY"]
    unless api_key
      Rails.logger.warn("Virus scan API key is not set. Skipping virus scan.")
      return true
    end
    request["Authorization"] = "Bearer #{api_key}"

    file = File.open(file_path)
    form_data = {"file" => file}
    request.set_form(form_data, "multipart/form-data")

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30) do |http|
      http.request(request)
    end

    results = JSON.parse(response.body)

    return true if results["Status"] == "OK"

    Rails.logger.warn("Virus scan failed: #{results["Description"]}")
    false
  rescue Timeout::Error, Errno::ECONNREFUSED => e
    Rails.logger.warn("error" => "Failed to connect to scan service", "details" => e.message)
    true
  rescue JSON::ParserError
    Rails.logger.warn("error" => "Failed to parse response from scan service: #{response.body}")
    return true if retries < 1
    sleep(5.seconds)
    call(retries: retries - 1)
  ensure
    file&.close
  end
end
