ActiveAdmin.register Family do
  permit_params :name, :phylogeny
  active_admin_import validate: true,
  
  template_object: ActiveAdminImport::Model.new(
      hint: "file will be imported with such header format: 'body','title','author'",
      csv_headers: ["name","created_at","updated_at"],
      headers_rewrites: { :'created_at' => :created_at},
  )
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
