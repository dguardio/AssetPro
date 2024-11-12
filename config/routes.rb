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
  resources :assets do
    resources :maintenance_records
    resources :rfid_tags, only: [:new, :create]
    resources :asset_tracking_events, only: [:index]
  end
  resources :asset_assignments
  resources :locations
  resources :categories
  
  root 'dashboards#index'
  
  # API endpoint for RFID scanning
  post '/scan', to: 'asset_tracking_events#create'
  
  get 'scanner', to: 'scanner_interface#scan'
  get 'scanner_interface/recent_scans', to: 'scanner_interface#recent_scans'
  
  # Keep the existing dashboard route
  get 'dashboard', to: 'dashboards#index'
  get 'dashboard/drilldown', to: 'dashboards#drilldown', as: :drilldown_dashboard
  
  # Add the export routes
  get 'dashboards/export', to: 'dashboards#export', as: :export_dashboard
end
