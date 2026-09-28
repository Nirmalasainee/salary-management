module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        employees = Employee.includes(:country, :department, :job_level)
        employees = employees.where(department_id: params[:department_id]) if params[:department_id].present?
        employees = employees.where(country_id: params[:country_id]) if params[:country_id].present?
        employees = employees.where(job_level_id: params[:job_level_id]) if params[:job_level_id].present?
        employees = employees.where(status: params[:status]) if params[:status].present?

        if params[:search].present?
          term = "%#{params[:search]}%"
          employees = employees.where(
            "first_name LIKE :t OR last_name LIKE :t OR employee_number LIKE :t OR email LIKE :t",
            t: term
          )
        end

        employees = employees.order(:last_name, :first_name)
                              .page(params[:page])
                              .per(params[:per_page] || 25)

        render json: {
          employees: employees.map { |e| employee_json(e) },
          meta: {
            current_page: employees.current_page,
            total_pages: employees.total_pages,
            total_count: employees.total_count
          }
        }
      end

      def show
        employee = Employee.includes(:country, :department, :job_level, :salary_records).find(params[:id])
        render json: employee_detail_json(employee)
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: employee_json(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        employee = Employee.find(params[:id])
        if employee.update(employee_params)
          render json: employee_json(employee)
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :employee_number, :first_name, :last_name, :email,
          :country_id, :department_id, :job_level_id, :manager_id,
          :hire_date, :status
        )
      end

      def employee_json(employee)
        {
          id: employee.id,
          employee_number: employee.employee_number,
          first_name: employee.first_name,
          last_name: employee.last_name,
          email: employee.email,
          status: employee.status,
          hire_date: employee.hire_date,
          country: employee.country.name,
          department: employee.department.name,
          job_level: employee.job_level.name
        }
      end

      def employee_detail_json(employee)
        employee_json(employee).merge(
          manager_id: employee.manager_id,
          current_salary: salary_json(employee.current_salary),
          salary_history: employee.salary_records.order(effective_start_date: :desc).map { |s| salary_json(s) }
        )
      end

      def salary_json(salary)
        return nil unless salary

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
