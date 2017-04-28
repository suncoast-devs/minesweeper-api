class Game < ActiveRecord::Base
  serialize :board, Array
  serialize :mine_locations, Array

  EMPTY = ' '
  MINE  = '*'
  FLAG  = 'F'
  SAFE  = '@'
  CLEAR = '_'

  before_create :make_board

  def make_board
    self.board = size.times.map { size.times.map { EMPTY } }
  end

  def place_mines(row, col)
    self.state = 'playing'

    while mine_locations.length < mine_count
      loc = [rand(size), rand(size)]

      banned_locations = [
        [row - 1, col - 1],
        [row + 0, col - 1],
        [row + 1, col - 1],
        [row - 1, col + 0],
        [row + 0, col + 0],
        [row + 1, col + 0],
        [row - 1, col + 1],
        [row + 0, col + 1],
        [row + 1, col + 1]
      ]

      banned_locations.concat(mine_locations)
      mine_locations << loc unless banned_locations.include?(loc)
    end
  end

  def flag(row, col)
    if board[row][col] == EMPTY
      board[row][col] = FLAG
    elsif board[row][col] == FLAG
      board[row][col] = EMPTY
    end
  end

  def out_of_bounds?(row, col)
    row < 0 || col < 0 || row >= size || col >= size
  end

  def check(row, col)
    # If we don't have any mines, go ahead and place them
    place_mines(row, col) if mine_locations.empty?

    # If the player is checking a mine space
    if mine_locations.include?([row, col])
      self.state = 'lost'
      mine_locations.each do |r, c|
        if board[r][c] == FLAG
          board[r][c] = SAFE
        else
          board[r][c] = MINE
        end
      end

      return
    end

    reveal(row, col)

    if board.flatten.count { |cell| [EMPTY, FLAG].include?(cell) } == mine_locations.length
      self.state = 'won'
      mine_locations.each { |row, col| board[row][col] = MINE }
    end
  end

  def reveal(row, col)
    if (count = mine_count_for(row, col)) > 0
      board[row][col] = count
      return
    else
      board[row][col] = CLEAR
    end

    (-1..1).each do |y|
      (-1..1).each do |x|
        neighbor = [row + y, col + x]
        next if x == 0 && y == 0
        next if out_of_bounds?(*neighbor)
        next if revealed?(*neighbor)

        reveal(*neighbor)
      end
    end
  end

  def mine_count_for(row, col)
    total = 0
    (-1..1).each do |y|
      (-1..1).each do |x|
        total += 1 if mine_locations.include?([row + y, col + x])
      end
    end

    total
  end

  def revealed?(row, col)
    ![EMPTY, MINE].include?(board[row][col])
  end

  # def compute_mines_for(row, col)
  #   total = 0
  #   (-1..1).each do |y|
  #     (-1..1).each do |x|
  #       next if (y == 0 && x == 0) || out_of_bounds?(row + y, col + x)
  #
  #       if mine_locations.include?([row + y, col + x])
  #         total += 1
  #       end
  #     end
  #   end
  #
  #   board[row][col] = total
  # end

  def flag_count
    board.flatten.count { |cell| cell == FLAG }
  end

  def size
    [8, 16, 24][difficulty]
  end

  def mine_count
    [10, 40, 99][difficulty]
  end

  def as_json(*)
    {
      "id":    id,
      "board": board,
      "state": state,
      "mines": [10, 40, 99][difficulty] - flag_count,
      "difficulty": difficulty
    }
  end
end
