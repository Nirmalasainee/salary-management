module Api
  module V1
    class SalaryRecordsController < ApplicationController
      def create
        employee = Employee.find(params[:employee_id])
        effective_start_date = Date.parse(salary_record_params[:effective_start_date])

        result = SalaryChangeService.new(
          employee: employee,
          amount: salary_record_params[:amount],
          currency_code: salary_record_params[:currency_code],
          effective_start_date: effective_start_date,
          change_reason: salary_record_params[:change_reason]
        ).call

        if result.success?
          render json: salary_json(result.salary_record), status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      rescue ArgumentError, TypeError
        render json: { errors: ["effective_start_date is not a valid date"] }, status: :unprocessable_entity
      end

      private

      def salary_record_params
        params.require(:salary_record).permit(:amount, :currency_code, :effective_start_date, :change_reason)
      end

      def salary_json(salary)
        {
          id: salary.id,
          amount: salary.amount,
          currency_code: salary.currency_code,
          effective_start_date: salary.effective_start_date,
          effective_end_date: salary.effective_end_date,
          change_reason: salary.change_reason
        }
      end
    end
  end
end
