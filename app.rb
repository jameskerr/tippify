require 'sinatra'
require_relative 'lib/tippify'

get '/' do
  erb :index
end

post '/tippify' do
    @input = params["uploaded_file"][:tempfile].read
	begin
		@output = Tippify.new(@input).replace!
		erb :index
	rescue => e
		@output = "There has been an error here!  This is the problem: #{e}"
		erb :index
	end
end