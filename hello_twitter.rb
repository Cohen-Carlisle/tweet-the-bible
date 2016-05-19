require 'yaml'
require 'oauth'
require 'uri'
require 'json'
require 'pp'
require 'pry' # for debugging

base_uri = 'https://api.twitter.com/1.1/statuses/update.json?'
oauth = YAML.load(File.open('oauth.yaml'))
consumer = OAuth::Consumer.new(oauth['consumer_key'], oauth['consumer_secret'])
token = OAuth::AccessToken.new(consumer, oauth['token'], oauth['token_secret'])

print "Tweet: "
input = gets.chomp
query_string = URI.encode_www_form(status: input)

response = token.post(base_uri + query_string)
puts response.code
pp JSON.parse(response.body) unless response.code == '200'
