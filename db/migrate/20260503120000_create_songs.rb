Sequel.migration do
  change do
    create_table(:songs) do
      primary_key :id
      String :name, null: false
      String :title, null: false
      String :track, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :name
      index :title
      index :track, unique: true
    end
  end
end
