require "open-uri"
require "json"

class GamesController < ApplicationController
  def initialize
    super
    @vowels = ["A", "E", "I", "O", "U"]
  end

  def new
    @grid = generate_grid(10)
    session[:grid] = @grid.join
    session[:start_time] = Time.now.to_s
    session[:grand_score] = 0 if session[:grand_score].nil?
  end

  def score
    @grid = session[:grid].split("")
    session[:end_time] = Time.now.to_s
    session[:grand_score] = 0 if session[:grand_score].nil?
    attempt = params[:attempt]
    time_to_answer = Time.parse(session[:end_time]) - Time.parse(session[:start_time])
    time_to_answer = 1 if time_to_answer == 0
    score = 0

    unless valid_letters(attempt.downcase)
      @response = { score: score, message: "#{attempt.upcase} is not in the grid", time: time_to_answer, win: false }
      return
    end

    if word_in_dictionary?(attempt)
      score = (attempt.length * 1000).fdiv(time_to_answer).floor
      @response = { score: score, message: "Well done 🚀", time: time_to_answer, win: true }
    else
      @response = { score: score, message: "#{attempt.upcase} is not an English word", time: time_to_answer, win: false }
    end

    session[:grand_score] = session[:grand_score].to_i + score
  end

  def reset
    session[:grand_score] = 0
    redirect_to new_path
  end

  private

  def word_in_dictionary?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word.downcase}"
    serialized_response = URI.open(url).read
    response = JSON.parse(serialized_response)
    response["found"]
  end

  def generate_grid(grid_size)
    vowels_proportion = 0.4
    vowels_count = (grid_size * vowels_proportion).ceil
    consonant_count = grid_size - vowels_count

    grid = []
    # pick vowels
    (1..vowels_count).each { grid << @vowels.sample }

    # pick consonants
    (1..consonant_count).each do
      grid << ("A".."Z").to_a.reject { |letter| @vowels.include?(letter) }.sample
    end
    grid.shuffle
  end

  def generate_word_hash(word)
    hash = {}
    word.chars.each do |char|
      if hash.key?(char)
        hash[char] += 1
      else
        hash[char] = 1
      end
    end
    hash
  end

  def valid_letters(attempt)
    attempt_hash = generate_word_hash(attempt)
    grid_hash = generate_word_hash(@grid.join.downcase)
    attempt_hash.each do |key, value|
      return false unless grid_hash.key?(key)
      return false if grid_hash[key] < value
    end
    return true
  end
end
