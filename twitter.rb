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

# подключаю библиотеку
require 'twitter'
require 'optparse'

# Все опции будут записаны сюда
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

# конфигурируем твитер клиент согласно документации https://github.com/sferik/twitter/blob/master/examples/Configuration.md
client = Twitter::REST::Client.new do |config|
  # ВНИМАНИЕ! Эти параметры уникальны для каждого проиложения, вы должны
  # зарегистрировать в своем аккаунте новое приложение на https://apps.twitter.com
  # и взять со страницы этого приложения данные настройки!
  config.consumer_key = '___'
  config.consumer_secret = '_______'
  config.access_token = '______'
  config.access_token_secret = '______'
end

# Постим новый твит https://github.com/sferik/twitter/blob/master/examples/Update.md
begin
  # постит картинку, если переданный аргумент --image
  if options.key?(:image)
    client.update_with_media("I'm tweeting with @gem!", File.new("")) # File.new("") <= здесь указан путь к картинке
  end

  # если картинка не найдена, то программа завершается
rescue Errno::ENOENT => e
  puts "не удалось загрузить картинку :("
  abort e.message
end

# запрос на вывод последних твитов из ленты
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

  # обработка ошибок, если не верный ключ
rescue Twitter::Error::Unauthorized => e
  abort e.message
rescue Twitter::Error::BadRequest => e
  abort e.message
    # обработка ошибки сети
rescue Twitter::Error => e
  puts "Упс :( ошибка сети"
  abort e.message
end
