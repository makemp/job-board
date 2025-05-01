class PlaceFreeOrder
  include Interactor::Organizer

  organize PlaceFreeOrder::CreateOrFindEmployer, PlaceFreeOrder::CreateJobOffer, PlaceFreeOrder::AssignVoucher
end
