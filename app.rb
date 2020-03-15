# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

gyms_table = DB.from(:gyms)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

get "/" do
    puts "params: #{params}"
    pp gyms_table.all.to_a
    @gyms = gyms_table.all.to_a
    @reviews = reviews_table.all.to_a
    view "gymlisting"
end

get "/gyms/:id" do
    puts "params: #{params}"
    pp gyms_table.where(id:params["id"]).to_a[0]
    @gym = gyms_table.where(id:params["id"]).to_a[0]
    @reviews = reviews_table.where(gyms_id:params["id"]).to_a
    view "gym"
end

get "/gyms/:id/reviews/new" do
    puts "params: #{params}"
    @gym = gyms_table.where(id:params["id"]).to_a[0]
    view "review"
end

get "/gyms/:id/review/create" do
    puts "params: #{params}"
    @gym = gyms_table.where(id:params["id"]).to_a[0]

    reviews_table.insert(
        gyms_id: @gym[:id],
        name: params["name"],
        email: params["email"],
        overall_rating: params["Overall_Rating"],
        equipment_rating: params["Equipment_Rating"],
        trainers_rating: params["Trainers_Rating"],
        comments: params["comments"]
        )

    view "create_review"
end


get "/users/new" do
    view "new_user"
end

get "/users/create" do
    puts "params: #{params}"

    users_table.insert(
        name: params["name"],
        email: params["email"],
        password: params["password"],
        )
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

get "/logins/create" do
    puts "params: #{params}"
 
    @user = users_table.where(email:params["email"]).to_a[0]

    if @user
        if @user[:password] == params["password"]
        view "create_login"
        else
        view "create_login_failed"
        end
    else
    view "create_login_failed"
    end
end

get "/logout" do
    view "logout"
end
