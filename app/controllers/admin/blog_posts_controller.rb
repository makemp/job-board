class Admin::BlogPostsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy]

  def index
    @blog_posts = BlogPost.all.recent
  end

  def show
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)

    if @blog_post.save
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Blog post was successfully deleted."
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find_by_slug(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :body, :published)
  end
end
