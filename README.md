# Reflections

This is an algorithmic composition piece in which the code sonifies itself. Stylistically it may not always be the most beautiful or consistent code to look at as the emphasis is more on the sound of the piece than the engineering quality of the code. I'm going to do my best not to do anything egregious, but by nature it is going to have to be somewhat monolithic.

The code is written using a framework called [Sonic Pi](https://sonic-pi.net) which is a Ruby wrapper around the more well-known [SuperCollider](https://supercollider.github.io). While in development, the only way to play the piece will be within a Sonic Pi environment. I've been using [this third-party CLI](https://github.com/lpil/sonic-pi-tool) rather than the official interface. **This program will not run in a standard Ruby environment.**

A bounce will be uploaded unless it is too large to be uploaded to github, in which case I guess I can provide one.

File will play between starting tag `#>>START-HERE` and ending tag `#>>END-HERE`, inclusive. These tags can be moved for testing purposes but should never be committed in any positions other than the first and last lines of the file respectively.

## Rules

### Pitch
Pitch is equal tempered and passed in as [MIDI numbers](http://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies).
* **Letters**: MIDI notes are assigned in alphabetical order, starting with `a` as 59
* **Special Characters**: the character's [ASCII number](https://ascii.cl) is used as the MIDI pitch number
* **Whitespace**: whitespace characters are rests

### Voices
Voices are the different base 'instruments' that can be tweaked by different modifiers
* **Normal Code**: Normal code is using an FM synth with a short attack and a longer release
* **Comments**: Comments are also using an FM synth, with the 'depth' value changed and an attack that is actually longer than the 'beat' length.
* **Special Characters**: Special characters are just a saw wave.

### Timing
Space between notes is 0.1 of whatever the default bpm is in Sonic Pi (probably 60 but I haven't really investigated it). Some modifiers have a multiplier to change this time.

### Modifiers and Effects
Modifiers and effects are applied on top of the pitch and voice combination. If a certain character contains multiple modifiers that would change the same element of a sound, the last one wins.  

* **Uppercase Letters**: Capital letters are louder and have really sharp attacks and are shorter than the beat time.
* **Language Keywords**: Keywords are a little louder, and they have a longer time in between notes so that the listener can really hear the repitition of these short patterns.
* **Whitespace**: Whitespace has lonnger time between notes, which basically means that the rests are longer.
* **Indent Level**: As the code becomes more indented, the whitespace at the beginning of each line increases the amount of rests between each line. The deeper the indent is, the softer it is.
* **Strings**: Strings have a different divisor applied to the FM synth.
* **Symbols**: All of the notes in a Ruby symbol sound at once. This chord has a smoother attack and lasts longer.
* **Grouping Symbols**: Characters that are inside paranthases or square brackets are panned. The deeper the nesting is, the farther the pan. Pipes are also panned. Each set of grouping symbols has its own panning rules.
