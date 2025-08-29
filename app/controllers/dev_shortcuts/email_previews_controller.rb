class DevShortcuts::EmailPreviewsController < ApplicationController
  def digest_email
    # Create sample job offers for the digest email
    @job_offers = create_sample_job_offers
    @job_alert = create_sample_job_alert

    render template: "job_alert_mailer/digest_email", layout: "mailer"
  end

  def confirmation_email
    # Create sample job alert filter for the confirmation email
    @job_alert_filter = create_sample_job_alert_filter
    @job_alert = @job_alert_filter.job_alert
    @confirmation_url = "http://localhost:3000/job_alerts/confirm/sample-token"
    @manage_url = "http://localhost:3000/job_alerts/manage/sample-management-token"

    render template: "job_alert_mailer/confirmation_email", layout: "mailer"
  end

  private

  def create_sample_job_offers
    # Create sample employers
    employer1 = Employer.new(
      email: "hr@drilltech.com",
      company_name: "DrillTech Solutions",
      confirmed_at: Time.current
    )

    employer2 = Employer.new(
      email: "careers@globalmining.com",
      company_name: "Global Mining Corp",
      confirmed_at: Time.current
    )

    employer3 = Employer.new(
      email: "jobs@energyinnovations.com",
      company_name: "Energy Innovations Ltd",
      confirmed_at: Time.current
    )

    return JobOffer.last(3) if JobOffer.find_by(subregion: "Norwegian Sector", application_destination: "hr@drilltech.com")

    # Create job offers with proper associations
    job_offers = [
      JobOffer.create(
        title: "Senior Drilling Engineer",
        company_name: "DrillTech Solutions",
        region: "North Sea - Offshore",
        subregion: "Norwegian Sector",
        category: "Drilling",
        offer_type: "Full-time",
        employer: employer1,
        approved: true,
        terms_and_conditions: true,
        application_type: "Form",
        application_destination: "hr@drilltech.com"
      ),
      JobOffer.create(
        title: "Mining Operations Manager",
        company_name: "Global Mining Corp",
        region: "Australia",
        subregion: "Western Australia",
        category: "Mining",
        offer_type: "Contract",
        employer: employer2,
        approved: true,
        terms_and_conditions: true,
        application_type: "Form",
        application_destination: "careers@globalmining.com"
      ),
      JobOffer.create(
        title: "Petroleum Engineer",
        company_name: "Energy Innovations Ltd",
        region: "UAE",
        subregion: "Abu Dhabi",
        category: "Petroleum",
        offer_type: "Full-time",
        employer: employer3,
        approved: true,
        terms_and_conditions: true,
        application_type: "Form",
        application_destination: "jobs@energyinnovations.com"
      )
    ]

    # Add job descriptions using ActionText
    job_offers[0].description = ActionText::RichText.new(
      body: "We are looking for an experienced Senior Drilling Engineer to join our offshore operations team. The role involves overseeing drilling operations, ensuring safety compliance, and managing drilling programs in challenging offshore environments."
    )

    job_offers[1].description = ActionText::RichText.new(
      body: "Seeking a dynamic Mining Operations Manager to oversee daily mining operations, manage teams, and ensure production targets are met while maintaining the highest safety standards."
    )

    job_offers[2].description = ActionText::RichText.new(
      body: "Join our team as a Petroleum Engineer and contribute to cutting-edge energy projects. You'll be responsible for reservoir analysis, production optimization, and field development planning."
    )

    # Create job offer actions to simulate recent_action associations
    action_times = [2.days.ago, 1.day.ago, 3.days.ago]
    action_types = ["created", "created", "extended"]

    job_offers.each_with_index do |job_offer, index|
      action = JobOfferAction.new(
        job_offer: job_offer,
        action_type: action_types[index],
        created_at: action_times[index],
        valid_till: action_times[index] + 30.days
      )

      # Manually set the recent_action association
      job_offer.association(:recent_action).target = action
      job_offer.association(:job_offer_actions).target = [action]
    end

    job_offers
  end

  def create_sample_job_alert
    OpenStruct.new(
      email: "user@example.com",
      management_token: "sample-management-token"
    )
  end

  def create_sample_job_alert_filter
    job_alert = OpenStruct.new(
      email: "user@example.com",
      management_token: "sample-management-token"
    )

    OpenStruct.new(
      category: "Drilling",
      region: "North Sea - Offshore",
      frequency: "daily",
      job_alert: job_alert,
      confirmation_token: "sample-confirmation-token"
    )
  end
end
