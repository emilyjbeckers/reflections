# Reflections

This is an algorithmic composition piece in which the code sonifies itself. Stylistically it may not always be the most beautiful or consistent code to look at as the emphasis is more on the sound of the piece than the engineering quality of the code. I'm going to do my best not to do anything egregious, but by nature it is going to have to be somewhat monolithic.

The code is written using a framework called [Sonic Pi](https://sonic-pi.net) which is a Ruby wrapper around the more well-known [SuperCollider](https://supercollider.github.io). While in development, the only way to play the piece will be within a Sonic Pi environment. I've been using [this third-party CLI](https://github.com/lpil/sonic-pi-tool) rather than the official interface. **This program will not run in a standard Ruby environment.**

There will be a bounce provided, but I do not guarantee that it is always from the most current version. 

File will play between starting tag `#>>START-HERE` and ending tag `#>>END-HERE`, inclusive. These tags can be moved for testing purposes but should never be committed in any positions other than the first and last lines of the file respectively.
