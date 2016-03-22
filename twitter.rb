# encoding: utf-8

# XXX/ Этот код необходим только при использовании русских букв на Windows
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# XXX/

require 'twitter'
require 'optparse'


options = {}

# задаем нужные нам опции
OptionParser.new do |opt|
  opt.banner = 'Usage: twitter.rb [options]'

  opt.on('-h', 'вывод помощи по настройкам') do
    puts opt
    exit
  end

  opt.on('--twit "TWIT"', 'Заставить "твит"') { |o| options[:twit] = o } #
  opt.on('--timeline USER_NAME', 'Показать последние твиты') { |o| options[:timeline] = o } #
  opt.on('--image', 'постит картинку') { |o| options[:image] = o } #
end.parse!


client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'r3ZTil2yHx2b0NubmIuddLkTA'
  config.consumer_secret = 'CVEa8Y66kwz8ciaCOZJrc75uWI8Pu01BlmsMuzEu9Gz8z3fs3t'
  config.access_token = '710126128200077312-LLRcsziQUPVFYyHXgXpoxSOBeCWodpx'
  config.access_token_secret = 'AHznV6H0jmSo9e6icYuELjMlmOax129otVwO2ptDJ1mQL'
end


if options.key?(:image)
  client.update_with_media("I'm tweeting with @gem!", File.new("C:/rubytut2/lesson14/twitter/programmist.png"))
end

if options.key?(:twit)
  puts "Постим твит: #{options[:twit].encode("UTF-8")}"
  client.update(options[:twit].encode("UTF-8"))
  puts "Твит запощен!"
end

begin
if options.key?(:timeline)
  puts "Сколько твитов показать?"
  num = STDIN.gets.chomp unless num.is_a? Numeric
  puts "Лента юзера: #{options[:timeline]}"

  opts = {count: num.to_i, include_rts: true}

  twits = client.user_timeline(options[:timeline], opts)

  twits.each do |twit|
    puts twit.text
    puts "by @#{twit.user.screen_name}, #{twit.created_at}"
    puts "-"*40
  end
else
  puts "Сколько твитов показать?"

  num = STDIN.gets.chomp.to_i

  puts "Моя лента:"

  twits = client.home_timeline({count: num.to_i})

  twits.each do |twit|
    puts twit.text
    puts "by @#{twit.user.screen_name}, #{twit.created_at}"
    puts "-"*40
  end
end
rescue Twitter::Error::Unauthorized => e
  abort e.message
rescue Twitter::Error::BadRequest => e
  abort e.message
rescue Twitter::Error => e
  puts "Упс :( ошибка сети"
  abort e.message
  end
