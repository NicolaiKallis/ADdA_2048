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

   procedure Initialize_New_Game (State : out Game_State) is
   begin
      Initialize_Board (State.Board);
      State.Status := Playing;
      State.Score := 0;
      -- TODO: Read high score from file
      State.High_Score := 0;
      State.Move_Count := 0;
   end Initialize_New_Game;

   procedure Initialize_Board (Board : out Board_Type) is
      Ignored : Boolean;
   begin
      Board := (others => (others => Empty_Cell));
      Ignored := Add_Random_Tile (Board);
      Ignored := Add_Random_Tile (Board);
   end Initialize_Board;

   function Process_Move
     (Board     : in out Board_Type;
      Direction : Direction_Type;
      Score     : out Score_Type) return Boolean
   is
      Tile_Added : Boolean;
   begin
      Move_Tiles (Board, Direction, Score);

      Tile_Added := Add_Random_Tile (Board);
      return Tile_Added;
   end Process_Move;

   procedure Slide_And_Merge (Line : in out Slice_Type; Score : out Score_Type)
   is
      subtype Write_Index_Type is
        Board_Index'Base range Board_Index'First .. Board_Index'Last + 1;
      Write_Index    : Write_Index_Type := Board_Index'First;
      Last_Merged    : Board_Index := Board_Index'First;
      Any_Merge_Done : Boolean := False;
      Merged_Value   : Cell_Value;
   begin
      Score := 0;
      for Read_Index in Board_Index loop
         declare
            Read_Index_Cell_Value : constant Cell_Value := Line (Read_Index);
         begin
            if not Is_Cell_Empty (Read_Index_Cell_Value) then
               -- Try to merge with the tile we just wrote
               if Write_Index > Board_Index'First
                 and then Line (Write_Index - 1) = Read_Index_Cell_Value
                 and then
                   (not Any_Merge_Done or else Last_Merged /= Write_Index - 1)
               then
                  -- Merge with previous tile
                  Merged_Value := 2 * Read_Index_Cell_Value;
                  Line (Write_Index - 1) := Merged_Value;
                  Line (Read_Index) := Empty_Cell;
                  Last_Merged := Write_Index - 1;
                  Any_Merge_Done := True;
                  Score := Score + Score_Type (Merged_Value);
               else
                  -- Move tile to write position
                  if Read_Index /= Write_Index then
                     Line (Write_Index) := Read_Index_Cell_Value;
                     Line (Read_Index) := Empty_Cell;
                  end if;
                  Write_Index := Write_Index + 1;
               end if;
            end if;
         end;
      end loop;
   end Slide_And_Merge;

   -- Wrapper that handles direction by reversing the slice
   procedure Process_Slice
     (Slice                   : in out Slice_Type;
      Iterate_Ascending_Index : Boolean;
      Score                   : out Score_Type)
   is
      procedure Reverse_Slice (S : in out Slice_Type) is
         Temp : Cell_Value;
      begin
         for Idx in
           Board_Index'First .. Board_Index'First + (Board_Size - 1) / 2
         loop
            Temp := S (Idx);
            S (Idx) := S (Board_Index'Last - (Idx - Board_Index'First));
            S (Board_Index'Last - (Idx - Board_Index'First)) := Temp;
         end loop;
      end Reverse_Slice;
   begin
      if Iterate_Ascending_Index then
         Slide_And_Merge (Slice, Score);
      else
         Reverse_Slice (Slice);
         Slide_And_Merge (Slice, Score);
         Reverse_Slice (Slice);
      end if;
   end Process_Slice;


   function Line_Would_Change
     (Line : Slice_Type; Iterate_Ascending_Index : Boolean) return Boolean
   is
      Copy         : Slice_Type := Line;
      Unused_Score : Score_Type;
   begin
      Process_Slice (Copy, Iterate_Ascending_Index, Unused_Score);
      return Copy /= Line;
   end Line_Would_Change;

   function Is_Move_Possible
     (Board : Board_Type; Direction : Direction_Type) return Boolean
   is
      Slice : Slice_Type;
   begin
      case Direction is
         when Up    =>
            for C in Board_Index loop
               for R in Board_Index loop
                  Slice (R) := Board (R, C);
               end loop;
               if Line_Would_Change (Slice, Iterate_Ascending_Index => True)
               then
                  return True;
               end if;
            end loop;

         when Down  =>
            for C in Board_Index loop
               for R in Board_Index loop
                  Slice (R) := Board (R, C);
               end loop;
               if Line_Would_Change (Slice, Iterate_Ascending_Index => False)
               then
                  return True;
               end if;
            end loop;

         when Left  =>
            for R in Board_Index loop
               for C in Board_Index loop
                  Slice (C) := Board (R, C);
               end loop;
               if Line_Would_Change (Slice, Iterate_Ascending_Index => True)
               then
                  return True;
               end if;
            end loop;

         when Right =>
            for R in Board_Index loop
               for C in Board_Index loop
                  Slice (C) := Board (R, C);
               end loop;
               if Line_Would_Change (Slice, Iterate_Ascending_Index => False)
               then
                  return True;
               end if;
            end loop;
      end case;
      return False;
   end Is_Move_Possible;

   --  Generic move: for any Board_Size, process rows or columns depending on
   --  Direction. Each line is processed with Process_Slice; tiles stop at
   --  Reached_Board_End, Merged_With_Tile, or Blocked_By_Tile (see Tile_Stop_Reason).
   procedure Move_Tiles
     (Board     : in out Board_Type;
      Direction : Direction_Type;
      Score     : out Score_Type)
   is
      Line       : Slice_Type;
      Line_Score : Score_Type;
   begin
      Score := 0;
      case Direction is
         when Up    =>
            for C in Board_Index loop
               for R in Board_Index loop
                  Line (R) := Board (R, C);
               end loop;
               Process_Slice
                 (Line, Iterate_Ascending_Index => True, Score => Line_Score);
               Score := Score + Line_Score;
               for R in Board_Index loop
                  Board (R, C) := Line (R);
               end loop;
            end loop;

         when Down  =>
            for C in Board_Index loop
               for R in Board_Index loop
                  Line (R) := Board (R, C);
               end loop;
               Process_Slice
                 (Line, Iterate_Ascending_Index => False, Score => Line_Score);
               Score := Score + Line_Score;
               for R in Board_Index loop
                  Board (R, C) := Line (R);
               end loop;
            end loop;

         when Left  =>
            for R in Board_Index loop
               for C in Board_Index loop
                  Line (C) := Board (R, C);
               end loop;
               Process_Slice
                 (Line, Iterate_Ascending_Index => True, Score => Line_Score);
               Score := Score + Line_Score;
               for C in Board_Index loop
                  Board (R, C) := Line (C);
               end loop;
            end loop;

         when Right =>
            for R in Board_Index loop
               for C in Board_Index loop
                  Line (C) := Board (R, C);
               end loop;
               Process_Slice
                 (Line, Iterate_Ascending_Index => False, Score => Line_Score);
               Score := Score + Line_Score;
               for C in Board_Index loop
                  Board (R, C) := Line (C);
               end loop;
            end loop;
      end case;
   end Move_Tiles;

   function Add_Random_Tile (Board : in out Board_Type) return Boolean is
      C   : constant Natural := Count_Empty_Cells (Board);
      N   : Positive;
      Row : Board_Index;
      Col : Board_Index;
   begin
      if C = 0 then
         return False;
      end if;
      N := Logic.Random.Random_Index (C);
      -- TODO: Need mapping to random index to static board index
      Get_Empty_Cell (Board, N, Row, Col);
      Board (Row, Col) := Logic.Random.Generate_Random_Cell_Value;
      return True;
   end Add_Random_Tile;

   function Is_Any_Move_Possible (Board : Board_Type) return Boolean is
   begin
      return
        Is_Move_Possible (Board, Up)
        or else Is_Move_Possible (Board, Down)
        or else Is_Move_Possible (Board, Left)
        or else Is_Move_Possible (Board, Right);
   end Is_Any_Move_Possible;

   function Has_Victory_Tile (Board : Board_Type) return Boolean is
   begin
      for R in Board_Index loop
         for C in Board_Index loop
            if Board (R, C) >= Victory_Tile_Value then
               return True;
            end if;
         end loop;
      end loop;
      return False;
   end Has_Victory_Tile;

   -- Returns True only when victory is achieved for the first time
   -- (status is Playing and board contains a victory tile)
   function Is_First_Victory (State : Game_State) return Boolean is
   begin
      return State.Status = Playing and then Has_Victory_Tile (State.Board);
   end Is_First_Victory;

   procedure Update_Game_Status (State : in out Game_State) is
   begin
      case State.Status is
         when Playing                      =>
            if Is_First_Victory (State) then
               State.Status := Victory_Achieved;
            elsif not Is_Any_Move_Possible (State.Board) then
               State.Status := Game_Over;
            end if;

         when Continuing                   =>
            if not Is_Any_Move_Possible (State.Board) then
               State.Status := Game_Over;
            end if;

         when Victory_Achieved | Game_Over =>
            -- These states are terminal until user action (Continue/Restart)
            null;
      end case;
   end Update_Game_Status;

end Logic.Game;
