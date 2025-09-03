module SecurityHelper
  # Validates and sanitizes URLs to prevent XSS and open redirect attacks
  def safe_url(url)
    return nil if url.blank?

    begin
      uri = URI.parse(url)
      # Only allow HTTP and HTTPS schemes
      return nil unless %w[http https].include?(uri.scheme&.downcase)

      # Prevent javascript: and data: schemes
      return nil if uri.scheme&.match?(/javascript|data/i)

      # Return the sanitized URL
      uri.to_s
    rescue URI::InvalidURIError
      nil
    end
  end

  # Validates if a URL is safe for external redirects
  def safe_redirect_url?(url)
    return false if url.blank?

    begin
      uri = URI.parse(url)
      # Only allow HTTP and HTTPS schemes
      return false unless %w[http https].include?(uri.scheme&.downcase)

      # Prevent javascript: and data: schemes
      return false if uri.scheme&.match?(/javascript|data/i)

      # Additional checks for common malicious patterns
      return false if uri.host&.match?(/localhost|127\.0\.0\.1|0\.0\.0\.0/i)

      true
    rescue URI::InvalidURIError
      false
    end
  end
end
