module Api
  module V1
    class ReferenceDataController < ApplicationController
      def index
        render json: {
          countries: Country.order(:name).select(:id, :name),
          departments: Department.order(:name).select(:id, :name),
          job_levels: JobLevel.order(:rank).select(:id, :name)
        }
      end
    end
  end
end
