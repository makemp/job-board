class JobsController < ApplicationController
  def index
    @jobs = Job.valid.includes(:employer)
  end
end
