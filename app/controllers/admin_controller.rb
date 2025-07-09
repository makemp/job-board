class AdminController < ApplicationController
  before_action :authenticate_admin!, except: [:login_panel, :create]

  # Ensure the admin is authenticated before accessing any action

  # dasboard
  def index
  end

  # just a panel for admin to login
  def login_panel
  end

  # login as admin
  def create
    admin = Admin.find_by(email: params[:email])
    if admin&.valid_password?(params[:password])
      session[:admin_id] = admin.id
      redirect_to admin_dashboard_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :login_panel, status: :unprocessable_entity
    end
  end

  # logout as admin
  def destroy
    session[:admin_id] = nil
    redirect_to root_path, notice: "Logged out successfully for admin panel."
  end

  private

  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id])
  end

  def authenticate_admin!
    redirect_to new_admin_session_path unless current_admin
  end
end
