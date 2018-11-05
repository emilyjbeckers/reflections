# Reflections is a piece that is meant to use algorithmic composition to sonify itself.
# It uses a framework called Sonic Pi that from what I understand is a Ruby wrapper around SuperCollider.

# Responsible for rendering out the music it is given
class Renderer
  # Take in the sonic pi context to have access to all its specific methods, as these aren't actually added to the library but methods added on the runtime.
  def initialize(sp)
    @sp = sp
  end

  # Play the instructions in the given line
  def play_line(line)
    play_note 60
    @sp.sleep 3
  end

  def play_note(pitch, opts = {})
    @sp.play pitch, opts
  end
end

# Responsible for parsing the code as given
class Parser
  # Load this file
  def initialize
  end

  # return the next line in the renderer format, or :eof if there are no more lines in the file
  def next_line
    return :eof
  end

end

# Main

parser = Parser.new
renderer = Renderer.new self

renderer.play_note 60

file_line = parser.next_line
while file_line != :eof do
  renderer.play_line file_line

  file_line = parser.next_line
end
