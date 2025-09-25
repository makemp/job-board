class BlogPost < ApplicationRecord
  validates :title, presence: true, length: {maximum: 255}
  validates :body, presence: true

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  def body_with_youtube_embeds
    return body unless body.present?

    # More comprehensive regex to match various YouTube URL formats
    processed_body = body.dup

    # Match YouTube URLs and replace with embedded iframe
    youtube_regex = /(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})(?:\S*)/

    processed_body.gsub!(youtube_regex) do |match|
      video_id = $1
      %(
<div class="video-wrapper" style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; margin: 20px 0;">
  <iframe style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
          src="https://www.youtube.com/embed/#{video_id}"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
  </iframe>
</div>
      ).strip
    end

    processed_body.html_safe
  end

  def excerpt(limit = 150)
    text = ActionView::Base.full_sanitizer.sanitize(body)
    intro = text.split("\n").first
    # Remove HTML tags and get plain text excerpt
    intro.truncate(limit)
  end
end
