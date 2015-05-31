require "sinatra"
require "csv"
require "pg"
require "pry"
# require 'sinatra/flash'
# enable :sessions

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def actors_names
  db_connection do |conn|
    conn.exec("SELECT name FROM actors
              ORDER by actors.name LIMIT 300")
  end
end

def actors_info
  db_connection do |conn|
    conn.exec("SELECT actors.name, movies.title, cast_members.character FROM actors
               JOIN cast_members ON (cast_members.actor_id = actors.id)
               JOIN movies ON (cast_members.movie_id = movies.id)
               WHERE actors.name = '#{params[:name]}'")
  end
end

def movie_names
  db_connection do |conn|
    conn.exec("SELECT movies.title, movies.rating, movies.year, genres.name FROM movies
               JOIN genres ON (movies.genre_id = genres.id)
               ORDER by movies.title")
  end
end

def movie_info
  db_connection do |conn|
    conn.exec("SELECT genres.name as genre,
    studios.name as studio,
     actors.name as actors,
      cast_members.character FROM movies
               JOIN cast_members on (cast_members.movie_id = movies.id)
               JOIN genres ON (movies.genre_id = genres.id)
               JOIN studios ON (movies.studio_id = studios.id)
               JOIN actors ON (cast_members.actor_id = actors.id)
               WHERE movies.title = '#{params[:title]}'
               ORDER by movies.title")
  end
end
#
# This page should contain information about the movie
# (including genre and studio) as well as a list of all of the actors
#  and their roles. Each actor name is a link to the details page for that actor.


get '/' do
  redirect "/actors"
end

get '/actors' do
  erb :'actors/index', locals: {actors_names: actors_names}
end

get '/actors/:name' do
  erb :'actors/show', locals: {name: params[:name], actors_info: actors_info}
end

get '/movies' do
  erb :'movies/index', locals: {title: params[:title], movie_names: movie_names, movie_info: movie_info}
end

get '/movies/:title' do
  erb :'movies/show', locals: {title: params[:title], movie_info: movie_info}
end

# get '/tada' do
#   flash[:notice] = "Hooray, Flash is working!"
#   flash[:warning] = "Warning!"
#   flash[:success] = "Hooray, Flash is working!"
#   erb :index
# end
