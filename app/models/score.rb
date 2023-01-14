class Score < ApplicationRecord
  belongs_to :quiz
  belongs_to :user

  attribute :data, :binary_hash
  attribute :favorites, :binary_hash

  MODES = {
    0 => "smart",
    1 => "write",
    2 => "multi",
    3 => "cards"
  }

  before_create do
    self.total = 0
    self.favorites = []

    quiz = Quiz.find(self.quiz_id)
    for translation in quiz.data do
      self.data[translation[:hash]] = Array.new(MODES.length, 0)
    end
  end

  after_find do
    if self.data.values.first.length < MODES.length
      for hash in self.data.keys do
        self.data[hash].concat(Array.new(MODES.length - self.data[hash].length, 0))
      end
      self.save
    end
  end

  def self.empty
    output = { favorite: false, score: {} }
    for x in 0..(MODES.length - 1) do
      output[:score][MODES[x]] = 0
    end
    return output
  end

  def get_data hash
    array = self.data[hash.to_sym] || Array.new(MODES.length, 0)
    output = { favorite: self.favorites.include?(hash.to_s), score: {} }
    for x in 0..(MODES.length - 1) do
      output[:score][MODES[x]] = array[x]
    end
    return output
  end

  def reset
    for hash, score in self.data do
      self.data[hash] = 0
    end
    self.save
  end
end
