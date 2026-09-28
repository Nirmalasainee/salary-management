Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :employees, only: [:index, :show, :create, :update] do
        resources :salary_records, only: [:create]
      end
    end
  end
end

