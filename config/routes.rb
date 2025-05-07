Rails.application.routes.draw do
  devise_for :employers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "job_offers#index"
  resources :job_offers, only: %i[index show]
  resource :job_offer_forms, only: %i[new create] do
    patch :update, on: :collection
  end
  namespace :employers do
    resources :job_offers
  end

  resources :first_orders, only: %i[index]

  resources :next_orders, only: %i[index create]

  get "/email_confirmed", to: "email_confirmations#email_confirmed", as: :email_confirmed
  get "/confirm_email", to: "email_confirmations#confirm_email", as: :confirm_email
  post "/confirm/resend", to: "email_confirmations#resend_confirmation_email", as: :resend_confirmation_email
end
