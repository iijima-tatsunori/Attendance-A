Rails.application.routes.draw do
  

  root 'static_pages#top'
  
  
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 拠点情報
  resources :bases
  
  resources :users do
    
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      
      get 'basic_edit'
      
      # 勤怠変更申請
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
      # 勤怠申請変更承認
      get 'attendances/change_apply_form'
      patch 'attendances/reply_change_apply'
      
      # 上長に１ヶ月の勤怠申請
      patch 'attendances/request_month_apply'
      
       # 申請された１ヶ月の勤怠承認画面
      get 'attendances/monthly_confirmation_form'
      patch 'attendances/apply_monthly_confirmation'
      
      get 'attendances/attendance_log'
      
      
      # 残業申請
      get 'attendances/edit_overtime_info'
      patch 'attendances/request_overtime'
      
      get 'attendances/overtime_superior_reply'
      patch 'attendances/request_overtime_reply'
    end
    
    collection do
      get :coming
      post :import
    end
    
    resources :attendances, only: :update
      
  end
  
  
    
  
  
  

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
