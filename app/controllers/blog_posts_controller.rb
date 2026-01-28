class BlogPostsController < ApplicationController
  before_action :set_blog_post, only: [:show]

  def index
    ahoy.track "Viewed Blog Posts Index"
    @blog_posts = BlogPost.published.recent
  end

  def show
    ahoy.track "Viewed Blog Post", title: @blog_post.title
  end

  private

  def set_blog_post
    @blog_post = BlogPost.published.find_by_slug(params[:id])
    unless @blog_post
      redirect_to blog_posts_path, alert: "Blog post not found."
    end
  end
end
