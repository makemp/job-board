class OrderPlacementsController < ApplicationController
  def show
    @order_placement = OrderPlacement.find(params[:id])
  end

  def create
    # code is entered and validated
    # redirect_to 'continue_order'
  end
end
