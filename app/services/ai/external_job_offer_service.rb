module Ai
  class ExternalJobOfferService
    AI_URL = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent").freeze

    def self.call(url, text)
      new(url, text).call
    end

    def initialize(url, text)
      @url = url
      @text = text
    end

    def call
      http = Net::HTTP.new(AI_URL.host, AI_URL.port)
      http.use_ssl = true # Use SSL for secure connection

      request = Net::HTTP::Post.new(AI_URL.path,
        "Content-Type" => "application/json",
        "X-goog-api-key" => ENV["GEMINI_API_KEY"])

      prompt = File.read(Rails.root.join("config/prompts/external_job.txt"))
      prompt.sub("<URL_PLACEHOLDER>", url)
      prompt.sub("<TEXT_PLACEHOLDER>", text)

      request.body = {
        contents: [
          {
            parts: [
              {
                text: prompt
              }
            ]
          }
        ]
      }.to_json

      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        json = JSON.parse(response.body)
        resp = json["candidates"].first["content"]["parts"].first["text"]
        match_data = resp.match(/\s*```json\n(.*)\s*```\z/m)
        json_string = match_data[1]
        JSON.parse(json_string)
      else
        raise "AI request failed: #{response.body}"
      end
    end

    private

    attr_reader :url, :text
  end
end
