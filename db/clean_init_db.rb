`rm db/schema.rb` if File.exist?("db/schema.rb")
`rails db:drop`
`rails db:setup`
`rails db:migrate`
`rails db:migrate`
`rails db:seed`
