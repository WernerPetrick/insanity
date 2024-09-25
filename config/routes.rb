Rails.application.routes.draw do
  
  resources :sanity_posts

 
  root "sanity_posts#index"
end
