module JobOfferHelper
  def timestamp_as_words(job)
    if job.expired?
      "Expired " + time_ago_in_words(job.expired_on) + " ago"
    elsif job.recent_action.created_at.today?
      "Added Today"
    elsif job.recent_action.created_at.yesterday?
      "Added Yesterday"
    else
      "Added " + time_ago_in_words(job.recent_action.created_at) + " ago"
    end
  end

  def job_offer_location(job)
    return job.region unless job.subregion.present?

    "#{job.region}/#{job.subregion}"
  end
end
