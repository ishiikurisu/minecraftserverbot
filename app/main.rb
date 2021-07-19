require "yaml"
require "telegram_bot"

class App
    def initialize config
        @config = config
        @bot = TelegramBot.new token: @config['token']
    end

    def run
        puts "# Minecraft Server Bot"
        @bot.get_updates do |message|
            puts "---"
            puts "from: @#{message.from.username}"
            puts "message: #{message.text}"
            command = message.get_command_for @bot

            message.reply do |reply|
                reply.text = command
                reply.send_with @bot
            end
        end
    end
end

config = YAML.load(File.open(ARGV[0], 'r').read)
app = App.new config
begin
    app.run
rescue Interrupt => e
    puts "Interrupting!"
end
