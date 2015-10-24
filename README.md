# ZPSI
Zee's Plugin Setting Interface (Pronounced Zip See)

ZPSI is a simple file format made specifically to be translated into a lua table. ZPSI.lua is a pure-lua implementation of the ZPSI parser. A 1000 line ZPSI file with no line breaks and no comments took .33 seconds to execute in a debug enviroment. A 2 line ZPSI file with no line breaks and no comments took .33 seconds to execute in a debug enviroment. This means that the actual file parsing and conversion is taking place in under .005 seconds. I do not have the ability to measure such small numbers, so if someone does, I would be quite happy if you tested it and reported the result to me.

## How to include

You use require. In most cases, `require "ZPSI"` will be all you have to do to be able to use ZPSI.parse.

`ZPSI.parse(filename)` will turn the ZPSI file into an object! Do note that this removes excess spaces from the end of all strings. If you do not want this behavior, use `ZPSI.parse(filename,false)`. This will leave all strings exactly as they are in the file. Do not that this means you might need to remove excess variables for yourself.    
ZPSI identifies numbers and boolean values and processes them accodingly. True and Yes both resolve to bool(true) while False and No both resolve to bool(false). Capitalization DOES NOT MATTER! True, true, TRUE, and TrUe are all proccessed the same way!

## Syntax

ZPSI was made with the ideal of being easily edited by technically inept users. However, no gaurentees are made in this being idiot proof. You have been warned. Files contain no {} or [] and instead of indentation, '-' is used to determine families. With that said, let us get into the specification.    
To anyone used to YAML, this will seem similar to that. In fact, ZPSI files can be created from most YAML files by replacing all "-" with ":" and two spaces with "-"!

The top level is defined like so:    
`First Key Here:`    
If you want to give the key a value, just place it after the colon (make sure there is a space!!)    
`First Key: First Value`    
However, the value is not, and is never, nessecary.
Here's an example ZPSI file:
```
FirstKey:
-First:
--First: true
--Second:
---: I'm in an array!
---: I'm second in an array!
---: false
---: The value above me is First.First.Second[3] and is a boolean value false
---: yes
---: The value above me is boolean value true!

# This is a comment!

SecondKey:
-: 26
-: 155.12345676543
-: .2
-: -26
-: -155.12345676543
-: -.2
-: The six handsome gentlemen directly above me are all numbers!
ThirdKey:
FourthKey: The guy above me is empty and that's totally OK!
```

That ZPSI file will be parsed into this table:

```
{
  FirstKey = {
    First = {
      First = true,
      Second = {
        1 = I'm in an array!,
        2 = I'm second in an array!,
        3 = false,
        4 = The value above me is First.First.Second[3] and is a boolean value false,
        5 = true,
        6 = The value above me is boolean value true!,
      },
    },
  },
  SecondKey = {
    1 = 26,
    2 = 155.12345676543,
    3 = 0.2,
    4 = -26,
    5 = -155.12345676543,
    6 = -0.2,
    7 = The six handsome gentlemen directly above me are all numbers!,
  },
  ThirdKey = {
  },
  FourthKey = The guy above me is empty and that's totally OK!,
}
```

### Limitations

  * The Keys (the parts before the : that are not "-") need to be valid Lua variable names. This means that they can only contain letters, numbers, and underscores, and must not begin with an underscore.    
  * You can't make an array in an array. Not automatically, at least. Not yet.    
  * Comments can only exist on new lines. You cannot put a comment at the end of a line. If you did this, the comment would be parsed as part of the string.
  * A string that is just numbers and spaces will be read as a number unless there is a space before the first character of a number.  
  * By default, all string have all trailing whitespace removed. However, when you call ZPSI.parse, you can add a second operator. If you call `ZPSI.parse(<filename>,false)`, then the strings will not be truncated. Numerical and Boolean values are unaffected by this setting.    
  * The space after the colon is really important and things break if it isn't there. No, seriously. Without that single space, the whole variable is wrong.
  * As of now, there is no "Object to ZPSI" function. I've only been using Lua for 4 days now (at time of writing), I'm not great with this yet.
  * It's probably poorly programmed! As I just said, I've only been using Lua for 4 days! One thing I know I could change is all the ==/~= nil in if statements. I tried that, but I broke something and reverted.
  
## License
The ZPSI library is released under the MIT liscense. You are free to use it as you please. Improvements to the code are much appretiated.
