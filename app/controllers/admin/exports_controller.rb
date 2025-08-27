class Admin::ExportsController < ApplicationController
  before_action :authenticate_admin!

  def index
  end

  def generate
    from_date = Date.parse(params[:from_date])
    to_date = Date.parse(params[:to_date])
    job_offer_type = params[:job_offer_type]
    source_type = params[:source_type]
    platform = params[:platform]
    limit = params[:limit]&.to_i || 15

    job_offers = fetch_job_offers(from_date, to_date, job_offer_type, source_type, limit)
    markdown_content = generate_markdown(job_offers, platform)

    render json: {markdown: markdown_content}
  rescue Date::Error
    render json: {error: "Invalid date format"}, status: 422
  rescue
    render json: {error: "An error occurred while generating the export"}, status: 500
  end

  private

  def fetch_job_offers(from_date, to_date, job_offer_type, source_type, limit)
    # Start with the base scope depending on source type
    scope = case source_type
    when "JobOffer"
      JobOffer.where(type: nil) # Regular JobOffers have type: nil
    when "ExternalJobOffer"
      ExternalJobOffer.all
    else
      JobOffer.all # This includes both JobOffer and ExternalJobOffer
    end

    scope = scope.includes(:employer)
      .where(created_at: from_date.beginning_of_day..to_date.end_of_day)
      .where(expired_on: nil) # Only get non-expired offers
      .order(:created_at)

    scope = if job_offer_type == "Drilling/Mining"
      scope.where(offer_type: %w[Mining Drilling Drilling/Mining])
    elsif job_offer_type == "Other"
      scope.where(offer_type: "Other")
    elsif job_offer_type == "Mining"
      scope.where(offer_type: %w[Mining Drilling/Mining])
    elsif job_offer_type == "Drilling"
      scope.where(offer_type: %w[Drilling Drilling/Mining])
    else
      scope
    end

    scope.limit(limit)
  end

  def generate_markdown(job_offers, platform)
    case platform
    when "X/Twitter"
      generate_twitter_markdown(job_offers)
    when "Reddit"
      generate_reddit_markdown(job_offers)
    when "Linkedin"
      generate_linkedin_markdown(job_offers)
    when "Facebook"
      generate_facebook_markdown(job_offers)
    else
      generate_generic_markdown(job_offers)
    end
  end

  def generate_twitter_markdown(job_offers)
    content = "🔥 Latest Job Opportunities in Mining & Drilling 🔥\n\n"

    job_offers.each do |offer|
      content += "🏢 #{offer.the_company_name}\n"
      content += "📋 #{offer.title}\n"
      content += "🌍 #{offer.region}"
      content += " - #{offer.subregion}" if offer.respond_to?(:subregion) && offer.subregion.present?
      content += "\n"
      content += "🔗 [Apply Now](#{the_job_offer_url(offer)})\n\n"
    end

    content += "#Mining #Drilling #Jobs #Career"
    content
  end

  def generate_reddit_markdown(job_offers)
    content = "# Latest Job Opportunities in Mining & Drilling\n\n"
    content += "| Company | Position | Location | Type | Apply |\n"
    content += "|---------|----------|----------|------|-------|\n"

    job_offers.each do |offer|
      location = offer.region.to_s
      location += " - #{offer.subregion}" if offer.respond_to?(:subregion) && offer.subregion.present?
      offer_type = offer.respond_to?(:offer_type) ? offer.offer_type : "N/A"
      offer_type ||= "N/A"

      content += "| #{offer.the_company_name} | #{offer.title} | #{location} | #{offer_type} | [Apply](#{the_job_offer_url(offer)}) |\n"
    end

    content
  end

  def generate_linkedin_markdown(job_offers)
    content = "🎯 Exciting opportunities in Mining & Drilling industry!\n\n"

    job_offers.each_with_index do |offer, index|
      content += "#{index + 1}. **#{offer.title}** at **#{offer.the_company_name}**\n"
      content += "   📍 Location: #{offer.region}"
      content += " - #{offer.subregion}" if offer.respond_to?(:subregion) && offer.subregion.present?
      content += "\n"
      content += "   🔗 Apply: #{the_job_offer_url(offer)}\n\n"
    end

    content += "Follow us for more opportunities! #Mining #Drilling #Jobs #Career #Opportunities"
    content
  end

  def generate_facebook_markdown(job_offers)
    content = "🚀 New Job Opportunities Available! 🚀\n\n"
    content += "Check out these amazing positions in the Mining & Drilling industry:\n\n"

    job_offers.each do |offer|
      content += "🏢 **#{offer.the_company_name}**\n"
      content += "📋 Position: #{offer.title}\n"
      content += "🌍 Location: #{offer.region}"
      content += " - #{offer.subregion}" if offer.respond_to?(:subregion) && offer.subregion.present?
      content += "\n"
      offer_type = offer.respond_to?(:offer_type) ? offer.offer_type : "N/A"
      offer_type ||= "N/A"
      content += "💼 Type: #{offer_type}\n"
      content += "🔗 Apply Now: #{the_job_offer_url(offer)}\n\n"
      content += "---\n\n"
    end

    content += "👍 Like and Share to help others find these opportunities!\n"
    content += "#Jobs #Mining #Drilling #Career #Opportunities"
    content
  end

  def generate_generic_markdown(job_offers)
    content = "# Job Opportunities Export\n\n"
    content += "**Export Date:** #{Date.current.strftime("%B %d, %Y")}\n"
    content += "**Total Offers:** #{job_offers.count}\n\n"

    job_offers.each do |offer|
      content += "## #{offer.title}\n"
      content += "**Company:** #{offer.the_company_name}\n"
      content += "**Location:** #{offer.region}"
      content += " - #{offer.subregion}" if offer.respond_to?(:subregion) && offer.subregion.present?
      content += "\n"
      content += "**Category:** #{offer.category}\n"
      offer_type = offer.respond_to?(:offer_type) ? offer.offer_type : "N/A"
      offer_type ||= "N/A"
      content += "**Type:** #{offer_type}\n"
      content += "**Created:** #{offer.created_at.strftime("%B %d, %Y")}\n"
      content += "**Apply:** #{the_job_offer_url(offer)}\n\n"
      content += "---\n\n"
    end

    content
  end

  # rubocop:disable Style/ClassEqualityComparison
  def the_job_offer_url(offer)
    return Rails.application.routes.url_helpers.job_offer_url(offer, host: request.host_with_port) if offer.class == JobOffer
    return Rails.application.routes.url_helpers.job_offer_url(offer, host: request.host_with_port) if offer.application_type == JobOffer::APPLICATION_TYPE_FORM
    offer.application_destination
  end
  # rubocop:enable Style/ClassEqualityComparison
end
