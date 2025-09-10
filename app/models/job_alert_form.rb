class JobAlertForm
  FREQUENCY_OPTIONS = %w[daily weekly monthly].freeze
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :email, :string

  attribute :category, :string
  attribute :region, :string
  attribute :frequency, :string

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}

  validates :frequency, inclusion: {in: FREQUENCY_OPTIONS}
  validates :region, inclusion: {in: JobOffer::REGIONS + JobOffer::HIGHLIGHTED_REGIONS}
  validates :category, inclusion: {in: JobOffer::CATEGORIES.categories_names + JobOffer::CATEGORIES.overcategories_names}

  def self.update_existing_filter(alert_attrs)
    job_alert = JobAlert.find_by(management_token: alert_attrs[:management_token])
    return nil unless job_alert&.active? # should not happen

    inst = new.tap do |form|
      form.email = job_alert.email
      form.category = alert_attrs[:category]
      form.region = alert_attrs[:region_search]
      form.frequency = alert_attrs[:frequency]
    end

    if inst.valid?
      job_alert_filter = job_alert.job_alert_filters.find(alert_attrs[:filter_id])
      return nil unless job_alert_filter # should not happen

      job_alert_filter.update!(
        category: inst.category,
        region: inst.region,
        frequency: inst.frequency
      )
    end

    inst
  end

  def self.add_new_filter(alert_attrs)
    job_alert = JobAlert.find_by(management_token: alert_attrs[:management_token])
    return nil unless job_alert&.active? # should not happen

    inst = new.tap do |form|
      form.email = job_alert.email
      form.category = alert_attrs[:category]
      form.region = alert_attrs[:region_search]
      form.frequency = alert_attrs[:frequency]
    end

    if inst.valid?
      job_alert.job_alert_filters.create!(
        category: inst.category,
        region: inst.region,
        frequency: inst.frequency,
        enabled: true
      )
    end
    inst
  end

  def self.find_by_token(token)
    JobAlertFilter.find_by(confirmation_token: token)
  end

  def self.create(params)
    inst = new.tap do |form|
      form.email = params[:email]
      alert_attrs = params[:alert_form]
      form.category = alert_attrs[:category]
      form.region = alert_attrs[:region_search]
      form.frequency = alert_attrs[:frequency]
    end

    if inst.valid?
      job_alert = nil
      JobAlert.transaction do
        JobAlertFilter.transaction do
          job_alert = JobAlert.find_or_initialize_by(email: inst.email)
          job_alert.save!

          job_alert.job_alert_filters.create!(
            category: inst.category,
            region: inst.region,
            frequency: inst.frequency,
            confirmation_token: SecureRandom.hex(16)
          )
        end

        job_alert_filter = job_alert.reload.job_alert_filters.last

        job_alert.update!(management_token: job_alert_filter.confirmation_token) if job_alert.management_token.blank?

        JobAlertMailer.confirmation_email(job_alert_filter).deliver_later
      end
    end
    inst
  end
end
