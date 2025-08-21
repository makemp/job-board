Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  devise_for :employers, controllers: {sessions: "employers/sessions"}, skip: [:registrations, :confirmations, :unlocks]
  devise_scope :employer do
    post "employers/sessions/process_email", to: "employers/sessions#process_email"
    post "employers/sessions/verify_code", to: "employers/sessions#verify_code"
    post "employers/sessions/forgot_password", to: "employers/sessions#forgot_password"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check
  get "/contact", to: "contact#index", as: :contact
  post "/contact", to: "contact#create"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "job_offers#index"
  resources :job_offers, only: %i[index show edit update destroy] do
    post "apply_with_form", on: :member
    get "apply_with_url", on: :member
    get "apply_for_external_offer", on: :member
    get "preview", on: :member
  end
  resource :job_offer_forms, only: %i[new create] do
    patch :update, on: :collection
  end

  # Job Alerts
  resources :job_alerts, only: %i[index show new create edit update destroy] do
    resources :job_alert_filters, only: %i[create], shallow: true
  end
  get "job_alerts/confirm/:id", to: "job_alerts#confirm", as: "confirm_job_alert"
  get "job_alerts/manage/:management_token", to: "job_alerts#manage", as: "manage_job_alert"
  get "job_alerts/unsubscribe/:management_token", to: "job_alerts#unsubscribe", as: "unsubscribe_job_alert"
  # Job Alert Filter management via token
  patch "job_alert_filters/:id/toggle/:management_token", to: "job_alert_filters#toggle", as: "toggle_job_alert_filter"
  patch "job_alert_filters/:id/update/:management_token", to: "job_alert_filters#update", as: "update_job_alert_filter"
  delete "job_alert_filters/:id/delete/:management_token", to: "job_alert_filters#destroy", as: "destroy_job_alert_filter"

  namespace :employers do
    get "dashboard", to: "dashboard#index", as: :dashboard
    patch "dashboard/password", to: "dashboard#update_password", as: :update_password
    patch "dashboard/billing", to: "dashboard#update_billing", as: :update_billing
    delete "dashboard/close_account", to: "dashboard#close_account", as: :close_account
    resources :job_offers
  end

  resources :first_orders, only: %i[index]

  resources :order_placements, only: %i[show create]
  resources :completed_orders, only: %i[show]

  get "/email_confirmed", to: "email_confirmations#email_confirmed", as: :email_confirmed
  get "/first_confirmation_email_sent", to: "email_confirmations#first_confirmation_email_sent", as: :first_confirmation_email_sent
  get "/confirm_email", to: "email_confirmations#confirm_email", as: :confirm_email
  post "/confirm/resend", to: "email_confirmations#resend_confirmation_email", as: :resend_confirmation_email

  # Explicit named routes for dashboard updates (ensure correct path helpers)
  patch "/employers/dashboard/password", to: "employers/dashboard#update_password", as: :update_password_employers
  patch "/employers/dashboard/billing", to: "employers/dashboard#update_billing", as: :update_billing_employers
  patch "/employers/dashboard/details", to: "employers/dashboard#update_details", as: :update_details_employers
  delete "/employers/dashboard/close_account", to: "employers/dashboard#close_account", as: :close_account_employers

  # Stripe webhook endpoint
  post "/stripe/webhook", to: "webhooks/stripe#receive"
  get "/terms_and_conditions", to: "job_offer_forms#terms_and_conditions", as: :terms_and_conditions
  get "/privacy", to: "job_offer_forms#privacy", as: :privacy

  # Admin authentication with Devise
  devise_for :admins, path: "amdg", controllers: {
    sessions: "devise/sessions"
  }

  authenticate :admin do
    # This mounts the Blazer UI at the desired path, e.g., /admin/blazer
    mount Blazer::Engine, at: "/amdg/blazer"
  end

  namespace :admin, path: "amdg" do
    root to: "admin#index", as: :dashboard
    post "impersonate/:id", to: "admin#impersonate", as: :impersonate_employer
    delete "stop_impersonating", to: "admin#stop_impersonating", as: :stop_impersonating_employers
    resources :staging_tokens, only: [:create, :destroy], defaults: {format: :text}
    resources :external_offers, only: [:create] do
      post :check_url, on: :collection
    end
    resources :exports, only: [:index] do
      post :generate, on: :collection
    end
  end

  get "/staging_access/:token", to: "staging_access#create", as: :staging_access, constraints: {token: /[A-Za-z0-9]+/}

  if Rails.env.development?
    scope module: :dev_shortcuts do
      get "/job_offer_forms/new/dev", controller: "job_offer_forms", action: :new
    end
  end
end
