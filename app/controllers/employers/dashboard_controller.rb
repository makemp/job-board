module Employers
  class DashboardController < ApplicationController
    before_action :authenticate_employer!

    def index
      # dashboard landing
    end
  end
end

