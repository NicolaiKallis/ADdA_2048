with Types.Game_Types; use Types.Game_Types;

package Logic.Game is

   -- A slice of the Board is either a row or a column.
   type Slice_Type is array (Board_Index) of Cell_Value;

   function Count_Empty_Cells (Board : Board_Type) return Natural
   with
     Pre  => Is_Valid_Board (Board),
     Post => Count_Empty_Cells'Result in 0 .. Board_Size * Board_Size;

   function Is_Board_Full (Board : Board_Type) return Boolean
   with
     Pre  => Is_Valid_Board (Board),
     Post => Is_Board_Full'Result = (Count_Empty_Cells (Board) = 0);

   procedure Initialize_New_Game (State : out Game_State)
   with
     Post =>
       State.Status = Playing
       and then State.Move_Count = 0
       and then State.Score = 0
       and then Is_Valid_Board (State.Board);

   procedure Initialize_Board (Board : out Board_Type)
   with
     Post =>
       (for all R in Board_Index =>
          (for all C in Board_Index => Board (R, C) = Empty_Cell))
       = True
       and then
         (for some R in Board_Index =>
            (for some C in Board_Index =>
               Board (R, C) = 2 or Board (R, C) = 4))
       and then Is_Valid_Board (Board);

   function Add_Random_Tile (Board : in out Board_Type) return Boolean
   with
     Pre  => Is_Valid_Board (Board) and then not Is_Board_Full (Board),
     Post =>
       Add_Random_Tile'Result
       and then Is_Valid_Board (Board)
       and then Count_Empty_Cells (Board) = Count_Empty_Cells (Board'Old) - 1;

   function Process_Move
     (Board     : in out Board_Type;
      Direction : Direction_Type;
      Score     : out Score_Type) return Boolean
   with
     Pre  =>
       Is_Valid_Board (Board) and then Is_Move_Possible (Board, Direction),
     Post => Is_Valid_Board (Board);

   procedure Move_Tiles
     (Board     : in out Board_Type;
      Direction : Direction_Type;
      Score     : out Score_Type)
   with
     Pre  =>
       Is_Valid_Board (Board) and then Is_Move_Possible (Board, Direction),
     Post => Is_Valid_Board (Board);

   function Is_Move_Possible
     (Board : Board_Type; Direction : Direction_Type) return Boolean
   with Pre => Is_Valid_Board (Board);

   function Is_Any_Move_Possible (Board : Board_Type) return Boolean
   with Pre => Is_Valid_Board (Board);

   function Has_Victory_Tile (Board : Board_Type) return Boolean
   with
     Pre  => Is_Valid_Board (Board),
     Post =>
       (if Has_Victory_Tile'Result
        then
          (for some R in Board_Index =>
             (for some C in Board_Index =>
                Board (R, C) >= Victory_Tile_Value)));

   -- Call this after each move to detect victory or game over
   procedure Update_Game_Status (State : in out Game_State)
   with
     Pre  => Is_Valid_Board (State.Board),
     Post =>
       Is_Valid_Board (State.Board)
       and then State.Board = State.Board'Old
       and then State.Score = State.Score'Old
       and then State.High_Score = State.High_Score'Old
       and then State.Move_Count = State.Move_Count'Old;

private

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   with
     Pre  => N <= Count_Empty_Cells (Board),
     Post => Is_Cell_Empty (Board (Row, Column));

end Logic.Game;
