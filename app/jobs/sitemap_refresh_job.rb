class SitemapRefreshJob < ApplicationJob
  queue_as :default

  def perform
    # Ensure Rake tasks are loaded
    Rails.application.load_tasks

    # Invoke the specific task
    Rake::Task["sitemap:refresh:no_ping"].invoke
  end
end
