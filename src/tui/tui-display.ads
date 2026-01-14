-- TUI Display package for 2048 game
-- Provides ASCII-based rendering of the game board and statistics

with Game_Types;

package TUI.Display is

   -- Shows the board, high score, and move count
   procedure Show_Game (Board : Game_Types.Board_Type);

   -- Display just the board grid
   procedure Show_Board (Board : Game_Types.Board_Type);

   -- Display the statistics line (high score and moves)
   procedure Show_Stats (High_Score : Natural; Moves : Natural);

   -- Clear the screen (platform dependent)
   procedure Clear_Screen;

end TUI.Display;
