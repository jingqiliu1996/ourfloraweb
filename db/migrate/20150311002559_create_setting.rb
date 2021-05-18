class CreateSetting < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :name
      # t.decimal  :lat
      # t.decimal  :lon
      t.decimal :lat, {:precision=>10, :scale=>6}
      t.decimal :lon, {:precision=>10, :scale=>6}
    end

    # Create a single row for the about page content
    # Setting.create!(:about_page_content => 'Test Content')
    Setting.create!(:name => 'Ourflora', :lat => '-33.886204', :lon => '151.189005')
  end
end 
