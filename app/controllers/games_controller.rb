require 'open-uri'
require 'json'
class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    if params[:attempt]
      @attempt = params[:attempt]
      @grid = params[:letters]
      run_game(@attempt, @grid, 0, 0)
    end

  end

    private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

def score_and_message(attempt, grid, time)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

  def run_game(attempt, grid, start_time, end_time)
  @result = { time: end_time - start_time }
  score_and_message = score_and_message(attempt, grid, @result[:time])
  @result[:score] = score_and_message.first
  @result[:message] = score_and_message.last
  @result
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
