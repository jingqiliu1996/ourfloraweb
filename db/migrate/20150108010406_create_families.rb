class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.string :name
      t.timestamps default:CURRENT_TIMESTAMP, null: false
    end
  end
end