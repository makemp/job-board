class PlaceOrder
  class CreateOrderPlacement
    include Interactor

    def call
      # context.order_placement = job_offer.create_order_placement!(price: price, free_order: true, voucher_code: code)
      context.order_placement = job_offer.create_order_placement!(job_offer_form_params: context.info)
    end

    delegate "voucher", to: :"context.info"
    delegate :job_offer, to: :context
    delegate :code, :price, to: :voucher
  end
end
