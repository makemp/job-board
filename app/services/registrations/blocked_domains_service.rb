module Registrations
  class BlockedDomainsService
    @blocked_domains = YAML.load_file("config/blacklisted_email_domains.yml")

    def self.on_list?(email)
      return false if email.blank?
      domain = email.split("@").last
      @blocked_domains.include?(domain)
    end
  end
end
