CycMapping::Application.routes.draw do
  resources :cyc_concepts

  resource :concepts do
    resources :spellings
  end

  resources :spellings
  resources :super_types, :only => [:index, :show]

  devise_for :users

  root :to => "cyc_concepts#index"

  match ':controller(/:action(/:id))'
end
