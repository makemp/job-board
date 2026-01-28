class Admin::ExternalJobOffersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_external_job_offer, only: [:approve, :hide]

  def index
    @external_job_offers = ExternalJobOffer.in_pending_queue
  end

  def approve
    # Fix: Use the has_one :order_placement association which is correctly ordered
    order_placement = @external_job_offer.order_placement
    if order_placement
      order_placement.update!(paid_on: Time.current)
      flash[:notice] = "Job offer '#{@external_job_offer.title}' approved successfully"
    else
      flash[:alert] = "No order placement found for this job offer"
    end

    respond_to do |format|
      format.html { redirect_to admin_dashboard_path, notice: flash[:notice] }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@external_job_offer) }
    end
  end

  def hide
    @external_job_offer.hide!

    respond_to do |format|
      format.html { redirect_to admin_dashboard_path, notice: "Job offer hidden successfully" }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@external_job_offer) }
    end
  end

  private

  def set_external_job_offer
    raw_id = params[:id]
    @external_job_offer = ExternalJobOffer.find_by(id: raw_id)
    @external_job_offer ||= ExternalJobOffer.find_by!(slug: raw_id)
  end
end
