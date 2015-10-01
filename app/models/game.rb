class Game < ActiveRecord::Base
  serialize :board, Array
  serialize :mine_locations, Array

  EMPTY = " "
  MINE  = "*"
  FLAG  = "F"

  before_create :make_board
  def make_board
    self.board = size.times.map { |row| size.times.map { |col| EMPTY } }
  end

  # Place the right number of mines on the board
  # but you CAN'T place any at row and col
  def place_mines(row, col)
    self.state = "playing"

    #
    # YOUR CODE GOES HERE TO PLACE THE RIGHT NUMBER OF BOMBS
    #
    # self.mine_locations = ...
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

    if mine_locations.include?([row, col])
      self.state = "lost"
      mine_locations.each { |row, col| board[row][col] = MINE }
      return
    end

    board[row][col] = "_"

    (-1..1).each do |row_offset|
      (-1..1).each do |col_offset|
        next if (row_offset == 0 && col_offset == 0) || out_of_bounds?(row + row_offset, col + col_offset)

        compute_mines_for(row + row_offset, col + col_offset)
      end
    end

    if board.flatten.count { |cell| [EMPTY, FLAG].include?(cell) } == mine_locations.length
      self.state = "won"
      mine_locations.each { |row, col| board[row][col] = MINE }
    end
  end

  def compute_mines_for(row, col)
    total = 0
    (-1..1).each do |row_offset|
      (-1..1).each do |col_offset|
        next if (row_offset == 0 && col_offset == 0) || out_of_bounds?(row + row_offset, col + col_offset)

        if mine_locations.include?([row + row_offset,col + col_offset])
          total = total + 1
        end
      end
    end

    board[row][col] = total
  end

  def flag_count
    board.flatten.count { |cell| cell == FLAG }
  end

  def size
    [8,16,24][difficulty]
  end

  def as_json(*)
    {
      "id":    id,
      "board": board,
      "state": state,
      "mines": [10,40,99][difficulty] - flag_count,
    }
  end
end
