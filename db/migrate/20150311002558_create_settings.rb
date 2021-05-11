class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :about_page_content
      t.timestamps null: false
    end

    # Create a single row for the about page content
    Settings.create!(:about_page_content => 'Test Content')
  end
end 
