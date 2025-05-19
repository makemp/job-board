#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"

ARGV.unshift("zeitwerk:check")

APP_PATH = File.expand_path("../config/application", __dir__)
require_relative "../config/boot"
require "rails/commands"