class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.string :name
      t.timestamps default:Time.now, null: false
    end
  end
end