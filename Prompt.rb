require 'rubygems'
require 'rainbow/ext/string'
Rainbow.enabled = true

class Prompt

  @currentPrompter = nil

  def out(text, options = {})
    if(text.is_a? Prompter)
      text.drawer
      return true
    end

    return false unless(canPrompt?)

    if(options[:r])
      text = "\r" + text
    end

    STDOUT << text
  end

  def canPrompt?
    return @currentPrompter == nil
  end

  def setPrompter(prompter)
    @currentPrompter = prompter
  end

  @@instance = nil
  class << self
    def load
      @@instance = self.new unless(@@instance)
      return @@instance
    end
  end
end

class Prompter

  def initialize(prompt)
    @prompt = prompt
  end

  def draw
    @prompt.out(self)
  end

end


class PromptLoadingbar < Prompter

  def initialize(prompt, options = {})
    super(prompt)
    @length = options[:length] ? options[:length] : 50
    @percentage = options[:percentage] ? options[:percentage].to_f : 0.to_f
    @text = options[:text] ? options[:text] : ""
    @prompt.out(self)
  end

  def setPercentage(newPercentage)
    @percentage = newPercentage.to_f
    @prompt.out(self)
  end

  def setLength(newLength)
    @length = length
    @prompt.out(self)
  end

  def drawer
    STDOUT << "\r"
    STDOUT <<  (@text == "" ? "" : @text + " - ") + "[ "
    for i in 1..@length do
      STDOUT << ((@length*(@percentage/100)).round >= i ? "#" : " ")
    end
    STDOUT <<  " #{@percentage.round}%]"
  end

end
