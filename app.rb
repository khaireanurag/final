# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"
require "sinatra/cookies"                                                                     #
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

before do 
@current_user = users_table.where(id:session["Logged_user_id"]).to_a[0]
end

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
        user_id: session["Logged_user_id"],
        name: session["Logged_user_name"],
        email: session["Logged_user_email"],
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

post "/users/create" do
    puts "params: #{params}"

    users_table.insert(
        name: params["name"],
        email: params["email"],
        password: BCrypt::Password.create(params["password"]),
        )
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"
 
    @user = users_table.where(email:params["email"]).to_a[0]

    if @user
        if BCrypt::Password.new(@user[:password]) == params["password"]
        session["Logged_user_id"] = @user[:id]
        session["Logged_user_name"] = @user[:name]
        session["Logged_user_email"] = @user[:email]
        view "create_login"
        else
        view "create_login_failed"
        end
    else
    view "create_login_failed"
    end
end

get "/logout" do
        session["Logged_user_id"] = nil
        session["Logged_user_name"] = nil
        session["Logged_user_email"] = nil
    view "logout"
end



get "/gyms/:id/gyms/contact" do

if session["Logged_user_id"] == nil 
    view "sms_fail"
else

@gym_contact = gyms_table.where(id:params["id"]).to_a[0]
account_sid = "ACaa2bfafe8214ff00c7f612d721bc5443"
auth_token = "449f3bef8a690e4bf14dcc4e395e412f"

client = Twilio::REST::Client.new(account_sid, auth_token)

client.messages.create(
 from: "+12674634027", 
 to: "#{@gym_contact[:contact]}",
 body: "Hey user #{session["Logged_user_name"]} is interested in booking a free session. Contact them at #{session["Logged_user_email"]} !"
)
    view "sms_success"
end

end