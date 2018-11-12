#>>START-HERE
# The above line MUST be the first line in the file (it can be moved for testing purposes).

# Reflections is a piece that is meant to use algorithmic composition to sonify itself.
# It uses a framework called Sonic Pi that from what I understand is a Ruby wrapper around SuperCollider. This code will not run in a standard ruby enviroment.

RESERVED_WORDS = ['__ENCODING__', '__LINE__', '__FILE__', 'BEGIN', 'END', 'alias', 'and', 'begin', 'break', 'case', 'class', 'def', 'defined?', 'do', 'else', 'elsif', 'end', 'ensure', 'false', 'for', 'if', 'in', 'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 'self', 'super', 'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield']

VOICES = {
  normal: {synth: :fm, play_opts: {amp: 0.6}},
  comment: {synth: :fm, play_opts: {divisor: 1, depth: 0.5, attack_level: 0.7, attack: 0.15, amp: 0.5}},
  special_character: {synth: :saw},
}

MODIFIERS = {
  uppercase: {play_opts: {attack: 0, attack_level: 1, sustain: 0.05, sustain_level: 0.5, release: 0.001, amp: 1}},
  keyword: {play_opts: {amp: 1}},
  string: {},
  method: {},
  block: {},
  parens: {},
}

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

    opts = VOICES[instruction.voice][:play_opts] || {}

    instruction.modifiers.each{ |modifier|
      opts.merge(MODIFIERS[modifier])
    }
    @sp.play instruction.pitch, opts
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
      modifiers = []
      if voice != :comment
        modifiers << :keyword
      end

      word.each_char{ |letter|
        modifiersmodifiers = []
        voicevoice = voice
        if letter.match(/[A-Z]/)
          modifiersmodifiers << :uppercase
        elsif !letter.match(/([a-zA-Z]|\s)/) && voice != :comment
          voicevoice = :special_character
        end

        @instructions << Instruction.new(get_pitch(letter), voicevoice, modifiers + modifiersmodifiers)
      }
    }
  end

  def get_pitch(letter)
    if letter.match(/[A-Za-z]/)
      letters = '_abcdefghijklmnopqrstuvwxyz'
      return letters.index(letter.downcase) + 58
    elsif !letter.match(/([a-zA-Z]|\s)/)
      return letter.codepoints[0]
    end

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

# The below line MUST be the last line in the file (it can be moved for testing purposes).
#>>END-HERE
