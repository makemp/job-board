class BlogPostsController < ApplicationController
  before_action :set_blog_post, only: [:show]

  def index
    @blog_posts = BlogPost.published.recent
  end

  def show
  end

  private

  def set_blog_post
    @blog_post = BlogPost.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to blog_posts_path, alert: "Blog post not found."
  end
end
