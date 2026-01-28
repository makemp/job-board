class JobOfferDirsController < ApplicationController
  def index
    @job_offers = JobOffer.for_index.sorted
  end
end
