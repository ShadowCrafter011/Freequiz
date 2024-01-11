class Score < ApplicationRecord
    belongs_to :quiz
    belongs_to :user

    attribute :data, :binary_hash
    attribute :favorites, :binary_hash

    MODES = { 0 => "smart", 1 => "write", 2 => "multi", 3 => "cards" }.freeze

    before_create do
        self.total = 0
        self.favorites = []

        quiz = Quiz.find(quiz_id)
        quiz.data.each do |translation|
            data[translation[:hash]] = Array.new(MODES.length, 0)
        end
    end

    after_find do
        if data.values.first.length < MODES.length
            data.each_key do |hash|
                data[hash].concat(
                    Array.new(MODES.length - data[hash].length, 0)
                )
            end
            save
        end
    end

    def self.empty
        output = { favorite: false, score: {} }
        MODES.each do |mode|
            output[:score][mode] = 0
        end
        output
    end

    def get_data(hash)
        array = data[hash.to_sym] || Array.new(MODES.length, 0)
        output = { favorite: favorites.include?(hash.to_s), score: {} }
        MODES.each do |mode|
            output[:score][mode] = array[x]
        end
        output
    end

    def reset
        data.each_key do |hash|
            data[hash] = 0
        end
        save
    end
end
