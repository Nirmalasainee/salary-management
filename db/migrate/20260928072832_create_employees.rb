class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :employee_number, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.references :country, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :job_level, null: false, foreign_key: true
      t.references :manager, foreign_key: { to_table: :employees }
      t.date :hire_date, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :employees, :employee_number, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, [:department_id, :status]
    add_index :employees, [:country_id, :status]
  end
end
