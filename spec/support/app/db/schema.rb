# frozen_string_literal: true

ActiveRecord::Schema.define(version: 0) do
  begin
    drop_table :users
    drop_table :skills
    drop_table :preloads
    drop_table :categories
    drop_table :categories_users
  rescue Exception => e
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

  create_table :categories do |t|
  end

  create_table :categories_users, id: false do |t|
    t.references :category
    t.references :user
  end
end
