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
require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
