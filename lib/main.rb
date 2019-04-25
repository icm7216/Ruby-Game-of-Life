require_relative './lifegame'
require 'curses'

# command option
# ruby main.rb <width> <height>

NO_CHANGE_MAX = 50  # Upper limit of no change
COUNT_DOWN = 10

class LifegameCurses < Lifegame
  def initialize(width, height)
    # status window
    status_w = 40
    status_h = 4
    @w_status = Curses::Window.new(status_h, status_w, height - status_h, 0)

    # main window
    @w_main = Curses::Window.new(height - status_h, width, 0, 0)
    @w_main.timeout = 0

    # info window
    info_w = 40
    info_h = 6
    @w_info = Curses::Window.new(info_h, info_w, height - info_h - status_h, 0)

    # initialize Lifegame Class
    w = (width / 2) - 1
    h = height - status_h
    super(w, h)

    @cmd = ""
    @ch = ""
    view_clear
    view_status
  end

  def view_update
    @w_main.color_set(1)
    @w_main.setpos(0, 0)
    @w_main.addstr(to_s)
    @w_main.refresh
    view_status

    case @cmd
    when :Next
      update
      @cmd = :Pause
    when :Start
      update
    end 
  end

  def view_status
    @w_status.color_set(2)
    @w_status.box('|', '-', '+')
    @w_status.setpos(1, 2)
    @w_status.addstr("Generation:#{@step}  ")
    @w_status.setpos(1, 20)
    @w_status.addstr("Alive:#{cur_alive}  ")
    @w_status.setpos(2, 2)
    @w_status.addstr("h:#{@height} w:#{@width}")
    @w_status.setpos(2, 20)
    @w_status.addstr("ch:#{@ch} cmd:#{@cmd} ")
    @w_status.refresh
  end

  def view_info(n)
    msg1 = "Life activities "
    msg1 += (cur_alive == 0) ? "are inactive." : "have stopped."
    msg2 = "Generation: #{@step - NO_CHANGE_MAX}, Alive: #{cur_alive}"
    msg3 = "Countdown for Resume : #{COUNT_DOWN - n} "
    @w_info.color_set(2)
    @w_info.box('|', '-', '+')
    @w_info.setpos(1, 2)
    @w_info.addstr(msg1)
    @w_info.setpos(2, 2)
    @w_info.addstr(msg2)
    @w_info.setpos(4, 2)
    @w_info.addstr(msg3)
    @w_info.refresh
  end

  def resume_count_down
    COUNT_DOWN.times do |n|
      view_info(n)
      sleep 1.0
    end
  end

  def view_clear
    @w_main.clear
    @w_status.clear
    @w_info.clear
    @w_main.refresh
    @w_status.refresh
    @w_info.refresh
  end

  def getcmd
    case @ch = @w_main.getch
    when "p", "P"
      @cmd = :Pause
    when "n", "N", " "
      @cmd = :Next
    when "x", "X"
      @cmd = :Start
    when "r", "R"
      @cmd = :Reset
      @step = 0
      view_clear
      random
    when "q", "Q"
      Curses.close_screen
      exit
    end 
  end
end

# Curses init
Curses.init_screen
Curses.crmode
Curses.noecho
Curses.curs_set(0)  # 0:invisible, 1:visible, 2:very visible

# set color
Curses.start_color
Curses.init_color(Curses::COLOR_GREEN, 0, 999, 0)
Curses.init_pair(1, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
Curses.init_pair(2, Curses::COLOR_WHITE, Curses::COLOR_BLACK)

# get window size
w_max = Curses.cols
h_max = Curses.lines
width = ARGV[0] ? [ARGV[0].to_i, w_max].min : w_max
height = ARGV[1] ? [ARGV[1].to_i, h_max].min : h_max

begin
  lc = LifegameCurses.new(width, height)
  lc.random
  loop do
    lc.getcmd
    lc.view_update

    # Resume LIFEGAME, when the cells doesn't increase or decrease 
    # due to oscillator or still life.
    if lc.no_change > NO_CHANGE_MAX
      lc.resume_count_down
      lc.view_clear
      lc.random
    end

    sleep 0.16
  end

rescue
  Curses.close_screen
  puts "error"
end
