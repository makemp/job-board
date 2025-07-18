class Admin::StagingTokensController < ApplicationController
  before_action :authenticate_admin!

  def create
    token = SecureRandom.hex(32)
    StagingToken.create!(value: token)
    render plain: token
  end

  def destroy
    StagingToken.find_by(value: params[:token]).destroy!
    render plain: "Staging token removed"
  end
end
