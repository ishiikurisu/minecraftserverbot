task default: %w[run]

desc "Starts the bot"
task :run do
    ruby 'app/main.rb', './config.yml'
end

desc "Tests bot internal functions"
task :test do
    ruby 'test/test_command.rb'
end
