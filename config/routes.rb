Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users do
    resources :savings_deposits
  end
  get 'users/:id/generate_revenue_report', to: 'users#generate_revenue_report'
  post 'authenticate', to: 'authentication#authenticate'
  resources :account_activations, only: [:edit]
end
