class JobsController < ApplicationController
  def index
    @jobs = Job.valid
  end
end
