class PlaceFreeOrder
  include Interactor::Organizer

  organize PlaceFreeOrder::CreateOrFindEmployer,
    PlaceFreeOrder::CreateJobOffer,
    PlaceFreeOrder::CreateOrderPlacement,
    PlaceFreeOrder::ApplyVoucher,
    PlaceFreeOrder::DetermineCustomerRoute
end
