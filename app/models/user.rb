# == Schema Information
#
# Table name: users
#
#  id                     :ulid             not null, primary key
#  closed_at              :datetime
#  company_name           :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string
#  encrypted_password     :string
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  login_code             :string
#  login_code_sent_at     :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  type                   :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  encrypts :email, deterministic: true, downcase: true

  # Associations
  has_many :job_alerts, dependent: :destroy

  validate :password_complexity

  def password_complexity
    return if password.blank?
    unless /(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9])/.match?(password)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one special character"
    end

    if password.size < 8
      errors.add :password, "must be at least 8 characters long"
    end
  end
end
