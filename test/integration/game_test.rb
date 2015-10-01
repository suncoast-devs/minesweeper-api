require 'test_helper'
require 'minitest/mock'

class GamesTest < ActionDispatch::IntegrationTest
  test "new game returns the correct response code" do
    skip
    post '/games', params: { difficulty: 0 }

    assert_response 201
  end

  test "new game returns the correct headers" do
    skip
    post '/games', params: { difficulty: 0 }

    assert_match %r{application/json}, response.headers["Content-Type"]
  end

  test "new easy game returns the correct body" do
    skip
    post '/games', params: { difficulty: 0 }

    json = JSON.parse(response.body)

    assert_equal "new", json["state"], "Board state should be new"
    assert_equal 10,    json["mines"], "Wrong number of mines"
    assert_equal 8,     json["board"].size, "Board should have 8 rows"

    json["board"].size.times do |row|
      assert_equal 8, json["board"][row].size, "Row #{row} of the board should have 8 columns"
    end
  end

  test "new intermediate game returns the correct body" do
    skip
    post '/games', params: { difficulty: 1 }

    json = JSON.parse(response.body)

    assert_equal "new", json["state"], "Board state should be new"
    assert_equal 40,    json["mines"], "Wrong number of mines"
    assert_equal 16,    json["board"].size, "Board should have 16 rows"

    json["board"].size.times do |row|
      assert_equal 16, json["board"][row].size, "Row #{row} of the board should have 16 columns"
    end
  end

  test "new expert game returns the correct body" do
    skip
    post '/games', params: { difficulty: 2 }

    json = JSON.parse(response.body)

    assert_equal "new", json["state"], "Board state should be new"
    assert_equal 99,    json["mines"], "Wrong number of mines"
    assert_equal 24,    json["board"].size, "Board should have 24 rows"

    json["board"].size.times do |row|
      assert_equal 24, json["board"][row].size, "Row #{row} of the board should have 24 columns"
    end
  end

  test "checking a square" do
    skip
    post '/games', params: {difficulty: 0}
    json = JSON.parse(response.body)
    board_id = json["id"]

    post "/games/#{board_id}/check", params: { row: 5, col: 7 }

    json = JSON.parse(response.body)
    board = json["board"]

    # This space should be checked
    assert_equal "_", board[5][7]

    # The spaces around that space should reveal a bomb count
    refute_equal " ", board[4][7] # above
    refute_equal " ", board[4][6] # above and to the left
    refute_equal " ", board[5][6] # to the left
    refute_equal " ", board[6][6] # below and to the left
    refute_equal " ", board[6][7] # below
  end

  test "getting a board in play" do
    skip
    post '/games', params: {difficulty: 0}
    json = JSON.parse(response.body)
    board_id = json["id"]

    post "/games/#{board_id}/check", params: { row: 5, col: 7 }

    get "/games/#{board_id}"
    json = JSON.parse(response.body)

    board = json["board"]

    # This space should be checked
    assert_equal "_", board[5][7]

    # The spaces around that space should reveal a bomb count
    refute_equal " ", board[4][7] # above
    refute_equal " ", board[4][6] # above and to the left
    refute_equal " ", board[5][6] # to the left
    refute_equal " ", board[6][6] # below and to the left
    refute_equal " ", board[6][7] # below
  end

  test "flagging a square" do
    skip
    post '/games', params: {difficulty: 0}
    json = JSON.parse(response.body)
    board_id = json["id"]

    post "/games/#{board_id}/flag", params: { row: 2, col: 2 }

    json = JSON.parse(response.body)
    board = json["board"]

    # This space should be flagged
    assert_equal "F", board[2][2]
    assert_equal 9,   json["mines"]
  end

  test "winning" do
    skip
    all_spaces = []
    8.times{ |row| 8.times { |col| all_spaces << [row,col] } }

    test_game = Game.create(difficulty: 0)
    test_game.mine_locations = all_spaces.take(10)
    test_game.state = "playing"

    spaces_to_click = all_spaces - test_game.mine_locations

    Game.stub :find, test_game do
      spaces_to_click.each do |row, col|
        post "/games/1/check", params: { row: row, col: col }

        json = JSON.parse(response.body)
      end

      # Test the the game is won
      get "/games/1"
      json = JSON.parse(response.body)
      assert_equal "won", json["state"]

      # Test that all the mines are revealed
      board = json["board"]
      test_game.mine_locations.each do |row, col|
        assert_equal Game::MINE, board[row][col]
      end
    end
  end

  test "losing" do
    skip
    all_spaces = []
    8.times{ |row| 8.times { |col| all_spaces << [row,col] } }

    test_game = Game.create(difficulty: 0)
    test_game.mine_locations = all_spaces.take(10)

    Game.stub :find, test_game do
      row, col = test_game.mine_locations[0]
      post "/games/1/check", params: { row: row, col: col }

      get "/games/1"
      json = JSON.parse(response.body)

      # Test that the game is lost
      assert_equal "lost", json["state"]

      # Test that all the mines are revealed
      board = json["board"]
      test_game.mine_locations.each do |row, col|
        assert_equal Game::MINE, board[row][col]
      end
    end
  end
end
