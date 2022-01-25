# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  begin
    drop_table :users if table_exists?(:users)
    drop_table :skills if table_exists?(:skills)
    drop_table :preloads if table_exists?(:preloads)
    drop_table :categories if table_exists?(:categories)
    drop_table :categories_users if table_exists?(:categories_users)
    drop_table :assets if table_exists?(:assets)
  end

  create_table :users do |t|
    t.string :name, null: false
    t.string :email, null: false
    t.integer :invitations, null: false, default: 0
  end

  add_index :users, :email, unique: true

  create_table :preloads do |t|
    t.string :name
  end

  create_table :skills do |t|
    t.references :user
  end

  create_table :categories

  create_table :categories_users, id: false do |t|
    t.references :category
    t.references :user
  end

  create_table :assets do |t|
    t.string :name
  end
end
