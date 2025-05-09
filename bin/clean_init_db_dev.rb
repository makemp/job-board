#!/usr/bin/env ruby
APP_PATH = File.expand_path("../config/application", __dir__)
require_relative "../config/boot"
require "rails"
require APP_PATH

return unless Rails.env.development?
`rm db/schema.rb` if File.exist?("db/schema.rb")
`rails db:drop`
`rails db:setup`
`rails db:migrate`
`rails db:migrate`
`rails db:reset`
`rails db:seeds:dev`
