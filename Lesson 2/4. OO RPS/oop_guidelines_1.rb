# oop_guidelines_1

# The classical approach to object oriented programming is:
# 1. Write a textual description of the problem or exercise.
# 2. Extract the major nouns and verbs from the description.
# 3. Organize and associate the verbs with the nouns.
# 4. The nouns are the classes and the verbs are the behaviors or methods.

# Step 1: Write out the 'story':
# a. RPS is a 2 player game played in a single turn.
# b. A player can choose one of 3 moves.
# c. The player moves are: Rock, Paper and Scissors.
# d. Each player chooses one of the move in secret.
# e. The moves are compared and the winner is selected as per the game rules.
# f. The game rules are:
# f1. Rock beats Scissors.
# f2. Scissors beats Paper.
# f3. Paper beats Rock.
# g. A winner is declared.
# h. If the moves were the same, the game is declared a tie.
# i. A new game can start again, or not, depending on player choice.

# Step 2: Identify Nouns and Verbs
# Major Nouns: Player, Game, Move, Rule
# Major Verbs: Choose, Compare

# Step 3: Group Verbs with Nouns
# a. Player
# a1. Choose (a Move)
# b. Move
# c. Game
# c1. Compare (and apply rules)
# d. Rule

 # Launch School's answer:
    # Player
    #  - choose
    # Move
    # Rule
    #
    # - compare
