Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :employees, only: [:index, :show, :create, :update] do
        resources :salary_records, only: [:create]
      end

      get "reports/summary", to: "reports#summary"
      get "reports/by_department", to: "reports#by_department"
      get "reports/by_country", to: "reports#by_country"
      get "reports/by_job_level", to: "reports#by_job_level"
      get "reference_data", to: "reference_data#index"

    end
  end
end
