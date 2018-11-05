# Reflections is a piece that is meant to use algorithmic composition to sonify itself.
# It uses a framework called Sonic Pi that from what I understand is a Ruby wrapper around SuperCollider.

# Responsible for rendering out the music it is given
class Renderer
  # Take in the sonic pi context to have access to all its specific methods, as these aren't actually added to the library but methods added on the runtime.
  def initialize(sp)
    @sp = sp
  end

  # Play the instructions in the given line
  def play_instructions(instructions)
    instructions.each{ |instruction|
      play_note instruction
      @sp.sleep 0.1
    }
  end

  def play_note(pitch, opts = {})
    @sp.play pitch, opts
  end
end

# Responsible for parsing the code as given
class Parser
  # Load this file
  def initialize(sp)
    @sp = sp
    @instructions = []
  end

  def parse_file
    # Note: This will break if the file has been renamed.
    f = File.open(File.absolute_path(__dir__) + '/reflections.rb')

    f.read.each_char{ |letter|
      letters = 'abcdefghijklmnopqrstuvwxyz'
      @instructions << letters.index(letter) + 59
    }

    f.close
  end

  def instructions
    return @instructions
  end
end

# Main

parser = Parser.new self
parser.parse_file

renderer = Renderer.new self

renderer.play_instructions parser.instructions

# eeeeeeeeeeeeeeeeeee
