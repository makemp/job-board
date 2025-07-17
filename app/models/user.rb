class User < ApplicationRecord
  encrypts :email, deterministic: true, downcase: true

  validate :password_complexity

  def password_complexity
    return if password.blank?
    unless /(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9])/.match?(password)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one special character"
    end

    unless password.size < 8
      errors.add :password, "must be at least 8 characters long"
    end
  end
end
