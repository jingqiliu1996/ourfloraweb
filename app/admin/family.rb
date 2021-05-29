ActiveAdmin.register Family do
  permit_params :name, :phylogeny
  active_admin_import validate: true,
        on_duplicate_key_ignore: true,
      after_import:  ->(importer){
        Family.transaction do
          Family.connection.execute("delete from families where id in (select id from (select id from families where name in 

(select name from families group by name having count(name)>1) and id not in

(select min(id) from families group by name having count(name)>1)) as tmpresult)")
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
