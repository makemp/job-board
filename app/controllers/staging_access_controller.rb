class StagingAccessController < ApplicationController
  skip_before_action :check_staging_access, only: [:create]

  def create
    token = params[:token].to_s
    if StagingToken.exists?(value: token)
      cookies[:staging_access] = {value: token, expires: 30.days.from_now, httponly: true}
      redirect_to "/"
    else
      render plain: "Invalid token.", status: :unauthorized
    end
  end
end
