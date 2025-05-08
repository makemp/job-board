class PlaceFreeOrder
  class DetermineCustomerRoute
    include Interactor
    include Rails.application.routes.url_helpers

    def call
      if context.is_new_employer
        context.redirect_path = first_confirmation_email_sent_path(free_order: context.order_placement.free?,
          needs_approval: !context.job_offer.approved?)
        Registrations::SendConfirmationEmailService.call!(context.info.email)
      else
        context.redirect_path = next_orders_path
      end
    end
  end
end
