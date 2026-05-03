Sequel.migration do
  change do
    rename_table :model_infos, :model_records
  end
end
