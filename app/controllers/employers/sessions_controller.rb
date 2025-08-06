class Employers::SessionsController < Devise::SessionsController
  def create
    email = params[:employer][:email]
    password = params[:employer][:password]
    remember_me = params[:employer][:remember_me] == "1"

    @employer = Employer.find_by(email: email)

    if @employer&.valid_password?(password)
      sign_in(:employer, @employer, remember_me: remember_me)

      # Use turbo_stream to navigate to dashboard
      render turbo_stream: turbo_stream.replace("login_form", "<script>window.location.href = '#{after_sign_in_path_for(@employer)}';</script>")
    else
      flash.now[:alert] = "Invalid email or password"
      render turbo_stream: [
        turbo_stream.update("login_form", partial: "password_form", locals: {email: email}),
        turbo_stream.update("flash", partial: "layouts/flash")
      ], status: :unprocessable_entity
    end
  end

  # POST /employers/process_email
  def process_email
    email = params[:employer][:email]
    @employer = Employer.find_by(email: email)

    if @employer
      if @employer.encrypted_password.present?
        # Render password form
        render turbo_stream: turbo_stream.update("login_form", partial: "password_form", locals: {email: email})
      else
        # Send login code and render code form
        send_login_code(@employer)
        render turbo_stream: turbo_stream.update("login_form", partial: "code_form", locals: {email: email})
      end
    else
      # To prevent email enumeration, render code form even if email doesn't exist
      render turbo_stream: turbo_stream.update("login_form", partial: "code_form", locals: {email: email})
    end
  end

  # POST /employers/verify_code
  def verify_code
    email = params[:employer][:email]
    remember_me = params[:employer][:remember_me] == "1"
    @employer = Employer.find_by(email: email)

    if @employer && @employer.login_code == params[:employer][:code] && @employer.login_code_sent_at > 10.minutes.ago
      sign_in(:employer, @employer, remember_me: remember_me)

      # Use turbo_stream to navigate to dashboard
      render turbo_stream: turbo_stream.replace("login_form", "<script>window.location.href = '#{after_sign_in_path_for(@employer)}';</script>")
    else
      flash[:alert] = "Invalid or expired code"
      render turbo_stream: [
        turbo_stream.update("login_form", partial: "code_form", locals: {email: email}),
        turbo_stream.update("flash", partial: "layouts/flash")
      ], status: :unprocessable_entity
    end
  end

  # POST /employers/forgot_password
  def forgot_password
    email = params[:employer][:email]
    @employer = Employer.find_by(email: email)

    if @employer
      send_login_code(@employer)
    end

    # Always render code form to prevent email enumeration
    render turbo_stream: turbo_stream.update("login_form", partial: "code_form", locals: {email: email})
  end

  private

  def send_login_code(employer)
    code = rand.to_s[2..8] # generate 7-digit code
    employer.update(login_code: code, login_code_sent_at: Time.current)
    EmployerLoginCodeMailer.send_code(employer).deliver_later
  end

  protected

  def after_sign_in_path_for(resource)
    employers_dashboard_path
  end
end
