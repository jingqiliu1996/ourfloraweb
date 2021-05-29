ActiveAdmin.register Family do
  permit_params :name, :phylogeny
  # active_admin_importable
  active_admin_import on_duplicate_key_ignore: true,
                      template_object: ActiveAdminImport::Model.new(
                        hint: "file will be imported with such header format: 'body','title','author'",
                        csv_headers: ["name"]
                    ),
                    after_import:  ->(importer){
                      Family.transaction do
                        Family.connection.execute("DELETE FROM families WHERE name IN (SELECT name FROM families GROUP BY name HAVING COUNT(name)>1)")                        
                      end
                  }
  controller do
    def index
      params[:order] = "name_asc"
      super
    end
  end
  # This defines the column order for the index page which shows the list of all families
  index do
    selectable_column
    column :name
    column :phylogeny
    column :created_at
    column :updated_at
    actions
  end
end
