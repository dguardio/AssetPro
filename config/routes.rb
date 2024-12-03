require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  
  # Admin namespace for user management
  namespace :admin do
    resources :users
  end

  namespace :api do
    namespace :v1 do
      resources :assets do
        member do
          post :check_out
          post :check_in
          get :history
        end
      end
      resources :categories
      resources :locations
      resources :asset_assignments
      resources :maintenance_records
      post '/scans', to: 'scans#create'
    end
  end
  resources :users
  resources :roles
  namespace :inventory do
    resources :assets do
      resources :maintenance_records
      resources :rfid_tags, only: [:new, :create]
      resources :asset_tracking_events, only: [:index]
      collection do
        post :import
        get :export
        get :download_template
      end
    end
  end
  resources :asset_assignments
  resources :locations
  resources :categories
  
  root 'dashboards#index'
  
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
    member do
      post :complete
    end
  end
  resources :licenses
  resources :asset_tracking_events, only: [:index, :show]
end
