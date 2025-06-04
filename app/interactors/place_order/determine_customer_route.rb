class PlaceOrder
  class DetermineCustomerRoute
    include Interactor
    include Rails.application.routes.url_helpers

    def call
      if context.is_new_employer && context.order_placement.free?
        context.redirect_path = first_confirmation_email_sent_path(free_order: context.order_placement.free?,
          needs_approval: !context.job_offer.approved?)
        Registrations::SendConfirmationEmailService.call!(context.info.email)
      elsif context.order_placement.free?
        context.redirect_path = job_offer_path(context.job_offer,
          flash_notice: "Your job offer is now visible",
          success: true)
      else
        session = Stripe::CheckoutSessionService.call(order_placement: context.order_placement)
        context.redirect_path = session.url
      end
    end
  end
end
