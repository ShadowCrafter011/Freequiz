# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

system_user = User.create(username: "System", email: "system@freequiz.ch", password: "BigChungus01", agb: true, confirmed_at: Time.now)
system_user.update(role: "admin", confirmed: true, password: "71ba800fb1961f975e0bbfb555aae2c2fa38f2e268c5f6f0333b2ee9aca74523")

Language.create([
    { id: 1, name: "german", locale: "de" },
    { id: 2, name: "french", locale: "fr" },
    { id: 3, name: "english", locale: "en" },
    { id: 4, name: "spanish", locale: "es" },
    { id: 5, name: "italian", locale: "it"},
    { id: 6, name: "latin", locale: "la" },
    { id: 7, name: "greek", locale: "el" },
    { id: 8, name: "romansh", locale: "rm" },
    { id: 9, name: "japanese", locale: "ja" },
    { id: 10, name: "korean", locale: "ko" },
    { id: 11, name: "chinese", locale: "zh" }
])

system_id = User.find_by(username: "System").id

for x in 1..20 do
    quiz = Quiz.new(user_id: system_id, title: "Automatic Quiz ##{x}", description: "This Quiz was generated randomly", data: [], from: 3, to: 1, visibility: "public")
    
    10.times do
        word = HTTParty.get("https://random-word-api.herokuapp.com/word")[0]
        query = { text: word, source_lang: "EN", target_lang: "DE" }
        headers = { Authorization: "DeepL-Auth-Key 05641ada-4439-cdfd-109f-539ebb0059ca:fx" }
        translation = HTTParty.post("https://api-free.deepl.com/v2/translate", query: query, headers: headers)["translations"][0]["text"]
        quiz.data.append({ w: word, t: translation })
    end
    quiz.save
    puts "Generated Quiz ##{x}"
end

for x in 21..1000 do
    Quiz.create(user_id: system_id, title: "Automatic Quiz ##{x}", description: "This Quiz was generated automatically", data: [{w: "Tree", t: "Baum"}], from: 3, to: 1, visibility: "public")
    puts "Generated Quiz ##{x}"
end
