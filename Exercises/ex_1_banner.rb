class Banner

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def horizontal_rule
    horizontal_array = []
    message.size.times { horizontal_array << '-' }
    "+-#{horizontal_array.join('')}-+"
  end

  def empty_line
    empty_array = []
    message.size.times { empty_array << ' ' }
    "| #{empty_array.join('')} |"
  end

  def message_line
    "| #{@message} |"
  end
end

banner = Banner.new('To boldly go where no one has gone before.')

puts banner
puts
# +--------------------------------------------+
# |                                            |
# | To boldly go where no one has gone before. |
# |                                            |
# +--------------------------------------------+

banner = Banner.new('')
puts banner
puts
# +--+
# |  |
# |  |
# |  |
# +--+
