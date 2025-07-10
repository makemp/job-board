# To idea if this is needed

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_employer, :true_employer
    impersonates :employer

    def connect
      self.current_employer = find_verified_user
      reject_unauthorized_connection unless current_employer
    end

    private

    def find_verified_employer
      env["warden"].employer # for Devise
    end
  end
end
