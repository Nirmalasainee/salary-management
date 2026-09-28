module Api
  module V1
    class ReportsController < ApplicationController
      def summary
        render json: PayReportService.new.summary
      end

      def by_department
        render json: group_json(PayReportService.new.by_department)
      end

      def by_country
        render json: group_json(PayReportService.new.by_country)
      end

      def by_job_level
        render json: group_json(PayReportService.new.by_job_level)
      end

      private

      def group_json(groups)
        groups.map do |g|
          {
            id: g.key,
            label: g.label,
            headcount: g.headcount,
            total_payroll_usd: g.total_usd,
            average_salary_usd: g.average_usd,
            median_salary_usd: g.median_usd
          }
        end
      end
    end
  end
end
