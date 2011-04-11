ActiveRecord::Schema.define(:version => 0) do
  begin
    drop_table :users
    drop_table :skills
  rescue Exception => e
  end

  create_table :users do |t|
    t.string :name, :null => false
    t.string :email, :null => false
    t.integer :invitations, :null => false, :default => 0
  end

  add_index :users, :email, :unique => true

  create_table :skills do |t|
    t.references :user
  end
end
