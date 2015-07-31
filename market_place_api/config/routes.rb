require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users
  namespace :api, defaults: { format: :json},
            path: '/api' do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, :only => [:show, :create, :update, :destroy] do
        resources :orders, :only => [:index, :show]
      end

      resources :sessions, :only => [:create]
      delete '/sessions/:auth_token', to: 'sessions#destroy'

      resources :products, :only => [:show, :index, :create, :update, :destroy]
      resources :orders, :only => [:create]
    end
  end
end
