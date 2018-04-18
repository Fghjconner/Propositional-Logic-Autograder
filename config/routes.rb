Rails.application.routes.draw do

  get 'quiz', to: 'static#quiz'

  get 'home', to: 'static#home'
  get 'help', to: 'static#help' 

  get 'about', to: 'static#about' 

  get 'contact', to: 'static#contact' 

    root 'static#home'
    
    get 'verifier', to: 'verifier#index'
    get 'verify', to: 'verifier#show'
    # resources :verifier, only:[:index, :show]
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
