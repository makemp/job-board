namespace :db do
  namespace :seeds do
    desc "Seed data for development environment"
    task dev: :environment do
      load Rails.root.join("db", "seeds", "dev.rb")
    end
  end
end
