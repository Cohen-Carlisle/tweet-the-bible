require 'yaml'
require 'oauth'
require 'uri'
require 'json'
require 'pp'

# tweeter = Tweeter.new
# verses = File.readlines("./bible/62-1Jo")
# verses.each { |verse| tweeter.tweet(verse) }

class Tweeter
  BASE_URI = 'https://api.twitter.com/1.1/statuses/update.json?'

  def initialize
    # TODO stop loading all this stuff every time
    oauth = YAML.load(File.open('oauth.yaml'))
    consumer = OAuth::Consumer.new(oauth['consumer_key'], oauth['consumer_secret'])
    @token = OAuth::AccessToken.new(consumer, oauth['token'], oauth['token_secret'])
  end

  def tweet(str)
    if str.length <= 140
      do_tweet(str)
    else
      header, verse = str.split(" ", 2)
      a = []
      split_tweets(verse, header.length, a)
      a = handle_last_tweet_length(a, header.length)
      a.each_with_index do |verse, i|
        do_tweet("#{header}[#{i+1}/#{a.length}] #{verse}")
      end
    end
  end

  # private

  def split_tweets(verse, header_length, ary)
    upto = 140 - header_length - 6 # 6 is for paging
    if verse.length < upto
      ary << verse
      return
    end
    space_idx = verse[0...upto].rindex(/ /)
    ary << verse[0...space_idx]
    split_tweets(verse[space_idx+1..-1], header_length, ary)
  end

  def do_tweet(str)
    query_string = URI.encode_www_form(status: str)
    response = @token.post(BASE_URI + query_string)
    # TODO handle response
    puts response.code
    pp JSON.parse(response.body) unless response.code == '200'
    sleep 36
  end

  def handle_last_tweet_length(array, header_length)
    return array if array.last.length > 60
    new_array = []
    wiggle = (60.0 - array.last.length) / (array.length - 1) + header_length
    split_tweets(array.join(" "), wiggle, new_array)
    new_array
  end
end
