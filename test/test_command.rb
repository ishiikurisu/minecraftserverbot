require "minitest/autorun"
require "./app/lib.rb"

class TestCommand < MiniTest::Test
    def test_command_detection
        commands = {
            "/start" => "/start",
            "/stop" => "/stop",
            "/command gamerule showcoordinates true" => "/command",
        }

        commands.each do |message_text, expected_result|
            obtained_result = detect_command message_text
            assert_equal expected_result, obtained_result
        end
    end

    def test_command_extraction
        commands = {
            "/start" => "",
            "/stop" => "",
            "/command gamerule showcoordinates true" => "gamerule showcoordinates true",
        }

        commands.each do |message_text, expected_result|
            obtained_result = extract_command_arguments message_text
            assert_equal expected_result, obtained_result
        end
    end
end
