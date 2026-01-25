with Types.Game_Types; use Types.Game_Types;

package Logic.Game is

   -- A slice of the Board is either a row or a column.
   type Slice_Type is array (Board_Index) of Cell_Value;

   function Count_Empty_Cells (Board : Board_Type) return Natural;

   function Is_Board_Full (Board : Board_Type) return Boolean;

   procedure Initialize_New_Game (State : out Game_State)
   with
     Post =>
       State.Status = Playing
       and then State.Move_Count = 0
       and then State.Score = 0;

   procedure Initialize_Board (Board : out Board_Type)
   with
     Post =>
       (for all R in Board_Index =>
          (for all C in Board_Index => Board (R, C) /= Empty_Cell))
       = False
       and then
         (for some R in Board_Index =>
            (for some C in Board_Index =>
               Board (R, C) = 2 or Board (R, C) = 4));

   function Add_Random_Tile (Board : in out Board_Type) return Boolean
   with Pre => Is_Valid_Board (Board) and then not Is_Board_Full (Board);

   function Process_Move
     (Board : in out Board_Type; Direction : Direction_Type) return Boolean
   with
     Pre =>
       Is_Valid_Board (Board) and then Is_Move_Possible (Board, Direction);

   procedure Move_Tiles (Board : in out Board_Type; Direction : Direction_Type)
   with
     Pre =>
       Is_Valid_Board (Board) and then Is_Move_Possible (Board, Direction);

   function Is_Move_Possible
     (Board : Board_Type; Direction : Direction_Type) return Boolean
   with Pre => Is_Valid_Board (Board);

private

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   with Pre => N <= Count_Empty_Cells (Board);

end Logic.Game;
