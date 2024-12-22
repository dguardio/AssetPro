require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  
  root 'pages#home'
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'

  # Admin namespace for user management
  namespace :admin do
    resources :users do
      member do
        get :status_history
      end
    end
    resources :asset_tracking_events, only: [:index] do
      get :timeline, on: :collection
    end
    resources :oauth_applications, controller: 'oauth_applications'
  end

  namespace :api do
    namespace :v1 do
      # Asset Tracking Events (including check-in/check-out)
      resources :scans, only: [:create] # For RFID scanner input
      resources :asset_tracking_events, only: [:index, :show, :create] do
        collection do
          get :timeline
        end
      end

      # Core Resources
      resources :assets do
        member do
          get :history # Shows asset tracking history
          patch :restore
        end
        collection do
          get :search
        end
      end

      # Asset Assignments
      resources :asset_assignments do
        member do
          post :check_out
          post :check_in
          patch :restore
        end
      end

      # Supporting Resources
      resources :locations, only: [:index, :show]
      resources :rfid_tags do
        member do
          patch :restore
        end
      end

      # Reporting
      get 'dashboard', to: 'dashboard#index'
      get 'reports/asset_movement', to: 'reports#asset_movement'

      # RFID Readers
      resources :rfid_readers, only: [:show, :update] do
        collection do
          post :ping
        end
      end
    end
  end

  
  resources :users
  resources :roles
  namespace :inventory do
    resources :assets do
      resources :maintenance_records
      resources :rfid_tags, only: [:new, :create] do
        member do
          patch :restore
        end
      end
      resources :asset_tracking_events, only: [:index]
      collection do
        post :import
        get :export
        get :download_template
      end
      member do
        patch :restore
      end
    end
  end
  resources :asset_assignments do
    member do
      patch :restore
    end
  end
  resources :locations
  resources :categories
  
  # root 'dashboards#index'
  
  # API endpoint for RFID scanning
  post '/scan', to: 'asset_tracking_events#create'
  
  # get 'scanner', to: 'scanner_interface#index'
  # post 'scanner/scan', to: 'scanner_interface#scan'
  # post 'scanner/bulk_scan', to: 'scanner_interface#bulk_scan'
  # patch 'scanner/update_location', to: 'scanner_interface#update_location'
  
  get 'scanner', to: 'scanner_interface#scan'
  get 'scanner/recent_scans', to: 'scanner_interface#recent_scans'

  # Keep the existing dashboard route
  get 'dashboard', to: 'dashboards#index'
  get 'dashboard/drilldown', to: 'dashboards#drilldown', as: :drilldown_dashboard
  
  # Add the export routes
  get 'dashboards/export', to: 'dashboards#export', as: :export_dashboard

  resources :audit_logs, only: [:index, :show] do
    get 'for_record/:auditable_type/:auditable_id', action: :for_record, on: :collection, as: :for_record
  end

  resources :notifications, only: [:index, :destroy] do
    collection do
      post :mark_as_read
    end
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :rfid_tags
  resources :maintenance_schedules do
    resources :maintenance_records
    member do
      post :complete
    end
  end
  resources :licenses
  resources :asset_tracking_events, only: [:index, :show]

  namespace :profile do
    get 'password/edit', to: 'passwords#edit', as: :edit_password
    patch 'password', to: 'passwords#update', as: :password
  end
  # Add this devise_scope block for profile password routes
  # devise_scope :user do
  #   get '/profile/password/edit', to: 'profile/passwords#edit', as: 'profile_edit_password'
  #   put '/profile/password', to: 'profile/passwords#update', as: 'profile_password'
  # end

  resources :dashboards do
    collection do
      get :timeline
    end
  end

  resources :rfid_readers do
    member do
      patch :toggle_active
    end
  end

  # Mount RSwag UI and API
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
