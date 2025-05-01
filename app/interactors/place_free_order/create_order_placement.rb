class PlaceFreeOrder
  class CreateOrderPlacement
    include Interactor

    def call
      job_offer.order_placement.create!(price: price, free_order: true)
    end

    private

    def price
      voucher&.price || Voucher.default_price
    end
    delegate "voucher", to: :"context.info"
    delegate :job_offer, to: :context
  end
end
