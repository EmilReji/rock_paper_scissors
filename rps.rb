VALID_CHOICES = %w(rock paper scissors spock lizard).freeze
WINNER_HASH = { 'rock' => %w(lizard scissors),
                'paper' => %w(rock spock),
                'scissors' => %w(paper lizard),
                'spock' => %w(rock scissors),
                'lizard' => %w(paper spock) }.freeze

def prompt(message)
  Kernel.puts("=> #{message}")
end

# complex method
=begin
def win?(first, second)
  (first == 'rock' && second == 'lizard') ||
    (first == 'lizard' && second == 'spock') ||
    (first == 'spock' && second == 'scissors') ||
    (first == 'scissors' && second == 'paper') ||
    (first == 'paper' && second == 'rock') ||
    (first == 'rock' && second == 'scissors') ||
    (first == 'lizard' && second == 'paper') ||
    (first == 'spock' && second == 'rock') ||
    (first == 'scissors' && second == 'lizard') ||
    (first == 'paper' && second == 'spock')
end
=end
def win?(first, second)
  WINNER_HASH[first].include?(second)
end

def display_results(player, computer)
  output = nil
  if win?(player, computer)
    output = 'You won!'
  elsif player == computer
    output = 'You tied!'
  else
    output = 'You lost!'
  end
  output
end

def valid_choice?(choice)
  # method is used as a boolean and to return full choice value??
  choices = VALID_CHOICES.select do
    |valid_choice| valid_choice.start_with?(choice)
  end
  if choices.length == 1
    choices[0]
  else
    false
  end
=begin
  # incomplete solution;
  bool = false
  VALID_CHOICES.each { |valid_choice|
    bool = valid_choice.start_with?(choice)
    return bool if bool
  }
  bool
=end
  # old solution
  # VALID_CHOICES.include?(choice)
end

player_score = 0
computer_score = 0
loop do
  choice = nil
  loop do
    prompt("Choose one: #{VALID_CHOICES.join(', ')}. Please note that the inputs are case sensitive.")
    prompt("When you enter the values, ensure no ambiguity. Ex. \"s\" has two potential answers and is invalid,")
    choice = Kernel.gets().chomp()
    if valid_choice?(choice)
      choice = valid_choice?(choice)
      break
    else
      prompt("That's not a valid choice.")
    end
  end

  computer_choice = VALID_CHOICES.sample
  prompt("You chose: #{choice}; Computer chose: #{computer_choice}")

  winning_message = display_results(choice, computer_choice)
  prompt(winning_message)

  if winning_message == 'You won!'
    player_score += 1
  elsif winning_message == 'You lost!'
    computer_score += 1
  end

  # prompt("Your score is #{player_score} and the computer score i #{computer_score}") # testing

  if player_score >= 5
    prompt('You are the ultimate winner!')
    break
  elsif computer_score >= 5
    prompt('The computer is the ultimate winner!')
    break
  end

  prompt('Do you want to play again?')
  answer = Kernel.gets().chomp()
  break unless answer.downcase().start_with?('y')
end
