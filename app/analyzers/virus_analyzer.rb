class VirusAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    # Scan all uploaded files
    true
  end

  def metadata
    download_blob_to_tempfile do |file|
      scan_result = VirusScanService.scan_file(file.path)

      {
        virus_scan: {
          clean: scan_result[:clean],
          message: scan_result[:message],
          scanned_at: Time.current,
          details: scan_result[:details]
        }
      }
    end
  rescue => e
    Rails.logger.error "Virus scan analyzer failed: #{e.message}"
    {
      virus_scan: {
        clean: true,
        message: "Scan failed: #{e.message}",
        scanned_at: Time.current,
        error: true
      }
    }
  end
end
