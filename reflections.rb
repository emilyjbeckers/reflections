#>>START-HERE
# The above line MUST be the first line in the file (it can be moved for testing purposes).

# This code must be run in a sonic pi context. It will not run in a standard ruby environment

# Incomplete set
RESERVED_WORDS = ['break', 'case', 'class', 'def', 'do', 'else', 'elsif', 'end','false', 'for', 'if', 'nil', 'redo', 'return', 'self', 'then', 'true', 'when', 'while', 'yield']

VOICES = {
  normal: {synth: :fm, play_opts: {amp: 0.6, attack: 0.01}},
  comment: {synth: :fm, play_opts: {divisor: 1, depth: 0.5, attack_level: 0.7, attack: 0.15, amp: 0.5}},
  special_character: {synth: :saw},
}

# Voice and modifiers are passed in as keys to above hashes
# Pitch and effects are passed in as params that sonic pi would use more directly
NoteInstruction = Struct.new(:pitch, :voice, :modifiers, :effects)

# Responsible for rendering out the music it is given
class Renderer
  # Take in the sonic pi context to have access to all its methods
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

# Putting the modifiers here instead of at the top for musical reasons
MODIFIERS = {
  uppercase: {play_opts: {attack: 0.001, attack_level: 1, sustain: 0.05, sustain_level: 0.5, release: 0.001, amp: 3}, wait: 1.2},
  keyword: {play_opts: {amp: 1, sustain: 0.2}, wait: 3},
  whitespace: {wait: 2},
  string: {play_opts: {divisor: 2.2}},
  symbol: {play_opts: {divisor: 2.1}},
}

# Responsible for parsing in and putting together instructions that the renderer takes in
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

  # This thing is a monster I'm sorry
  # I like the indent depth
  def parse_line(line)
    voice = line.match(/^\s*#/) ? :comment : :normal
    is_string = false
    indent_fx = make_indent_fx line.match(/^(\s*).*$/)[1].length

    line.each_line(' ') do |word|
      mods = []
      groups = {parens: 0, brackets: 0, pipes: 0}
      if voice != :comment && RESERVED_WORDS.include?(word)
        mods << :keyword
      elsif word.start_with?(':') || word.end_with?(':')
        mods << :symbol
      end

      word.each_char do |letter|
        char_mods = []
        char_voice = voice

        if letter.match(/[A-Z]/)
          char_mods << :uppercase
        elsif !letter.match(/([a-zA-Z]|\s)/) && voice != :comment
          char_voice = :special_character
        elsif letter.match(/\s/)
          char_mods << :whitespace
        elsif letter.match(/['"]/)
          is_string = !is_string
        end

        if !is_string && letter == '('
          groups[:parens] += 1;
        end
        groups_fx = make_groups_fx groups

        char_mods << :string if is_string

        @instructions << NoteInstruction.new(get_pitch(letter), char_voice, mods + char_mods, [indent_fx, groups_fx])

        if !is_string && letter == ')'
          groups[:parens] -= 1;
        end
      end
    end
  end

  def make_indent_fx(indent)
    return {name: :level, opts: {amp: 1 - (0.05 * indent)}}
  end

  def make_groups_fx(group)
    pan = (-0.2 * group[:parens])
    pan += (0.3 * group[:brackets])
    pan += (0.5 * group[:pipes])

    return {name: :pan, opts: {pan: pan}}
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
