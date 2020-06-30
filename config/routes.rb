Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get 'users/index1', to: 'users#index1'

  resources :users do
    collection { post :import }
    
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'edit_overtime_request'
      post 'update_overtime_request'
    end
    resources :attendances, only: :update do
      member do
        get 'edit_overtime_request'
        post 'update_overtime_request'
      end
    end
  end
  resources :offices
end