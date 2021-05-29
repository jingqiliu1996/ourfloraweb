ActiveAdmin.register Family do
  permit_params :name, :phylogeny
  # active_admin_importable
  active_admin_import on_duplicate_key_ignore: true
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
