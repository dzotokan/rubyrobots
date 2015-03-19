require 'bundler'
Bundler.require

server = Opal::Server.new(debug: false) do |s|
  s.append_path 'app'
  s.append_path 'lib'
  s.main = 'application'
  s.index_path = 'index.html.erb'
end

run server
