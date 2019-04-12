require_relative './lifegame'
require 'io/console/size'

# command option
# ruby main.rb <width> <height>

NO_CHANGE_MAX = 50  # Upper limit of no change
COUNT_DOWN = 10
CLEAR_SCREEN = "\e[2J\e[0;0H"

# window size
h, w = IO::console_size
w_max = (w / 2) -1
h_max = h - 3
if ARGV[0]
  width = ARGV[0].to_i
  width = w_max if width > w_max
else
  width = w_max
end
if ARGV[1]
  height = ARGV[1].to_i
  height = h_max if height > h_max
else
  height = h_max
end

def resume_message(obj, n)
  s = "Life activities "
  s += (obj.cur_alive == 0) ? "are inactive.\n" : "have stopped.\n"
  s += "Generation: #{obj.step - NO_CHANGE_MAX}, Alive: #{obj.cur_alive},\n"
  s += "Countdown for Resume : #{COUNT_DOWN - n} "
end

def resume_count_down(obj, width, height)
  COUNT_DOWN.times do |n|
    puts "\e[#{height - 2};#{width}H"
    puts resume_message(obj, n)
    sleep 1.0
  end
end

life = Lifegame.new(width, height)
life.random

loop do
  puts CLEAR_SCREEN
  puts "Generation: #{life.step}, Alive: #{life.cur_alive}"
  puts life.to_s
  life.update

  # Resume LIFEGAME, when the cells doesn't increase or decrease 
  # due to oscillator or still life.
  if life.no_change > NO_CHANGE_MAX
    resume_count_down(life, width, height)
    life.random
  end

  sleep 0.16
end







