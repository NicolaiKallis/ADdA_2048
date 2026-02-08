pragma SPARK_Mode (On);

package Types.Game_Types
  with Pure
is

   -- Board size is a runtime choice bounded for UI stability and proofs
   Min_Board_Size     : constant := 4;
   Max_Board_Size     : constant := 8;
   subtype Board_Size_Type is Positive range Min_Board_Size .. Max_Board_Size;
   Default_Board_Size : constant Board_Size_Type := Min_Board_Size;

   -- Shared index range used by board rows and columns
   type Board_Index is range 1 .. Max_Board_Size;

   -- Base type so constants can be defined before the constrained Cell_Value subtype
   type Cell_Value_Base is new Natural;

   -- Numeric value used to represent an empty board cell
   Empty_Cell           : constant Cell_Value_Base := 0;
   -- Smallest non-empty tile value accepted by game rules
   Min_Valid_Cell_Value : constant Cell_Value_Base := 2;
   -- Tile value that marks base victory state
   Victory_Tile_Value   : constant Cell_Value_Base := 2048;
   -- The maximum possible tile on a grid with k cells is 2^(k+1)
   -- (assuming the final tile to spawn is a "4")
   -- For an n×n square board, this is 2^(n^2 + 1), capped to type limits
   Max_Valid_Cell_Value : constant Cell_Value_Base := Cell_Value_Base'Last;

   subtype Cell_Value is
     Cell_Value_Base range Empty_Cell .. Max_Valid_Cell_Value;
   -- Full square game board with fixed maximum bounds
   type Board_Type is array (Board_Index, Board_Index) of Cell_Value;
   -- Count type sized for total cells in the maximum board
   type Tile_Count_Type is range 0 .. Max_Board_Size * Max_Board_Size;

   --  A slice of the Board is either a row or a column
   type Slice_Type is array (Board_Index) of Cell_Value;

   -- Score accumulated from merges during play
   type Score_Type is range 0 .. 10_000_000;
   -- Number of accepted moves played in one game
   type Move_Count_Type is range 0 .. 1_000_000;

   -- Direction of user-initiated tile movement
   type Direction_Type is (Up, Down, Left, Right);

   -- High-level state of the current game lifecycle
   type Game_Status is (Playing, Victory_Achieved, Continuing, Game_Over);
   -- Aggregate runtime game state used by logic and UI
   type Game_State is record
      Size       : Board_Size_Type := Default_Board_Size;
      Board      : Board_Type := (others => (others => Empty_Cell));
      Score      : Score_Type := 0;
      High_Score : Score_Type := 0;
      Move_Count : Move_Count_Type := 0;
      Status     : Game_Status := Playing;
   end record;

   -- Check whether a value is an exact power of two
   function Is_Power_Of_Two (Value : Cell_Value) return Boolean
   with
     Post =>
       (if Value = 0 then not Is_Power_Of_Two'Result)
       and (if Value = 1 then Is_Power_Of_Two'Result);

   -- Check whether a cell contains an allowed game value
   function Is_Valid_Cell_Value (Value : Cell_Value) return Boolean
   with
     Post =>
       Is_Valid_Cell_Value'Result
       = (Value = Empty_Cell
          or else
            (Value >= Min_Valid_Cell_Value and then Is_Power_Of_Two (Value)));

   -- Return True when a cell holds no tile
   function Is_Cell_Empty (Value : Cell_Value) return Boolean
   is (Value = Empty_Cell)
   with Post => Is_Cell_Empty'Result = (Value = Empty_Cell);

   -- Validate all cells in a board against tile invariants
   function Is_Valid_Board (Board : Board_Type) return Boolean
   with
     Post =>
       Is_Valid_Board'Result
       = (for all Row in Board_Index =>
            (for all Col in Board_Index =>
               Is_Valid_Cell_Value (Board (Row, Col))));


end Types.Game_Types;
