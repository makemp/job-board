module ApplicationHelper
  def error_messages_for(form, field, classes: "mt-1 text-sm text-red-600")
    return unless form.object.errors[field].any?

    raw(form.object
            .errors
            .full_messages_for(field)
            .map { |msg| content_tag(:p, msg.html_safe, class: classes) }
            .join)
  end
end
