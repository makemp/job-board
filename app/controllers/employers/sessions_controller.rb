class Employers::SessionsController < Devise::SessionsController
  # GET /employers/sign_in
  def new
    super
  end

  # POST /employers/process_email
  def process_email
    email = params[:employer][:email]
    @employer = Employer.find_by(email: email)

    if @employer
      if @employer.encrypted_password.present?
        # Render password form
        render turbo_stream: turbo_stream.replace("login_form", partial: "password_form", locals: {email: email})
      else
        # Send login code and render code form
        send_login_code(@employer)
        render turbo_stream: turbo_stream.replace("login_form", partial: "code_form", locals: {email: email})
      end
    else
      # To prevent email enumeration, render code form even if email doesn't exist
      render turbo_stream: turbo_stream.replace("login_form", partial: "code_form", locals: {email: email})
    end
  end

  # POST /employers/verify_code
  def verify_code
    email = params[:employer][:email]
    @employer = Employer.find_by(email: email)

    if @employer && @employer.login_code == params[:employer][:code] && @employer.login_code_sent_at > 10.minutes.ago
      sign_in(:employer, @employer)
      redirect_to after_sign_in_path_for(@employer)
    else
      flash.now[:alert] = "Invalid or expired code"
      render turbo_stream: turbo_stream.replace("login_form", partial: "code_form", locals: {email: email}), status: :unprocessable_entity
    end
  end

  private

  def send_login_code(employer)
    code = rand.to_s[2..6] # generate 5-digit code
    employer.update(login_code: code, login_code_sent_at: Time.current)
    EmployerLoginCodeMailer.send_code(employer).deliver_later
  end

  protected

  def after_sign_in_path_for(resource)
    employers_dashboard_path
  end
end
