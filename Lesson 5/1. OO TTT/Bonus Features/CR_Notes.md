### Reply to Code Review Feedback(1):

Hi Pete,

Thanks for your feedback and suggestions. Most of them were valid and/or better solutions than I had come up with. The issues I would like some clarity about, or provide you with an explanations, are listed below.

Thanks
Bennie

### Source Code

** Board: @available_markers**

`Board: @available_markers` should probably be a class constant instead of an instance variable.
##### Answer:
I had it as a class constant, but because the human chooses first from the list of available markers, I have to remove that marker from the `@available_markers` array before the computer player can make its choice. So I needed to delete the human's marker from the array, and instead of duplicating the constant AVAILABLE_MARKERS array, and then using that for the deletion as well as the computer's choice, I decided to rather make the array of available_markers an instance variable.

** Board: @player_markers[]: **

I'm not clear on how `@player_markers` is being used. I can't easily tell what it contains, but I think it's a 2-element array, with one element for the player's marker, and one for the computer's marker. Rather than array, a Hash would provide more meaning to this IV. You may even be able to just use a couple of variables rather than a structure.

##### Answer:
You are correct, it is a 2 element array. It was meant to serve two purposes:
1. A mechanism for the `Board` class to keep track of the markers and who they belong to. `@player_markers[0]` was the human, and `@player_markers[1]` was the computer.
2. I wanted to "future proof" the Board class for if/when the program is expanded to allow for more than two players to participate in the game (presumably with a larger board as well).

I know the above two reasons were not obvious so I do apologize. ** I have changed this to two instance variables (`@player_marker` and `@computer_marker`), as you suggested **.

** Board#make_marker_unvailable: **

I would say that this method name is descriptive, but it's descriptive of the secondary effect rather than the primary effect. What you are doing primarily here is setting the human's marker; making it unavailable is secondary.

`Board#make_marker_unavailable`: If @player_markers is indeed a 2-element array, would it be better to use @player_markers[0] = marker instead? (Presumably, you will change this to a hash or a plain string variable, but the point remains; be specific when you need to set a specific element of an Array. This way, if someone later decides to alter the sequence in which methods are called, they won't be surprised by << suddenly putting the human's marker in `@player_markers[2]`.

##### Answer:
Yes, you are correct! I have changed the method name to: `set_and_make_unavailable(marker)`. This of course means, set the Board's human marker and then make this marker unavailable to the computer player.

My (not very advanced) thinking was to accommodate the 'bigger board and more than two player' idea mentioned above. You would need to be very careful when each human player's marker choice is sent to the Board object, and then know which index in the array to use for each player. If more than one computer player is to be allowed, each computer player's marker will also need to be removed from the array of available markers. A hash would work better here as you would be able to associate a name with a marker. Perhaps something like this?:

 > @allocated_markers = { 1 => %w(John X), 2 => %w(Sam O), 3 => %w(Hal +), 4 => %w(Twiki #) }   

#### Misc and valid_string?(name):
Not a very useful name. Module names should usually say something about what they are used for, and names like Misc and Helper don't really do that.

I'm also not fond of valid_string? as a name.

##### Answer:

I thought that ** Misc ** would be fine for all those methods you really don't know where to put. I did change this to the code below. Better?
```ruby
module NameCheck
  def valid_name?(name) # Hyphenated names are also valid: "Jean-Claude".
    !!(name =~ /^[A-Z][a-zA-Z]*(-[A-Z][a-zA-Z]*)?$/)
  end
end
```

#### Human#request_human_name, Human#request_human_marker (and Computer#):
Overly descriptive given that you are already in the Human class: request_name and request_marker are sufficiently descriptive.

Better yet, make them generic: get_name and get_marker, and do the same thing for Computer#choose_new_name and Computer#choose_marker. Then, you can set both @name and @marker in Player#initialize, and eliminate the initialize calls from Human and Computer.

##### Answer:
Thanks for this! The word ** human ** in those methods was a left-over from when these methods were first implemented in the TTTGame class.

Regarding your suggestion about the **generic get_name and get_marker methods **: I did as you suggested, except Rubocop does not like any method to start with ** get **. I changed it to ** obtain_name ** and ** obtain_marker **, but it still words nicely.I managed to delete a lot of lines of unnecessary code because of this. Is the actual code reflective of what you were thinking of?

#### Numeric values for Constants:
Lines 326-328: Rather than numeric values for these constants, use symbols instead.

##### Answer:
A noob mistake I think. Thanks for pointing it out!

#### Board#winning_marker and Board#keys_for_best_move:

These methods share a lot of code. I think they can be simplified with a 3rd method that consolidates the shared code.

You may also consider not having keys_for_best_move return all of the best moves, just return the first move it finds -- you don't really need them all. This might simplify the refactor. Alternatively, you could do your sampling inside this method since you always sample the results anyway.

##### Answer:
Still thinking about how to do this exactly. But here are a few thoughts:

1. The methods `winning_marker` and `keys_for_best_move` already share a common method in `identical_markers?` (which is tucked away in the private section of the `Board` class). In the one case `identical_markers?` searches for 3 of the same markers and in the other, for 2 of the same with an empty square. The two methods above pass the `identical_markers?` method the 'winning_line' squares to search, the number of identical markers (2 or 3) to look for and, in the case of the `keys_for_best_move` method, the specific marker to search for.
2. The method `best_key_for_blocking` also uses the `keys_for_best_move` method (but providing the opponent's marker instead).
3. `keys for best move` returns an array of keys, just so that in the case where two or more possible keys for 'best' moves are available, a random one is chosen. This in order for the computer not to seem so predictable.

#### Final Question:
I considered making a Constants module, which would contain all the constants, and then mixing that in with the `Board` and `TTTGame` classes (and any other class making use of a constant). I decided against that in order to keep the relevant constants with the classes which use them.

 Is this ok? The one positive I can see with a Constants module containing all of the constants used by all of the classes in the program, is that it provides one place where all the constants can be found and also set prior to running the program.

#### Final, Final Question:
Is it done in Ruby to save each class and its related modules to a separate .rb file? And then loading them all up in the class where the main loop is situated in (for example `load 'board.rb'` at the top of the TTTGame class' .rb file)? I would much prefer this as the scrolling up and down get very tedious after a while (as opposed to using CTRL-Tab to switch from file to file).
