-- TUI Display package for 2048 game
-- Provides ASCII-based rendering of the game board and statistics

with Types.Game_Types;
with Logic.User;

package TUI.Display is

   -- Shows the board, high score, and move count
   procedure Show_Game (State : Types.Game_Types.Game_State)
   with Pre => Types.Game_Types.Is_Valid_Board (State.Board);

   -- Display just the board grid
   procedure Show_Board (Board : Types.Game_Types.Board_Type)
   with Pre => Types.Game_Types.Is_Valid_Board (Board);

   -- Display the statistics line (high score and moves)
   procedure Show_Stats
     (Move_Count : Types.Game_Types.Move_Count_Type;
      High_Score : Types.Game_Types.Score_Type);

   -- Clear the screen (platform dependent)
   procedure Clear_Screen;

   -- Display a warning for unrecognized input
   procedure Show_Invalid_Input_Warning (Input_Char : Character);

   -- Display a warning when extra input is ignored
   procedure Show_Extra_Input_Warning (Input_Char : Character);

   -- Display any warnings related to the last input
   procedure Show_Input_Warnings
     (User_Input    : Logic.User.Input_Command;
      Input_Char    : Character;
      Extra_Input   : Boolean;
      Move_Executed : Boolean);

   -- Display a warning when a move doesn't change the board
   procedure Show_Move_Not_Possible_Warning
     (Direction : Types.Game_Types.Direction_Type);

end TUI.Display;
