require 'http'
require 'json'
require 'dotenv'

Dotenv.load('.env')

# fonction qui initialise l'authentification
def login_openai(prompt = "Bonjour")
  api_key = ENV["OPENAI_API_KEY"]
  url = "https://api.openai.com/v1/engines/text-babbage-001/completions"

  headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
  }

  data = {
  "prompt" => prompt,
  "max_tokens" => 100,
  "temperature" => 0.8
  }

  response = HTTP.post(url, headers: headers, body: data.to_json)
  response_body = JSON.parse(response.body.to_s)
  response_string = response_body['choices'][0]['text'].strip
  
  return response_string
end

#fonction pour parler avec l'API
def converse_with_ai(api_key, conversation_history = [])
  url = "https://api.openai.com/v1/engines/text-davinci-002/completions"

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{api_key}"
  }

  prompt = "Bonjour"
  if conversation_history.any?
    last_entry = conversation_history.last
    prompt = "#{last_entry[:bot]}\n\n#{last_entry[:user]}"
  end

  data = {
    "prompt" => prompt,
    "max_tokens" => 100,
    "temperature" => 0.8
  }

  response = HTTP.post(url, headers: headers, body: data.to_json)
  response_body = JSON.parse(response.body.to_s)

  if response_body['choices'].empty?
    return "Je suis désolé, je ne peux pas répondre à ça pour le moment."
  end

  bot_response = response_body['choices'][0]['text'].strip
  conversation_history << { user: prompt, bot: bot_response }

  return bot_response
end

# Appelle login_openai pour t'authentifier et obtenir la réponse initiale du bot.
initial_response = login_openai("Bonjour")
puts initial_response

# Lancer la boucle de conversation
conversation_history = []
loop do
  print "Vous: "
  user_input = gets.chomp.downcase
  conversation_history << { user: user_input, bot: "" }
  bot_response = converse_with_ai(ENV["OPENAI_API_KEY"], conversation_history)
  conversation_history.last[:bot] = bot_response
  puts "IA: #{bot_response}"
  break if user_input == "au revoir"
end