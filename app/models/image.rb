class Image < ActiveRecord::Base
  belongs_to :species
  before_save :update_genus_species

  # Add a paperclip interpolation for species name
  Paperclip.interpolates :genusspecies do |attachment, style|
    attachment.instance.genusspecies
  end

  has_attached_file :image,
                    :styles => {
                      :medium_desktop => "250x250^ -gravity center -extent 250x250",
                      :medium_mobile => "220x220^ -gravity center -extent 220x220",
                      :thumb_retina => "100x100#",
                      :thumb => "50x50#"
                    },
                    :default_url => "/images/:style/missing.png",
                    :path => ":rails_root/public/assets/species_images/:genusspecies/:id/:style_:basename.:extension",
                    :url  => "/assets/species_images/:genusspecies/:id/:style_:basename.:extension"

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def update_genus_species
    self.genusspecies = self.species.genusspecies
  end
end