#>>START-HERE
# The above line MUST be the first line in the file (it can be moved for testing purposes).

# Reflections is a piece that is meant to use algorithmic composition to sonify itself.
# It uses a framework called Sonic Pi that from what I understand is a Ruby wrapper around SuperCollider. This code will not run in a standard ruby enviroment.

RESERVED_WORDS = ['__ENCODING__', '__LINE__', '__FILE__', 'BEGIN', 'END', 'alias', 'and', 'begin', 'break', 'case', 'class', 'def', 'defined?', 'do', 'else', 'elsif', 'end', 'ensure', 'false', 'for', 'if', 'in', 'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 'self', 'super', 'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield']

VOICES = {
  normal: {synth: :saw},
  comment: {synth: :fm, play_opts: {divisor: 1, depth: 0.5, attack_level: 0.8}},
  keyword: {},
}
MODIFIERS = [:string, :method, :block, :parens]

Instruction = Struct.new(:pitch, :voice, :modifiers)

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

  def play_note(instruction)
    if VOICES[instruction.voice][:synth]
      @sp.use_synth VOICES[instruction.voice][:synth]
    end

    @sp.play instruction.pitch, VOICES[instruction.voice][:play_opts] || {}
  end
end

# Responsible for parsing the code as given
class Parser
  # Take in the sonic pi context to have access to its methods
  def initialize(sp)
    @sp = sp
    @instructions = []
  end

  def parse_file
    # Note: This will break if the file has been renamed.
    f = File.open(File.absolute_path(__dir__) + '/reflections.rb')

    started = false
    f.read.each_line{ |line|
      if started || line.match(/#>>START-HERE\s*$/)
        started = true
        parse_line line
      end

      break if line.match(/#>>END-HERE\s*$/)
    }

    f.close
  end

  def parse_line(line)

    voice = line.match(/^\s*#/) ? :comment : :normal

    line.each_line(' '){ |word|
      voice = RESERVED_WORDS.include?(word) && voice != :normal ? :keyword : voice

      word.each_char{ |letter|
        @instructions << Instruction.new(get_pitch(letter), voice)
      }
    }
  end

  def get_pitch(letter)
    letters = 'abcdefghijklmnopqrstuvwxyz'
    return letters.index(letter.downcase) + 59
  end

  def instructions
    return @instructions
  end
end

# Main

parser = Parser.new self
parser.parse_file

print "Number of instructions: #{parser.instructions}"

renderer = Renderer.new self

renderer.play_instructions parser.instructions

# eeeeeeeeeeeeeeeeeee

# The below line MUST be the last line in the file (it can be moved for testing purposes).
#>>END-HERE
