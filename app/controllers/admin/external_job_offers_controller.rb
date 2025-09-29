class Admin::ExternalJobOffersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @external_job_offers = ExternalJobOffer.in_pending_queue
  end

  def approve
    @external_job_offer = ExternalJobOffer.find(params[:id]).order_placement.last.update!(paid_on: Time.current)
  end

  def hide
    @external_job_offer = ExternalJobOffer.find(params[:id]).hide!
  end
end
