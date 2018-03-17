Rails.application.routes.draw do
    root 'verifier#index'
    
    get 'verifier', to: 'verifier#index'
    get 'verify', to: 'verifier#show'

    resources :entries
    # resources :verifier, only:[:index, :show]
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
