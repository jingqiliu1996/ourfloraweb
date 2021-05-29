ActiveAdmin.register Family do
  permit_params :name, :phylogeny
  active_admin_import validate: true,
        on_duplicate_key_ignore: true,
      after_import:  ->(importer){
        Family.transaction do
          Family.connection.execute("select name from families group by name")
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
