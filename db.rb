require "sequel"
# require 'mysql2'
# DB = Sequel.connect('mysql2://localhost?user=root&password=root')

DB = Sequel.connect('mysql2://root:root@127.0.0.1:3306/crawled') 

DB.create_table :items do
    primary_key :id
    String :name, null: false
    String :price, null: false
    String :link, null: false
    String :itemparams
  end
  
# DB = Sequel.mysql('mysql://localhost?user=root&password=root')
