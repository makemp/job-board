module ApplicationHelper
  def error_messages_for(form, field, classes: "mt-1 text-sm text-red-600")
    return unless form.object.errors[field].any?

    raw(form.object
            .errors
            .full_messages_for(field)
            .map { |msg| content_tag(:p, msg.html_safe, class: classes) }
            .join)
  end

  def set_meta_tags(title: nil, description: nil, image: nil, url: nil, type: "website")
    content_for :meta_title, title || "DrillCrew - Find Your Next Drilling Job"
    content_for :meta_description, description || "Find the best drilling & mining and oil & gas job opportunities. Connect with top employers in the energy sector."
    content_for :meta_image, image || asset_url("drillcrew-logo.png")
    content_for :meta_url, url || request.original_url
    content_for :meta_type, type
  end

  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "DrillCrew - Find Your Next Drilling Job"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : "Find the best drilling and oil & gas job opportunities. Connect with top employers."
  end

  def meta_image
    content_for?(:meta_image) ? content_for(:meta_image) : asset_url("drillcrew-logo.png")
  end

  def meta_url
    content_for?(:meta_url) ? content_for(:meta_url) : request.original_url
  end

  def meta_type
    content_for?(:meta_type) ? content_for(:meta_type) : "website"
  end
end
