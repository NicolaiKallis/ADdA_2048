with Logic.Random;
with Types.Game_Types; use Types.Game_Types;

package body Logic.Game is

   function Count_Empty_Cells (Board : Board_Type) return Natural is
      Count : Natural := 0;
   begin
      for R in Board_Index loop
         for C in Board_Index loop
            if Is_Cell_Empty (Board (R, C)) then
               Count := Count + 1;
            end if;
         end loop;
      end loop;
      return Count;
   end Count_Empty_Cells;

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   is
      Seen : Natural := 0;
   begin
      for R in Board_Index loop
         for C in Board_Index loop
            if Is_Cell_Empty (Board (R, C)) then
               Seen := Seen + 1;
               if Seen = N then
                  Row := R;
                  Column := C;
                  return;
               end if;
            end if;
         end loop;
      end loop;
   end Get_Empty_Cell;

   function Is_Board_Full (Board : Board_Type) return Boolean is
   begin
      return Count_Empty_Cells (Board) = 0;
   end Is_Board_Full;

   procedure Initialize_Board (Board : out Board_Type) is
      Ignored : Boolean;
   begin
      Board := (others => (others => Empty_Cell));
      Ignored := Add_Random_Tile (Board);
      Ignored := Add_Random_Tile (Board);
   end Initialize_Board;

   function Add_Random_Tile (Board : in out Board_Type) return Boolean is
      C   : constant Natural := Count_Empty_Cells (Board);
      N   : Positive;
      R   : Board_Index;
      Col : Board_Index;
   begin
      if C = 0 then
         return False;
      end if;
      N := Logic.Random.Random_Index (C);
      -- TODO: Need mapping to random index to static board index
      Get_Empty_Cell (Board, N, R, Col);
      Board (R, Col) := Logic.Random.Generate_Random_Cell_Value;
      return True;
   end Add_Random_Tile;

end Logic.Game;
