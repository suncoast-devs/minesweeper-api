require "sinatra"
require "sinatra/json"
require "sinatra/activerecord"
require "json"
require "amazing_print"

require_relative "./game.rb"

if ENV["PORT"]
  set :port, ENV["PORT"]
end

if ENV["RACK_ENV"] != "production"
  set :database_file, "./config/database.yml"
end

configure do
  enable :cross_origin
end

before do
  response.headers["Access-Control-Allow-Origin"] = "*"
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"

  200
end

get "/" do
  send_file File.join(settings.public_folder, "index.html")
end

post "/games" do
  data = parse_body

  # Remove all the old games.
  # This makes sure that we do not fill the database
  Game.where("created_at > ?", Date.today - 30).delete_all

  game = Game.create(difficulty: data["difficulty"].to_i, state: "new")

  json(game)
end

get "/games/{id}" do
  data = parse_body

  game = Game.find(data["id"])

  json(game)
end

post "/games/{id}/flag" do
  data = parse_body

  game = Game.find(data["id"])
  validate_move(data, game)

  game.flag(data["row"].to_i, data["col"].to_i)
  game.save

  json(game)
end

post "/games/{id}/check" do
  data = parse_body

  game = Game.find(data["id"])
  validate_move(data, game)

  game.check(data["row"].to_i, data["col"].to_i)
  game.save

  json(game)
end

def validate_move(data, game)
  if data["row"].nil?
    halt 400, json({ error: "Missing parameter row" })
  end

  if data["col"].nil?
    halt 400, json({ error: "Missing parameter col" })
  end

  row = data["row"].to_i
  col = data["col"].to_i

  if game.out_of_bounds?(row, col)
    halt 400, json({ error: "Illegal move" })
  end
end

def parse_body
  data = nil

  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    halt 400, json(error: "Sorry, your JSON request could not be parsed")
  end

  data.merge!(params)
  data
end
