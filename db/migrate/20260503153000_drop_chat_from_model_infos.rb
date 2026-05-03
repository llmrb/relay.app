Sequel.migration do
  change do
    alter_table(:model_infos) do
      drop_index [:provider, :chat]
      drop_column :chat
    end
  end
end
