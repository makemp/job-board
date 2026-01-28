# == Schema Information
#
# Table name: blog_posts
#
#  id         :integer          not null, primary key
#  body       :text
#  published  :boolean
#  slug       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_blog_posts_on_slug  (slug) UNIQUE
#
class BlogPost < ApplicationRecord
  include Sluggi::Slugged

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
      @youtube_video = %(
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
    body_with_youtube_embeds
    text = ActionView::Base.full_sanitizer.sanitize(body)
    intro = text.split("\n").first
    # Remove HTML tags and get plain text excerpt
    text_ = intro.truncate(limit)
    @youtube_video ? "#{text_} #{@youtube_video}".html_safe : text_
  end

  def slug_candidates
    [title, "#{title}-#{Time.current.to_i}"]
  end

  def slug_value_changed?
    title_changed?
  end
end
