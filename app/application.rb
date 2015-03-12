require 'opal'
require 'opal-parser'
require 'pp'
require 'two'
require 'browser'
require 'browser/interval'
require 'rrobots/rrobots'
require 'monkey_patches'

class Application
  attr_accessor :started

  def initialize
    @started = false
  end

  def load_ducks
    @ducks = []
    @ducks << SittingDuck
    load_text_bot

    start_battle unless started
  end

  private

  def load_text_bot
    eval $document['brains'].inner_html
    # @todo Need to parse out class name dynamically
    @ducks << MyDuck
  end

  def run_in_gui(battlefield, xres, yres, speed_multiplier)
    arena = TkArena.new(battlefield, xres, yres, speed_multiplier)
    game_over_counter = battlefield.teams.all?{|k,t| t.size < 2} ? 250 : 500
    outcome_printed = false
    arena.on_game_over{|battlefield|
      unless outcome_printed
        print_outcome(battlefield)
        outcome_printed = true
      end
      exit 0 if game_over_counter < 0
      game_over_counter -= 1
    }
    arena.run
  end

  def print_outcome(battlefield)
    winners = battlefield.robots.find_all{|robot| !robot.dead}
    puts
    if battlefield.robots.size > battlefield.teams.size
      teams = battlefield.teams.find_all{|name,team| !team.all?{|robot| robot.dead} }
      puts "winner_is:     { #{
        teams.map do |name,team|
          "Team #{name}: [#{team.join(', ')}]"
        end.join(', ')
      } }"
      puts "winner_energy: { #{
        teams.map do |name,team|
          "Team #{name}: [#{team.map do |w| ('%.1f' % w.energy) end.join(', ')}]"
        end.join(', ')
      } }"
    else
      puts "winner_is:     [#{winners.map{|w|w.name}.join(', ')}]"
      puts "winner_energy: [#{winners.map{|w|'%.1f' % w.energy}.join(', ')}]"
    end
    puts "elapsed_ticks: #{battlefield.time}"
    puts "seed :         #{battlefield.seed}"
    puts
    puts "robots :"
    battlefield.robots.each do |robot|
      puts "  #{robot.name}:"
      puts "    damage_given: #{'%.1f' % robot.damage_given}"
      puts "    damage_taken: #{'%.1f' % (100 - robot.energy)}"
      puts "    kills:        #{robot.kills}"
    end
  end

  def start_battle
    return if started
    @started = true
    xres = yres = 400
    seed = 0
    speed_multiplier = 1
    timeout = 50000

    battlefield = Battlefield.new xres * 2, yres * 2, timeout, seed

    @ducks.each_with_index do |duck, index|
      battlefield << RobotRunner.new(duck.new, battlefield, index)
    end

    puts "Battle started between #{@ducks.join(' and ')}"

    run_in_gui battlefield, xres, yres, speed_multiplier
  end
end

a = Application.new

$document['run'].on :click do |event|
  a.load_ducks
end

