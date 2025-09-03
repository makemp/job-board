# monthly job alert filter works only if monthly parameter is passed
# weekly job alert filter works only if weekly parameter is passed or monthly parameter is passed
# daily job alert filter works any time
module JobAlerts
  class FetchDataService
    # frequency can be :daily, :weekly, :monthly
    def self.call(frequency)
      new(frequency).call
    end

    def initialize(frequency)
      @frequency = frequency
    end

    def call
      result_job_offers = {}
      job_alert_filters.each do |job_alert_id, filters|
        next if job_alert_id.blank? || filters.blank?
        result_job_offers[job_alert_id] = []
        filters.each do |filter|
          next unless proceed_with_filter_frequency?(filter)

          selector = ->(job_offer, filter_) do
            job_offer.recent_action.created_at >= frequency_to_time(filter_.frequency) &&
              job_offer.matches_category?(filter_.category) &&
              job_offer.region == filter_.region
          end
          result_job_offers[job_alert_id] += job_offers.select { selector.call(it, filter) }
        end
      end
      result_job_offers
    end

    private

    def proceed_with_filter_frequency?(filter)
      case filter.frequency.to_sym
      when :daily
        true # daily job alert filter works any time
      when :weekly
        %i[weekly monthly].include?(frequency.to_sym) # weekly filter works if weekly or monthly parameter is passed
      when :monthly
        frequency.to_sym == :monthly # monthly filter works only if monthly parameter is passed
      else
        false
      end
    end

    def frequency_to_time(frequency_)
      case frequency_.to_sym
      when :daily
        25.hours.ago
      when :weekly
        (7 * 24 + 1).hours.ago
      when :monthly
        1.month.ago
      else
        Rails.logger.warn "Unrecognised frequency: #{frequency_}"
        1.month.ago
      end
    end

    def job_offers
      @job_offers ||= JobOffer.valid_recent
    end

    def job_alert_filters
      @job_alert_filters ||= JobAlertFilter.eager_load(:job_alert)
        .where(job_alert_filters: {enabled: true})
        .where.not(job_alerts: {confirmed_at: nil}).group_by { it&.job_alert&.id }
    end

    attr_reader :frequency
  end
end
