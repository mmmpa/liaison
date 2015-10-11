require 'sinatra'
require 'sinatra/cookies'

Dir[
  Pathname.new("#{__dir__}") + '../app/app.rb',
].each(&method(:require))

LiaisonApplication.ready

set :public_folder, Pathname.new("#{__dir__}") + '../sinatra/public'

get '/' do
  Liaison.new(LiaisonApplication.analysed_config).execute({method: :get, parameters: {}}).rendered
end

post '/' do
  result = Liaison.new(LiaisonApplication.analysed_config).execute({method: :post, parameters: params, cookie_token: cookies[:token]})
  cookies[:token] = result.token.for_cookie if result.token
  result.try_send_mail
  result.rendered
end
