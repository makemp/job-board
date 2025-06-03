class PlaceOrder
  include Interactor::Organizer

  organize PlaceOrder::CreateOrFindEmployer,
    PlaceOrder::CreateJobOffer,
    PlaceOrder::CreateOrderPlacement,
    PlaceOrder::ApplyVoucher,
    PlaceOrder::DetermineCustomerRoute
end
