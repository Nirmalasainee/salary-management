class CreateSalaryRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :salary_records do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :amount, null: false, precision: 12, scale: 2
      t.string :currency_code, null: false, limit: 3
      t.date :effective_start_date, null: false
      t.date :effective_end_date
      t.integer :change_reason, null: false, default: 0
      t.timestamps
    end

    add_index :salary_records, [:employee_id, :effective_start_date]
    # Enforces the versioning invariant at the DB level: at most one
    # "current" (open-ended) salary record per employee.
    add_index :salary_records, :employee_id, unique: true,
      where: "effective_end_date IS NULL",
      name: "index_salary_records_on_employee_id_current"

    create_table :fx_snapshots do |t|
      t.string :currency_code, null: false, limit: 3
      t.decimal :rate_to_usd, null: false, precision: 12, scale: 6
      t.date :as_of_date, null: false
      t.timestamps
    end
    add_index :fx_snapshots, [:currency_code, :as_of_date], unique: true
  end
end
