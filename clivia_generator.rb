# do not forget to require your gem dependencies
require "htmlentities"
require "json"
require "terminal-table"
require "colorize"
# do not forget to require_relative your local dependencies
require_relative "presenter"
require_relative "requester"
require_relative "clivia_services"

class CliviaGenerator
  # maybe we need to include a couple of modules?
  include Presenter
  include Requester

  def initialize(filename)
    # we need to initialize a couple of properties here
    @questions = []
    @decoder = HTMLEntities.new
    @score = 0
    @filename = filename
    File.open(@filename, "w") unless File.exist?(@filename)
    jsonstring = File.read(@filename)
    @report = jsonstring.empty? ? [] : JSON.parse(jsonstring)
   
  end

  def start
    # welcome message
    print_welcome
    # prompt the user for an action
    action = select_main_menu_action
    # keep going until the user types exit
    until action == "exit"
      case action
      when "random" then random_clivia
      when "scores" then print_scores
      end
      print_welcome
      action = select_main_menu_action
    end
  end

  def random_clivia
    # load the questions from the api
    # questions are loaded, then let's ask them
    load_questions.each do |questions|
      category = @decoder.decode(questions[:category])
      difficulty = @decoder.decode(questions[:difficulty])
      puts "Category: #{category.colorize(:yellow)} | Difficulty: #{difficulty.colorize(:yellow)}"
      
      ask_questions(questions)
      puts ""
    end
    print_score(@score)
    puts "-" * 50
    will_save?(@score)
    puts ""
  end

  def ask_questions(questions)
    # ask each question
    correct_index = 0
    selected_alternative = ""
    puts "Question: #{@decoder.decode(questions[:question])}"
    @alternatives = questions[:incorrect_answers].push(questions[:correct_answer]).shuffle
    @alternatives.each_with_index.map do |e, index|
      puts "#{index + 1}. #{@decoder.decode(e)}"
      correct_index = index + 1 if e == questions[:correct_answer]
    end
    selection = get_number(questions[:incorrect_answers].length + 1)
    @alternatives.each_with_index.map do |e, index|
      selected_alternative = e if selection == index + 1
    end
    ask_questions_refactorizing(selection, correct_index, selected_alternative, questions)
  end

  def ask_questions_refactorizing(selection, correct_index, selected_alternative, questions)
    # if response is correct, put a correct message and increase score
    if selection == correct_index
      puts "#{@decoder.decode(selected_alternative)}... Correct!".colorize(:green)
      @score += 10
    # if response is incorrect, put an incorrect message, and which was the correct answer
    else
      puts "#{selected_alternative}... Incorrect!".colorize(:red)
      puts "The correct answer was: #{questions[:correct_answer].colorize(:green)}"
    end
  end

  def save(data)
    # write to file the scores data
    @report << data
    File.write(@filename, @report.to_json)
    @score = 0
    puts "Scores saved!".colorize(:green)
  end

  def load_questions
    # ask the api for a random set of questions and parse it
    @questions = CliviaAPI.index[:results]
  end

  def print_scores
    jsonstring = File.read(@filename)
    @report = jsonstring.empty? ? [] : JSON.parse(jsonstring)
    table = Terminal::Table.new
    table.title = "Top Scores"
    table.headings = ["Name", "Score"]
    report_sorted = @report.sort { |x, y| y["score"] <=> x["score"] }.map { |unit| [unit["name"], unit["score"]] }
    report_fifth = []
    report_sorted.each_with_index { |e, index| (report_fifth << e if index < 5) }
    table.rows = report_fifth.map { |row| row.map { |cell| cell.to_s.colorize(:yellow) } } 
    puts table.to_s.colorize(:yellow)  # Aplicar color azul a toda la tabla
    puts ""
  end
end

