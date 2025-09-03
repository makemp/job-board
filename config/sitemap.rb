# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://drillcrew.work"

SitemapGenerator::Sitemap.create do
  add Rails.application.routes.url_helpers.root_path, priority: 1.0, changefreq: "daily"
  add "/privacy", priority: 0.7, changefreq: "monthly"
  add "/terms_and_conditions", priority: 0.7, changefreq: "monthly"
  add "/contact", priority: 0.2, changefreq: "monthly"
  add "/job_offer_forms/new", priority: 0.4, changefreq: "monthly"
  JobOffer.valid.find_each do |job_offer|
    add Rails.application.routes.url_helpers.job_offer_path(job_offer), lastmod: job_offer.updated_at, priority: 0.9, changefreq: "monthly"
  end
end
