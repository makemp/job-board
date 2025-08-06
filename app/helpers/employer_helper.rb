module EmployerHelper
  def current_employer_company_name
    return unless current_employer
    return unless current_employer.confirmed_at

    current_employer.company_name
  end
end
