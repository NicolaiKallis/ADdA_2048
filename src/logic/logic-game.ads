with Types.Game_Types; use Types.Game_Types;

package Logic.Game is

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

private

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   with Pre => N <= Count_Empty_Cells (Board);

end Logic.Game;
