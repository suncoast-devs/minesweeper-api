class Game < ActiveRecord::Base
  serialize :board, Array
  serialize :mine_locations, Array

  EMPTY = ' '
  MINE  = '*'
  FLAG  = 'F'
  CLEAR = '_'

  before_create :make_board

  def make_board
    self.board = size.times.map { size.times.map { EMPTY } }
  end

  def place_mines(row, col)
    self.state = 'playing'

    while mine_locations.length < mine_count
      loc = [rand(size), rand(size)]
      unless loc == [row, col] || mine_locations.include?(loc)
        mine_locations << loc
      end
    end
  end

  def flag(row, col)
    board[row][col] = FLAG
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
      mine_locations.each { |r, c| board[r][c] = MINE }
      return
    end

    reveal(row, col)

    if board.flatten.count { |cell| [EMPTY, FLAG].include?(cell) } == mine_locations.length
      self.state = 'won'
      mine_locations.each { |row, col| board[row][col] = MINE }
    end
  end

  def reveal(row, col)
    total = 0
    [-1, 1].each do |y|
      [-1, 1].each do |x|
        neighbor = [row + y, col + x]
        next if out_of_bounds?(*neighbor)
        next if revealed?(*neighbor)

        if mine_locations.include?(neighbor)
          total += 1
        else
          board[row + y][col + x] = CLEAR
          reveal(*neighbor)
        end
      end
    end

    if total > 0
      board[row][col] = total
    end
  end

  # def reveal_neigbor(row, col)
  #   return if revealed?(row, col)
  #   if mine_locations.include?([row, col])
  #
  #   end
  # end

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
      "mines": [10, 40, 99][difficulty] - flag_count
    }
  end
end
