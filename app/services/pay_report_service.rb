class PayReportService
  GroupStats = Struct.new(:key, :label, :headcount, :total_usd, :average_usd, :median_usd, keyword_init: true)

  def initialize(scope: Employee.active)
    @scope = scope
  end

  def summary
    amounts_usd = current_salary_rows.map { |row| to_usd(row[:amount], row[:currency_code]) }

    {
      headcount: amounts_usd.size,
      total_payroll_usd: amounts_usd.sum.round(2),
      average_salary_usd: average(amounts_usd),
      median_salary_usd: median(amounts_usd)
    }
  end

  def by_department
    group_by(:department_id, :department_name)
  end

  def by_country
    group_by(:country_id, :country_name)
  end

  def by_job_level
    group_by(:job_level_id, :job_level_name)
  end

  private

  def group_by(id_key, label_key)
    current_salary_rows.group_by { |row| [row[id_key], row[label_key]] }.map do |(id, label), rows|
      amounts_usd = rows.map { |row| to_usd(row[:amount], row[:currency_code]) }

      GroupStats.new(
        key: id,
        label: label,
        headcount: rows.size,
        total_usd: amounts_usd.sum.round(2),
        average_usd: average(amounts_usd),
        median_usd: median(amounts_usd)
      )
    end.sort_by { |g| -g.headcount }
  end

  def current_salary_rows
    @current_salary_rows ||= @scope
      .joins(:salary_records, :department, :country, :job_level)
      .merge(SalaryRecord.current)
      .pluck(
        "salary_records.amount", "salary_records.currency_code",
        "departments.id", "departments.name",
        "countries.id", "countries.name",
        "job_levels.id", "job_levels.name"
      )
      .map do |amount, currency_code, dept_id, dept_name, country_id, country_name, level_id, level_name|
        {
          amount: amount, currency_code: currency_code,
          department_id: dept_id, department_name: dept_name,
          country_id: country_id, country_name: country_name,
          job_level_id: level_id, job_level_name: level_name
        }
      end
  end

  def to_usd(amount, currency_code)
    amount.to_f * fx_rates.fetch(currency_code, 1.0)
  end

  def fx_rates
    @fx_rates ||= FxSnapshot.order(as_of_date: :asc)
      .each_with_object({}) { |snap, h| h[snap.currency_code] = snap.rate_to_usd.to_f }
  end

  def average(values)
    return 0.0 if values.empty?

    (values.sum / values.size).round(2)
  end

  def median(values)
    return 0.0 if values.empty?

    sorted = values.sort
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid].round(2) : ((sorted[mid - 1] + sorted[mid]) / 2.0).round(2)
  end
end
