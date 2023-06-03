module Presenter
  def print_welcome
    puts [
      "#" * 40,
      "#   Welcome to Validation Clibrary   #",
      "#" * 40
    ].join("\n")
  end

  def print_score(score)
    puts "Well done! Your score is #{score}"
  end
end
