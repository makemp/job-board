class VirusScanService
  def self.scan_file(file_path)
    return {clean: true, message: "Virus scanning disabled"} if Rails.env.production?
    return {clean: false, message: "File not found"} unless File.exist?(file_path)
    return {clean: false, message: "File too large"} if File.size(file_path) > 32.megabytes

    api_key = Rails.application.credentials.virustotal_api_key
    return {clean: true, message: "No API key configured"} unless api_key

    begin
      # Upload file for scanning
      response = post("/file/scan", {
        body: {
          apikey: api_key,
          file: File.open(file_path)
        }
      })

      if response.success?
        resource = response.parsed_response["resource"]

        # Wait a moment then check results
        sleep(2)

        # Get scan report
        report_response = get("/file/report", {
          query: {
            apikey: api_key,
            resource: resource
          }
        })

        if report_response.success?
          result = report_response.parsed_response

          if result["response_code"] == 1
            positives = result["positives"] || 0
            total = result["total"] || 0

            if positives > 0
              {
                clean: false,
                message: "Virus detected (#{positives}/#{total} engines)",
                details: result["scans"]
              }
            else
              {
                clean: true,
                message: "File is clean (#{total} engines checked)"
              }
            end
          else
            # Still processing or not found
            {clean: true, message: "Scan in progress, allowing upload"}
          end
        else
          {clean: true, message: "Unable to get scan results"}
        end
      else
        {clean: true, message: "Upload to scanner failed"}
      end
    rescue => e
      Rails.logger.error "Virus scan failed: #{e.message}"
      {clean: true, message: "Scan service unavailable"}
    end
  end

  def self.scan_url(url)
    return {clean: true, message: "Virus scanning disabled"} unless Rails.env.production?

    api_key = Rails.application.credentials.virustotal_api_key
    return {clean: true, message: "No API key configured"} unless api_key

    begin
      response = post("/url/scan", {
        body: {
          apikey: api_key,
          url: url
        }
      })

      if response.success?
        {clean: true, message: "URL scan initiated"}
      else
        {clean: true, message: "URL scan failed"}
      end
    rescue => e
      Rails.logger.error "URL virus scan failed: #{e.message}"
      {clean: true, message: "URL scan service unavailable"}
    end
  end
end
