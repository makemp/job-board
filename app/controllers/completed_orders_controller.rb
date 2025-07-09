class CompletedOrdersController < ApplicationController
  def show
    @order_placement = OrderPlacement.where.not(session_token: nil)
      .find_by(id: params[:id],
        session_token:  params[:session_token])
    return redirect_to root_path unless @order_placement

    employer = @order_placement.employer

    # login only on the first order placement
    sign_in(employer) if employer.order_placements.size == 1
  end
end
