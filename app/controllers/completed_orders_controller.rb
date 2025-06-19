class CompletedOrdersController < ApplicationController
  def show
    @order_placement = OrderPlacement.where.not(session_token: nil)
      .find_by(id: params[:id],
        session_token:  params[:session_token])
    return redirect_to root_path unless @order_placement

    @order_placement.update!(session_token: nil)
    sign_in(@order_placement.employer)
  end
end
