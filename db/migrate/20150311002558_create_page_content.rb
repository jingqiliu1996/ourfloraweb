class CreatePageContent < ActiveRecord::Migration
  def change
    create_table :page_contents do |t|
      t.text :about_page_content
      t.timestamps null: false
    end

    # Create a single row for the about page content
    PageContent.create!(:about_page_content => 'OurFlora is an extension of the CampusFlora project. OurFlora allows institutions, organisations and community groups to offer vegetation maps to showcase the diversity of botanical life growing around them. Both OurFlora and CampusFlora are lead by A/Prof Rosanne Quinnell, School of Life and Environmental Sciences, The University of Sydney.

    IT development of OurFlora was undertaken by Faculty of Engineering students (Jingqi Liu, Xiaoqun Zhao, Zijing Zhang, Zeyu Wang, Jinyuan Liu) at The University of Sydney as part of their capstone unit using the students-as-partners approach and supervised by University of Sydney ICT staff (Daniel Burn, Erica Bista).
    
    Licence: OurFlora is offered under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.')
  end
end
