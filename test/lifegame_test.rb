require_relative './test_helper'

class TestLifegame < Test::Unit::TestCase
  self.test_order = :defined

  sub_test_case 'Methods' do
    setup do
      @life = Lifegame.new(5, 5)
    end

    test '#cur_alive' do
      @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 1, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 0, 0, 0]
      ]
      assert_equal 7, @life.cur_alive
    end

    test '#scan_cell' do
      w = []
      @life.scan_cell(0, 0, 3, 4) do |y, x|
        w << [y, x]
      end
      assert_equal w, [
        [0, 0], [0, 1], [0, 2], [0, 3],
        [1, 0], [1, 1], [1, 2], [1, 3],
        [2, 0], [2, 1], [2, 2], [2, 3]
      ]
    end

    test '#convolution' do
      @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 1, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 0, 0, 0]
      ]
      assert_equal @life.convolution(2, 2), 6
    end

    test '#convolution_board' do
      @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 1, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 0, 0, 0]
      ]
      @life.convolution_board
      assert_equal @life.work_status, (
        "1.2.3.2.1.\n" + 
        "1.2.3.2.1.\n" + 
        "2.5.6.5.2.\n" + 
        "1.2.3.2.1.\n" + 
        "1.2.3.2.1.\n"
      )
    end
  end

  sub_test_case 'Rules' do
    setup do
      @life = Lifegame.new(5, 5)
    end
    # 空白セルは、周囲に3つの生存セルが存在すれば、次の世代が誕生する。
    test "born" do
     @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 1, 0, 1, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
     @life.update
      assert_equal @life.board, [
        [0, 0, 0, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
    end
    # 生存セルは、周囲に生存セルが2つか3つ存在すれば存続できる。
    test "alive_2: When there are 2 living cells around" do
     @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
     @life.update
      assert_equal @life.board, [
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ] 
    end
    test "alive_3: When there are 3 living cells around" do
     @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 0, 0], 
        [0, 1, 1, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
     @life.update
      assert_equal @life.board, [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 0, 0], 
        [0, 1, 1, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ] 
    end
    # 生存セルは、周囲の生存セルが1つ以下ならば、過疎により死滅。
    test "depopulation" do
     @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
     @life.update
      assert_equal @life.board, [
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ] 
    end
    # 生存セルは、周囲の生存セルが4つ以上ならば、過密により死滅。
    test "overpopulation" do
     @life.board = [
        [0, 0, 0, 0, 0], 
        [0, 1, 1, 0, 0], 
        [0, 1, 1, 1, 0], 
        [0, 0, 0, 0, 0], 
        [0, 0, 0, 0, 0]
      ]
     @life.update
      assert_equal @life.board, [
        [0, 0, 0, 0, 0], 
        [0, 1, 0, 1, 0], 
        [0, 1, 0, 1, 0], 
        [0, 0, 1, 0, 0], 
        [0, 0, 0, 0, 0]
      ] 
    end
  end

  sub_test_case 'Beacon behavior' do
    setup do
      @life = Lifegame.new(6, 6)
    end

    data('step_1' => [[
      [0,0,0,0,0,0], 
      [0,1,1,0,0,0], 
      [0,1,1,0,0,0], 
      [0,0,0,1,1,0],
      [0,0,0,1,1,0], 
      [0,0,0,0,0,0]
    ],[
      [0,0,0,0,0,0], 
      [0,1,1,0,0,0], 
      [0,1,0,0,0,0], 
      [0,0,0,0,1,0],
      [0,0,0,1,1,0], 
      [0,0,0,0,0,0] ]])
    data('step_2' => [[
      [0,0,0,0,0,0], 
      [0,1,1,0,0,0], 
      [0,1,0,0,0,0], 
      [0,0,0,0,1,0],
      [0,0,0,1,1,0], 
      [0,0,0,0,0,0]
    ],[
      [0,0,0,0,0,0], 
      [0,1,1,0,0,0], 
      [0,1,1,0,0,0], 
      [0,0,0,1,1,0],
      [0,0,0,1,1,0], 
      [0,0,0,0,0,0] ]])
    def test_equal(data)
      expected, actual = data
      @life.board = expected
      @life.update
      assert_equal @life.board, actual
    end
  end
end