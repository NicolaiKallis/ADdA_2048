-- Core type definitions for 2048 game
-- SPARK-compliant type system with verification support

pragma SPARK_Mode (On);

package Game_Types is

   -- Cell_Value represents the value in a single board cell
   -- Extended range to support values beyond 2048 (powers of 2 up to 2^31)
   type Cell_Value is new Natural range 0 .. 2_147_483_648;
   Empty_Cell : constant Cell_Value := 0;
   
   -- Target tile value for victory condition
   Target_Tile_Value : constant Cell_Value := 2048;
   
   -- ============================================================================
   -- Board Dimensions
   -- ============================================================================
   
   Board_Size : constant := 4;
   type Board_Index is range 1 .. Board_Size;
   
   -- The game board: 4x4 grid of cells
   type Board_Type is array (Board_Index, Board_Index) of Cell_Value;
   
   -- ============================================================================
   -- Custom Meaningful Types
   -- ============================================================================
   
   -- Score_Type for game scoring (custom type instead of raw Natural)
   type Score_Type is range 0 .. 10_000_000;
   
   -- Move_Count_Type for tracking move count
   type Move_Count_Type is range 0 .. 1_000_000;
   
   -- Tile_Count_Type for tracking number of tiles/empty cells
   type Tile_Count_Type is range 0 .. Board_Size * Board_Size;
   
   -- ============================================================================
   -- Direction Enumeration
   -- ============================================================================
   
   -- Direction enumeration for move commands
   type Direction is (Up, Down, Left, Right);
   
   -- Game_State record encapsulates all game information
   type Game_State is record
      Board       : Board_Type;
      Score       : Score_Type := 0;
      Game_Over   : Boolean := False;
      Victory     : Boolean := False;
   end record;
   
   -- ============================================================================
   -- Predicate Functions for State Validation
   -- ============================================================================
   
   -- Check if a cell value is valid (empty or positive value)
   -- Full power-of-2 validation can be added in game logic layer
   function Is_Valid_Cell_Value (Value : Cell_Value) return Boolean
     is (True);  -- All values in Cell_Value range are valid by type definition
   
   -- Check if board contains only valid cell values
   function Is_Valid_Board (Board : Board_Type) return Boolean
     with
       Post => Is_Valid_Board'Result =
         (for all Row in Board_Index =>
            (for all Col in Board_Index =>
               Is_Valid_Cell_Value (Board (Row, Col))));
   
   -- Check if game state is valid (board is valid, score is non-negative)
   function Is_Valid_Game_State (State : Game_State) return Boolean
     is (Is_Valid_Board (State.Board) and State.Score >= 0);

end Game_Types;
