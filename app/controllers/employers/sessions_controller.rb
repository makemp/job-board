class Employers::SessionsController < Devise::SessionsController
  # GET /employers/sign_in
  def new
    super
  end

  # POST /employers/login_code
  def send_code
    employer = Employer.find_by(email: params[:email])
    if employer
      code = rand.to_s[2..6] # generate 5-digit code
      employer.update(login_code: code, login_code_sent_at: Time.current)
      EmployerLoginCodeMailer.send_code(employer).deliver_later
    end
    redirect_to verify_code_employers_path(email: params[:email])
  end

  # GET and POST /employers/verify_code
  def verify_code
    if request.post?
      employer = Employer.find_by(email: params[:email])
      if employer && employer.login_code == params[:code] && employer.login_code_sent_at > 10.minutes.ago
        sign_in(:employer, employer)
        redirect_to after_sign_in_path_for(employer)
      else
        flash.now[:alert] = "Invalid or expired code"
        render :verify_code
      end
    else
      render :verify_code
    end
  end

  protected

  def after_sign_in_path_for(resource)
    employers_dashboard_path
  end
end
