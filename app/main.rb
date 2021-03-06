require "yaml"
require "telegram/bot"
require "./app/lib.rb"

class App
    def initialize config
        @config = config
        @token = @config['token']
        @mc_server_dir = @config['server_directory']
        @allowed_users = @config['allowed_users']
        @session_name = "mc"
        @terminal_file = "#{@mc_server_dir}/terminal.log"
        @started = false
        @lc = 0
    end

    def start_server bot, message
        # giving up if server has started
        unless @started
            @started = true

            # starting server
            `cd #{@mc_server_dir}; rm -f #{@terminal_file}`
            `cd #{@mc_server_dir}; touch #{@terminal_file}`
            `cd #{@mc_server_dir}; tmux new -d -s #{@session_name}`
            `tmux send-keys -t #{@session_name}.0 "make > #{@terminal_file}" ENTER`

            # starting logging
            return Thread.new do
                while @started
                    read_terminal_file bot, message
                    sleep 1
                end
                read_terminal_file bot, message
            end
        end
        return nil
    end

    def send_command command
        `tmux send-keys -t #{@session_name}.0 "#{command}" ENTER`
    end

    def stop_server
        @started = false
        send_command "stop"
        `tmux kill-session -t #{@session_name}`
    end

    def run
        puts "# Minecraft Server Bot"
        Telegram::Bot::Client.run(@token) do |bot|
            bot.listen do |message|
                if @allowed_users.include? message.from.id
                    command = detect_command message.text

                    case command
                    when "/start"
                        result = start_server bot, message
                        if result == nil
                            bot.api.send_message(chat_id: message.chat.id, text: "Server is already on!")
                        end
                    when "/command"
                        command = extract_command_arguments message.text
                        if command.length > 0
                            send_command command
                        end
                    when "/stop"
                        stop_server()
                    end
                end
            end
        end
    end

    private
    def read_terminal_file bot, message
        lc = 0
        File.readlines(@terminal_file).each do |line|
            lc += 1
            if lc > @lc
                bot.api.send_message(chat_id: message.chat.id, text: line)
            end
        end
        @lc = lc
    end
end

config = YAML.load(File.open(ARGV[0], 'r').read)
app = App.new config
begin
    app.run
rescue Interrupt => e
    puts "Interrupting!"
end
