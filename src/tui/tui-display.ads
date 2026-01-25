-- TUI Display package for 2048 game
-- Provides ASCII-based rendering of the game board and statistics

with Types.Game_Types;

package TUI.Display is

   -- Shows the board, high score, and move count
   procedure Show_Game (State : Types.Game_Types.Game_State);

   -- Display just the board grid
   procedure Show_Board (Board : Types.Game_Types.Board_Type);

   -- Display the statistics line (high score and moves)
   procedure Show_Stats
     (Move_Count : Types.Game_Types.Move_Count_Type;
      High_Score : Types.Game_Types.Score_Type);

   -- Clear the screen (platform dependent)
   procedure Clear_Screen;

end TUI.Display;
