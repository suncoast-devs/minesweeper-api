class GamesController < ApplicationController
  def flag
    game = Game.find(params[:id])
    game.flag(params[:row].to_i, params[:col].to_i)
    game.save

    render json: game
  end

  def show
    game = Game.find(params[:id])

    render json: game
  end

  def check
    game = Game.find(params[:id])
    game.check(params[:row].to_i, params[:col].to_i)
    game.save

    render json: game
  end

  def create
    game = Game.create(difficulty: params[:difficulty].to_i, state: 'new')

    render json: game, status: :created
  end
end
