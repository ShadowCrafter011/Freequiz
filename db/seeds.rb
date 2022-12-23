# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Language.create([
    { name: "german", locale: "de" },
    { name: "french", locale: "fr" },
    { name: "english", locale: "en" },
    { name: "spanish", locale: "es" },
    { name: "italian", locale: "it"},
    { name: "latin", locale: "la" },
    { name: "greek", locale: "el" },
    { name: "romansh", locale: "rm" },
    { name: "japanese", locale: "ja" },
    { name: "korean", locale: "ko" },
    { name: "chinese", locale: "zh" }
])
