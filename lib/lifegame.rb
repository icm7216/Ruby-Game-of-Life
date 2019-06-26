class Lifegame
  attr_reader :no_change, :step
  attr_accessor :board
  
  # 3x3 neighborhood, relative cell address.
  NE33 = [[-1, -1], [-1,  0], [-1, +1],
          [ 0, -1], [ 0,  0], [ 0, +1],
          [+1, -1], [+1,  0], [+1, +1]]
  # 3x3 convolution operator.
  CO33 = [1, 1, 1, 
          1, 0, 1, 
          1, 1, 1]
  # status
  ALIVE = 1
  DEAD = 0
  # Display character
  ON = "[]"                 # alive character
  OFF = "  "                # dead character

  def initialize(width, height)
    @width = width
    @height = height
    @board = zeros
    @work  = []
    @pre_alive = 0
    @no_change = 0
    @step = 0
  end

  def zeros
    ([[0] * @width] * @height).map(&:clone)
  end

  def scan_cell(y = 0, x = 0, height = @height, width = @width, &block)
    return to_enum(:scan_cell) unless block_given?
    (y...height).each do |_y|
      (x...width).each do |_x|
        block.call(_y, _x)
      end
    end
  end

  def convolution(y, x)
    NE33.each_with_index.inject(0) do |sum, (nabe, idx)|
      row = y + nabe[0]
      col = x + nabe[1]
      unless (row < 0) || (row == @height) || (col < 0) || (col == @width)
        sum += (@board[ row ][ col ] * CO33[idx])
      end
      sum
    end
  end

  def convolution_board
    @work = zeros
    scan_cell do |y, x|
      @work[y][x] = convolution(y, x)
    end
  end

  def each_row(board, &block)
    return to_enum(:each_row) unless block_given?
    str = ""
    board.each do |row|
      row.each do |cell|
        str += block.call(row, cell)
      end
      str += "\n"
    end
    str 
  end

  def to_s
    each_row(@board) {|row, cell| cell == ALIVE ? ON : OFF }
  end
  
  def work_status
    each_row(@work) {|row, cell| cell.to_s + "." }
  end
  
  def board_status
    each_row(@board) {|row, cell| cell.to_s + "." }
  end

  def cur_alive
    @board.inject(:+).inject(:+)
  end

  def random
    @no_change = 0
    @step = 0
    scan_cell {|y, x| @board[y][x] = rand(2) if rand(3) == 0 }
  end

  def update
    convolution_board
    scan_cell do |y, x|
      if (@work[y][x] == 3) || ((@work[y][x] == 2) && (@board[y][x] == 1)) 
        @board[y][x] = ALIVE
      else
        @board[y][x] = DEAD
      end
    end
    (@pre_alive == cur_alive) ? @no_change += 1 : @no_change = 0
    @pre_alive = cur_alive
    @step += 1
  end
end
