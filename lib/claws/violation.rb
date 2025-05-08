class Violation
  attr_accessor :file, :name, :line, :snippet, :description

  def initialize(line:, description:, file: nil, name: nil, snippet: nil)
    @file = file
    @name = name
    @line = line
    @snippet = snippet
    @description = description
  end
end
