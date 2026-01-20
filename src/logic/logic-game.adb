with Logic.Random;
with Types.Game_Types; use Types.Game_Types;
with Logic.User;       use Logic.User;

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

   procedure Process_Move
     (Board : in out Board_Type; UserInput : Input_Command) is
   begin
      case UserInput is
         when Move_Up     =>
            Move_Tiles (Board, Up);

         when Move_Down   =>
            Move_Tiles (Board, Down);

         when Move_Left   =>
            Move_Tiles (Board, Left);

         when Move_Right  =>
            Move_Tiles (Board, Right);

         when Cmd_Restart =>
            -- TODO: Reset score and moves
            Initialize_Board (Board);

         when Cmd_Quit    =>
            Exit_Game;

         when Cmd_Invalid =>
            raise Invalid_Input_Error;
      end case;
   end Process_Move;

   -- TODO: Add move tiles commands -> IMplement generic method for move tiles
   procedure Move_Tiles (Board : in out Board_Type; Direction : Direction_Type)
   is
   begin
      case Direction is
         when Up    =>
            Move_Tiles_Up (Board);

         when Down  =>
            Move_Tiles_Down (Board);

         when Left  =>
            Move_Tiles_Left (Board);

         when Right =>
            Move_Tiles_Right (Board);
      end case;
   end Move_Tiles;
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
