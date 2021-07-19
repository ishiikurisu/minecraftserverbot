def detect_command message_text
    message_text.split(" ")[0]
end

def extract_command_arguments message_text
    message_text.split(" ")[1..].join(" ")
end
