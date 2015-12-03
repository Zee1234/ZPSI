# ZPSI
Zee's Plugin Setting Interface (Pronounced Zip See)

ZPSI is a simple file format made specifically to be translated into a lua table. ZPSI.lua is a pure-lua implementation of the ZPSI parser. A 1000 line ZPSI file with no line breaks and no comments took .18 seconds to execute in a debug enviroment (version one took .33 seconds!). A 2 line ZPSI file with no line breaks and no comments took .18 seconds to execute in a debug enviroment. This means that the conversion is taking place in under .005 seconds, and the majority of the time is likely i/o and compilation. I do not have the ability to measure such small numbers, so if someone does, I would be quite happy if you tested it and reported the result to me.

## How to include

You use require. In most cases, `require "ZPSI"` will be all you have to do to be able to use ZPSI.parse.

`ZPSI.parse(filename)` will turn the ZPSI file into an object! Do note that this removes all whitespace from the outside of values unless "" are used (single quotes do not work!!!)    
ZPSI identifies numbers and boolean values and processes them accodingly. True and TRUe both resolve to bool(true) while False and FALsE both resolve to bool(false). Capitalization DOES NOT MATTER! True, true, TRUE, and TrUe are all proccessed the same way! So if you want the string True as a value, you will need to use "True".

## Syntax

ZPSI was made with the ideal of being easily edited by technically inept users. However, no guarantees are made in this being idiot proof. You have been warned. Files contain no {} or [] and instead of indentation, '-' is used to determine families. With that said, let us get into the specification.    
To anyone used to YAML, this will seem similar to that. In fact, ZPSI files can be created from most YAML files by replacing all "-" with ":" and two spaces with "-"!

The top level is defined like so:    
`First Key Here:`    
If you want to give the key a value, just place it after the colon.    
`First Key: First Value`    
However, the value is not, and is never, nessecary.
Newlines can exist in strings by using "\n". Tabs can be places with "\t" "\\t" and "\\n" both resolve to the literals "\t" and "\n". You can also change this behavior. When you call ZPSI.parse(filename), you can instead call ZPSI.parse(filename,#) where # is 0, 1, 2, or 3 (if unspecified or any other value is entered, then 3 is assumed). 0 completely removes this parsing. 1 replaces "\t" but not "\n". 2 replaces "\n" but not "\t". 3 replaces both "\n" and "\t".
Here's an example ZPSI file:
```
FirstKey:
-a1:
--b1: true
--b2: 
---: I'm in an array!
---: I'm second in an array!
---: false
---: The value above me is FirstKey.a1.b2[3] and is a boolean value false
---:yes
---: The value above me is the string "yes"!
----:Nesting in arrays works now! YAY!
----: "You can have an octothorp like this: \#"
----: You can also do it without the quote, like so: \# #This part is still a comment though!
----d1: You can even have key names and arrays at the same depth!
----: and alternate between them!

--b3: Line breaks aren't bad
              #And comments with whitespace before the octothorp are fine as well!
--b4:          Even in a value              #Remember, all that extra space is trimmed off!
--b5: "          but all this space remains               " # Quotes are cool, amirite?
a2: 
-b1: repeated names are fine so long as they share different parents
-: -15.2
-: 0
-: -1
-: -.3
-: .3
-b2: "The above 5 are all read into numbers"
-: true
-: false
-: tRUe
-: fAlSe
-b3: And the above 4 are all read into booleans
-b4: You can insert newlines into strings like this: \n I'm on a new line!!
-b5: This also work with tabs using \t !
-b6: Just realize that \\n and \\t doesn't make newlines or tabs
a3:
a4: The guy above me is empty and that is TOTALLY FINE!
a5: The program just thinks of a3 as an empty object.


```

That ZPSI file will be parsed into this table:

```
{
	["a2"] = {
		[1] = -15.2;
		[2] = 0;
		[3] = -1;
		[4] = -0.3;
		[5] = 0.3;
		[6] = true;
		[7] = false;
		[8] = true;
		[9] = false;
		["b5"] = "This also work with tabs using 	 !";
		["b3"] = "And the above 4 are all read into booleans";
		["b1"] = "repeated names are fine so long as they share different parents";
		["b4"] = "You can insert newlines into strings like this: 
 I'm on a new line!!";
		["b2"] = "The above 5 are all read into numbers";
		["b6"] = "Just realize that \n and \t doesn't make newlines or tabs";
	};
	["FirstKey"] = {
		["a1"] = {
			["b5"] = "          but all this space remains               ";
			["b3"] = "Line breaks aren't bad";
			["b1"] = true;
			["b4"] = "Even in a value";
			["b2"] = {
				[1] = "I'm in an array!";
				[2] = "I'm second in an array!";
				[3] = false;
				[4] = "The value above me is FirstKey.a1.b2[3] and is a boolean value false";
				[5] = "yes";
				[6] = "The value above me is the string "yes"!";
				[7] = {
					[1] = "Nesting in arrays works now! YAY!";
					[2] = "You can have an octothorp like this: #";
					[3] = "You can also do it without the quote, like so: #";
					[4] = "and alternate between them!";
					["d1"] = "You can even have key names and arrays at the same depth!";
				};
			};
		};
	};
	["a5"] = "The program just thinks of a3 as an empty object.";
	["a3"] = {};
	["a4"] = "The guy above me is empty and that is TOTALLY FINE!";
};
```
Pardon the weird syntax and the "out of orderness" present. That's due to the table -> string program I used and lua's limitations, respectively.

### Limitations

  * The Keys (the parts before the : that are not "-") need to be valid Lua variable names. This means that they can only contain letters, numbers, and underscores, and must not begin with an underscore.    
  * As of now, there is no "Object to ZPSI" function. This is partially due to lua tables having no implicit "order" to them. 
  
## License
The ZPSI library is released under the MIT liscense. You are free to use it as you please. Improvements to the code are much appretiated.
