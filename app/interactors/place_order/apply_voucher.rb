class PlaceOrder
  class ApplyVoucher
    include Interactor

    def call
      voucher.apply(order_placement:, job_offer:)
    end

    private

    delegate :job_offer, :order_placement, to: :context
    delegate :voucher, to: :"context.info"
  end
end
