WINNING_SCORE = 3
VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

class Move
  WINNER_TO_LOSERS = {
    'rock' => ['scissors', 'lizard'],
    'paper' => ['rock', 'spock'],
    'scissors' => ['paper', 'lizard'],
    'spock' => ['rock', 'scissors'],
    'lizard' => ['spock', 'paper']
  }
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    WINNER_TO_LOSERS[value].include?(other_move.value) &&
      value != other_move.value
  end

  def <(other_move)
    !WINNER_TO_LOSERS[value].include?(other_move.value) &&
      value != other_move.value
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score
  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  SHORTHAND = ['r', 'p', 'sc', 'sp', 'l']

  def choose
    choice = nil
    loop do
      puts "Please choose (r)ock, (p)aper, (sc)issors, (sp)ock, or (l)izard:"
      choice = gets.chomp.downcase.strip
      break if valid_choice?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(get_valid_choice(choice))
  end

  private

  def set_name
    n = nil
    loop do
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def valid_choice?(choice)
    VALUES.include?(choice) || SHORTHAND.include?(choice)
  end

  def get_valid_choice(choice)
    return VALUES[SHORTHAND.index(choice)] if SHORTHAND.include?(choice)
    choice
  end
end

PERSONALITIES = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5']

class Personality
  attr_accessor :comp_name, :weights
  def initialize(comp_name)
    @comp_name = comp_name
    set_weights
  end

  private

  def set_weights
    case comp_name
    when PERSONALITIES[0]
      @weights = [100, 0, 0, 0, 0]
    when PERSONALITIES[1]
      @weights = [10, 0, 80, 10, 0]
    when PERSONALITIES[2]
      @weights = [20, 20, 20, 20, 20]
    when PERSONALITIES[3]
      @weights = [0, 0, 0, 100, 0]
    when PERSONALITIES[4]
      @weights = [55, 15, 15, 15, 0]
    end
  end
end

class Computer < Player
  attr_accessor :choices, :personality
  def initialize
    super
    @personality = Personality.new(name)
    create_choices
  end

  def decrement_weight(item, percent)
    amt_remove = percent / 100.0
    index = VALUES.index(item)
    personality.weights[index] *= amt_remove
    personality.weights[index] = personality.weights[index].to_i
    create_choices
  end

  def choose
    str_choice = choices.flatten.sample
    self.move = Move.new(str_choice)
  end

  private

  def create_choices
    self.choices = [[], [], [], [], []]
    personality.weights.each_with_index do |weight, index|
      weight.times { |_| choices[index] << VALUES[index] }
    end
  end

  def set_name
    self.name = PERSONALITIES.sample
  end
end

class State
  attr_reader :human_choice, :computer_choice, :winner

  def initialize(human_choice, computer_choice, winner)
    @human_choice = human_choice
    @computer_choice = computer_choice
    @winner = winner
  end
end

class History
  attr_accessor :states
  def initialize
    @states = []
  end

  def add(state_obj)
    states << state_obj
  end

  def percent_lost_computer_choice(choice)
    selected_states = states.select do |state_obj|
      state_obj.computer_choice == choice && state_obj.winner == 'Human'
    end
    100 * (selected_states.length.to_f / states.length)
  end
end

class Rule
  attr_reader :choice, :loss_percent, :decrement_percent

  def initialize(choice, loss_percent, decrement_percent)
    @choice = choice
    @loss_percent = loss_percent
    @decrement_percent = decrement_percent
  end

  def to_s
    "If computer loses #{loss_percent}% or more when computer chooses #{choice},
    then remove #{decrement_percent}% of #{choice}'s weight."
  end
end

class RPSGame
  attr_accessor :human, :computer, :history, :rule

  def initialize
    @human = Human.new
    @computer = Computer.new
    @history = History.new
    @rule = Rule.new(VALUES[0], 60, 50)
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      change_score
      display_winner
      display_current_score
      update_history
      check_rule
      break unless play_again?
    end
    display_final_winner
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard #{human.name}!"
    puts "The winner of this game must win #{WINNING_SCORE} rounds. Good luck!"
  end

  def display_goodbye_message
    # rubocop:disable Metrics/LineLength
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard #{human.name}. Good bye!"
    # rubocop:enable Metrics/LineLength
  end

  def display_moves
    puts "#{human.name} choose: #{human.move}"
    puts "#{computer.name} choose: #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{human.name} lost!"
    else
      puts "It's a tie!"
    end
  end

  def change_score
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def display_current_score
    puts "\nCurrent score:"
    puts "#{human.name} has won #{human.score} times."
    puts "#{computer.name} has won #{computer.score} times."
  end

  def display_final_winner
    puts "\nFinal Result:"
    if human.score > computer.score
      puts "You have beat #{computer.name} with #{human.score} wins!"
    else
      puts "#{computer.name} has beat you with #{computer.score} wins!"
    end
  end

  def play_again?
    human.score < WINNING_SCORE && computer.score < WINNING_SCORE
  end

  def winner
    return "Human" if human.move > computer.move
    return "Computer" if human.move < computer.move
    "Tie"
  end

  def update_history
    current_state = State.new(human.move.value, computer.move.value, winner)
    history.add(current_state)
  end

  def apply_rule
    computer.decrement_weight(rule.choice, rule.decrement_percent)
  end

  def check_rule
    per_lost = history.percent_lost_computer_choice(rule.choice)
    apply_rule if per_lost >= rule.loss_percent
  end
end

RPSGame.new.play
