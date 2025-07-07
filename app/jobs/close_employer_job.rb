class CloseEmployerJob < ApplicationJob
  CloseEmployerProblemError = Class.new(StandardError)

  queue_as :default

  def perform(employer_id)
    employer = Employer.find_by(id: employer_id)

    Employer.transaction do
      JobOffer.transaction do
        OrderPlacement.transaction do
          employer.update!(closed_at: Time.now, email: nil, company_name: "")
          employer.job_offers.includes(:order_placements).each do |job_offer|
            job_offer.expire_manually!(title: "<>Closed<>", description: nil, company_name: nil)
            job_offer.order_placements.each do |order_placement|
              order_placement.update!(job_offer_form_params: {}, stripe_payload: {})
            end
          end
        end
      end
    end
  rescue => e
    raise CloseEmployerProblemError, "Employer id: #{employer_id} -> #{e.message} || #{e.backtrace.join("\n")}"
  end
end
