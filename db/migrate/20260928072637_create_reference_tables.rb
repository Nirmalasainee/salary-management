class CreateReferenceTables < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :currency_code, null: false, limit: 3
      t.timestamps
    end
    add_index :countries, :name, unique: true

    create_table :departments do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :departments, :name, unique: true

    create_table :job_levels do |t|
      t.string :name, null: false
      t.integer :rank, null: false
      t.timestamps
    end
    add_index :job_levels, :rank, unique: true
  end
end
