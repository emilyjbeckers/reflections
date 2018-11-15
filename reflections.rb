#>>START-HERE
# The above line MUST be the first line in the file (it can be moved for testing purposes).

# Reflections is a piece that is meant to use algorithmic composition to sonify itself.
# It uses a framework called Sonic Pi that from what I understand is a Ruby wrapper around SuperCollider. This code will not run in a standard ruby enviroment.

RESERVED_WORDS = ['__ENCODING__', '__LINE__', '__FILE__', 'BEGIN', 'END', 'alias', 'and', 'begin', 'break', 'case', 'class', 'def', 'defined?', 'do', 'else', 'elsif', 'end', 'ensure', 'false', 'for', 'if', 'in', 'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return', 'self', 'super', 'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield']

VOICES = {
  normal: {synth: :fm, play_opts: {amp: 0.6, attack: 0.01}},
  comment: {synth: :fm, play_opts: {divisor: 1, depth: 0.5, attack_level: 0.7, attack: 0.15, amp: 0.5}},
  special_character: {synth: :saw},
}

# static modifiers
MODIFIERS = {
  uppercase: {play_opts: {attack: 0.001, attack_level: 1, sustain: 0.05, sustain_level: 0.5, release: 0.001, amp: 3}, wait: 1.2},
  keyword: {play_opts: {amp: 1, sustain: 0.2}, wait: 3},
  whitespace: {wait: 2},
  string: {play_opts: {divisor: 2.2}},
  symbol: {play_opts: {divisor: 2.1}},
}

# Voice and modifiers are passed in as keys to above hashes
# Pitch and effects are passed in as params that sonic pi would use more directly
NoteInstruction = Struct.new(:pitch, :voice, :modifiers, :effects)

# Responsible for rendering out the music it is given
class Renderer
  # Take in the sonic pi context to have access to all its specific methods, as these aren't actually added to the library but methods added on the runtime.
  def initialize(sp)
    @sp = sp
    @fx = {}
  end

  # Play the instructions in the given line
  def play_instructions(instructions)
    @sp.with_fx :level, amp: 1, amp_slide: 3 do |level|
      @sp.with_fx :pan, pan: 0 do |pan|
        @fx[:level] = level
        @fx[:pan] = pan
        instructions.each do |instruction|
          play_note instruction
          wait instruction
        end
      end
    end
  end

  def play_note(instruction)
    # set synth
    if VOICES[instruction.voice][:synth]
      @sp.use_synth VOICES[instruction.voice][:synth]
    end

    # set effects
    if instruction.effects
      instruction.effects.each do |effect|
        @sp.control @fx[effect[:name]], effect[:opts]
      end
    end

    # build note options
    opts = VOICES[instruction.voice][:play_opts] || {}
    instruction.modifiers.each do |modifier|
      if MODIFIERS[modifier]
        opts.merge(MODIFIERS[modifier][:play_opts] || {})
      elsif DYNAMIC_MODIFIERS[modifier[:name]]
        opts.merge(DYNAMIC_MODIFIERS[modifier[:name]].call modifier[:value])
      end
    end

    # play the note
    @sp.play instruction.pitch, opts
  end

  def wait(instruction)
    wait = 0.1
    instruction.modifiers.each do |modifier|
      if MODIFIERS[modifier].include? :wait
        wait *= MODIFIERS[modifier][:wait]
      end
    end
    @sp.sleep wait
  end
end

# Responsible for parsing the code as given
class Parser
  # Take in the sonic pi context to have access to its methods
  def initialize(sp)
    @sp = sp
    @instructions = []
  end

  def instructions
    return @instructions
  end

  def parse_file
    # Note: This will break if the file has been renamed.
    f = File.open(File.absolute_path(__dir__) + '/reflections.rb')

    started = false
    f.read.each_line do |line|
      if started || line.match(/#>>START-HERE\s*$/)
        started = true
        parse_line line
      end

      break if line.match(/#>>END-HERE\s*$/)
    end

    f.close
  end

  def parse_line(line)
    voice = line.match(/^\s*#/) ? :comment : :normal
    is_string = false
    indent_fx = make_indent_fx line.match(/^(\s*).*$/)[1].length

    line.each_line(' ') do |word|
      modifiers = []
      groups = {parens: 0, brackets: 0, pipes: 0}
      if voice != :comment && RESERVED_WORDS.include?(word)
        modifiers << :keyword
      elsif word.start_with?(':') || word.end_with?(':')
        modifiers << :symbol
      end

      word.each_char do |letter|
        modifiersmodifiers = []
        voicevoice = voice

        if letter.match(/[A-Z]/)
          modifiersmodifiers << :uppercase
        elsif !letter.match(/([a-zA-Z]|\s)/) && voice != :comment
          voicevoice = :special_character
        elsif letter.match(/\s/)
          modifiersmodifiers << :whitespace
        elsif letter == "'" || letter == '"'
          is_string = !is_string
        end

        if !is_string && letter == '('
          groups[:parens] += 1;
        end
        groups_fx = make_groups_fx groups

        modifiersmodifiers << :string if is_string

        @instructions << NoteInstruction.new(get_pitch(letter), voicevoice, modifiers + modifiersmodifiers, [indent_fx, groups_fx])

        if !is_string && letter == ')'
          groups[:parens] -= 1;
        end
      end
    end
  end

  def make_indent_fx(indent)
    amp = 1 - (0.05 * indent)
    return {name: :level, opts: {amp: amp}}
  end

  def make_groups_fx(group)
    paren_pan = (-0.2 * group[:parens])
    bracket_pan = (0.3 * group[:brackets])
    pipes_pan = (0.5 * group[:pipes])

    return {name: :pan, opts: {pan: paren_pan + bracket_pan + pipes_pan}}
  end

  def get_pitch(letter)
    if letter.match(/[A-Za-z]/)
      letters = '_abcdefghijklmnopqrstuvwxyz'
      return letters.index(letter.downcase) + 58
    elsif !letter.match(/([a-zA-Z]|\s)/)
      return letter.codepoints[0]
    end
  end
end

# Main

parser = Parser.new self
parser.parse_file

renderer = Renderer.new self

renderer.play_instructions parser.instructions

# The below line MUST be the last line in the file (it can be moved for testing purposes).
#>>END-HERE
