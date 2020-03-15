# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
# Database schema - this should reflect your domain model
DB.create_table! :gyms do
  primary_key :id
  String :name
  Float  :avg_rating
  String :description, text: true
  String :location
  String :contact
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :gyms_id
  foreign_key :user_id
  String :comments, text: true
  Integer :overall_rating
  Integer :equipment_rating
  Integer :trainers_rating
  String :name
  String :email
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end


# Insert initial (seed) data
gyms_table = DB.from(:gyms)
reviews_table = DB.from(:reviews)

gyms_table.insert(Name: "London Gold Gym", 
                    description: "The famous mecca of bodybuilding in London!",
                    avg_rating: 0.0,
                    location: "Baker Street",
                    contact: "+447425184467")

gyms_table.insert(Name: "Fitness First", 
                    description: "21 Outles all across London  ",
                    avg_rating: 0.0,
                    location: "Bond Street",
                    contact: "+447425184467")


puts "Success!"