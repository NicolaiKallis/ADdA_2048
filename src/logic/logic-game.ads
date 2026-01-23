with Types.Game_Types; use Types.Game_Types;

package Logic.Game is

   type Cell_Constraint_Type is
     (Blocked_By_Board, Merged_With_Tile, Blocked_By_Tile);

   function Count_Empty_Cells (Board : Board_Type) return Natural;

   function Is_Board_Full (Board : Board_Type) return Boolean;

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
