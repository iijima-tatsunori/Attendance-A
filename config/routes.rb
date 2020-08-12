Rails.application.routes.draw do
  

  root 'static_pages#top'
  
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  #CSVのインポート
  post '/import_csv', to: 'users#import_csv'

  resources :users do
    
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
    end
    
    collection do
      get :coming
    end
    
    collection { post :import }
    resources :attendances do
      patch 'update'
      get 'edit_overtime_info'
      patch 'request_overtime'
    end
      
  end
  
  # 拠点情報
  resources :bases
    
  
  
  

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
