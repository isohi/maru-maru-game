require './board'
require 'highline'
require 'io/console'

class Game
  def initialize
    @h = HighLine.new
    @commands = []
  end

  def detect_pos
    @board.each_with_index do |line, y|
      line.each_with_index do |char, x|
        case char
        when "S"
          @x = x
          @y = y
        end
      end
    end
  end

  def print_board
    @board.each_with_index do |line, y|
      line.each_with_index do |char, x|
        case char
        when "S", "G", "O"
          if @x == x && @y == y
            print @h.color(char, :green)
          else
            print @h.color(char, :white)
          end
        when "."
          if @x == x && @y == y
            print @h.color(char, :red)
          else
            print @h.color(char, :white)
          end
        end
      end
      print "\n"
    end
  end

  def input
    cls
    puts "#{@h.color("あおむし", :green)}に"
    puts "スタート(S)からゴール(G)までのみちをおしえてあげよう！"
    puts "Oがとおれるよ。"
    puts "やじるし（↑↓←→）をえらんで、さいごにエンター(⏎)をおしてね。"

    print_board

    arrows = {A: '↑', B: '↓', C: '→', D: '←'}
    while (key = STDIN.getch)
      exit if key == "\C-c"

      if key == "\e"
        second_key = STDIN.getch

        if second_key == "["
          key = STDIN.getch
          key = arrows[key.intern] || "esc: [#{key}"
        else
          key = "esc: #{second_key}"
        end
      end
      if key == "\r"
        break
      end

      print "#{key}"
      @commands << key
    end
  end

  def print_command
    return if @commands.length == 0
    @commands.each_with_index do |command, index|
      print @h.color(command, (index == 0) ? :green : :white)
    end
    puts
  end

  def wait_enter
    puts "エンター(⏎)をおすと、すすむよ"
    while (key = STDIN.getch) != "\r"
      exit if key == "\C-c"
    end
  end

  def check_pos
    case @board[@y][@x]
    when "G"
      puts "ゴール！おめでとう！"
      wait_enter
    when "X", "."
      puts @h.color("ざんねん、やりなおし", :red)
      wait_enter
    when "O"
      sleep(1)
    end
  end

  def move
    cls
    print_board
    print_command
    wait_enter

    while (command = @commands.shift) != nil
      case command
      when "↑"
        @y -= 1
      when "↓"
        @y += 1
      when "←"
        @x -= 1
      when "→"
        @x += 1
      end
      cls
      print_board
      print_command
      check_pos
    end
  end

  def cls
    puts "\e[H\e[2J"
  end

  def init_board(i)
    @board = []

    board = BOARD[i].dup
    board.each do |line|
      chars = line.split(//)
      @board << chars
    end
    detect_pos
  end

  def select_map
    ids = (1..BOARD.length).to_a
    ids_str = ids.map{_1.to_s}

    cls
    puts "どのもんだいがいい？"
    puts "#{ids_str.join(",")}からえらんでね"
    while (key = STDIN.getch)
      case key
      when *ids_str
        init_board(key.to_i - 1)
        break
      when "\C-c"
        exit
      end
    end
  end

  def main
    while(1)
      select_map
      input
      move
    end
  end
end

Game.new.main
