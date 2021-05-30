class AddGenusSpeciesToImage < ActiveRecord::Migration
  def change
    add_column :images, :genusspecies, :string
    Image.all.each do |image|
      image.genusspecies = image.species.genusspecies
      image.save!
    end
  end
end
