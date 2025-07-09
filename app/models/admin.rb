class Admin < User
  normalizes :email, with: -> { it.downcase.strip }

  devise :database_authenticatable, authentication_keys: [:email]

  def password_required?
    true
  end

  def admin?
    true
  end
end
