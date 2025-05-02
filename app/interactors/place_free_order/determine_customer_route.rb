class PlaceFreeOrder
  class DetermineCustomerRoute
    include Interactor
    include Rails.application.routes.url_helpers

    def call
      if context.is_new_employer
        context.redirect_path = first_orders_path
        Registrations::SendConfirmationEmailService.call!(context.info.email)
      else
        context.redirect_path = next_orders_path
      end
    end
  end
end
