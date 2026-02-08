pragma SPARK_Mode (On);

with Logic.Random;
with Logic.Highscore;
with Types.Game_Types; use Types.Game_Types;
with Verification.Game_Ghost;

package body Logic.Game is

   function Count_Empty_Cells
     (Board : Board_Type; Size : Board_Size_Type) return Natural is
      Count : Natural := 0;
   begin
      for R in Board_Index range 1 .. Board_Index (Size) loop
         for C in Board_Index range 1 .. Board_Index (Size) loop
            if Is_Cell_Empty (Board (R, C)) then
               Count := Count + 1;
            end if;
         end loop;
      end loop;
      return Count;
   end Count_Empty_Cells;

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      Size   : Board_Size_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   is
      Seen : Natural := 0;
   begin
      --  Initialize outputs for SPARK flow analysis
      Row := Board_Index'First;
      Column := Board_Index'First;

      for R in Board_Index range 1 .. Board_Index (Size) loop
         for C in Board_Index range 1 .. Board_Index (Size) loop
            if Is_Cell_Empty (Board (R, C)) then
               Seen := Seen + 1;
               if Seen = N then
                  Row := R;
                  Column := C;
                  pragma Assert (Is_Cell_Empty (Board (Row, Column)));
                  return;
               end if;
            end if;
         end loop;
      end loop;
   end Get_Empty_Cell;

   function Is_Board_Full
     (Board : Board_Type; Size : Board_Size_Type) return Boolean is
   begin
      return Count_Empty_Cells (Board, Size) = 0;
   end Is_Board_Full;

   procedure Initialize_New_Game
     (State : out Game_State; Size : Board_Size_Type)
   with SPARK_Mode => Off
   is
   begin
      State.Size := Size;
      Initialize_Board (State.Board, Size);
      State.Status := Playing;
      State.Score := 0;
      State.High_Score := Logic.Highscore.Load_Highscore (Size);
      State.Move_Count := 0;
   end Initialize_New_Game;

   procedure Initialize_Board
     (Board : out Board_Type; Size : Board_Size_Type) with SPARK_Mode => Off
   is
      Ignored : Boolean;
   begin
      Board := (others => (others => Empty_Cell));
      Ignored := Add_Random_Tile (Board, Size);
      Ignored := Add_Random_Tile (Board, Size);
   end Initialize_Board;

   function Process_Move
     (Board     : in out Board_Type;
      Size      : Board_Size_Type;
      Direction : Direction_Type;
      Score     : out Score_Type) return Boolean
   with SPARK_Mode => Off
   is
      Tile_Added : Boolean;
   begin
      Move_Tiles (Board, Size, Direction, Score);

      Tile_Added := Add_Random_Tile (Board, Size);
      return Tile_Added;
   end Process_Move;

   procedure Slide_And_Merge
     (Line : in out Slice_Type; Size : Board_Size_Type; Score : out Score_Type)
   is
      subtype Index_Type is Board_Index;
      subtype Write_Index_Type is
        Index_Type'Base range Line'First .. Line'Last + 1;
      Start_Index   : constant Index_Type := Line'First;
      End_Index     : constant Index_Type := Board_Index (Size);
      Write_Index    : Write_Index_Type := Start_Index;
      Last_Merged    : Index_Type := Start_Index;
      Any_Merge_Done : Boolean := False;
      Merged_Value   : Cell_Value;

      Initial_Sum : constant Natural :=
        Verification.Game_Ghost.Slice_Sum (Line)
      with Ghost;
   begin
      Score := 0;
      for Read_Index in Start_Index .. End_Index loop
         --  Write_Index never exceeds Read_Index + 1
         pragma
           Loop_Invariant (Write_Index in Start_Index .. Read_Index + 1);

         --  Cells between Write_Index and Read_Index-1 are empty (compaction)
         pragma
           Loop_Invariant
             (for all I in Write_Index .. Read_Index - 1 =>
                (if I in Start_Index .. End_Index
                 then Line (I) = Empty_Cell));

         declare
            Read_Index_Cell_Value : constant Cell_Value := Line (Read_Index);
         begin
            if not Is_Cell_Empty (Read_Index_Cell_Value) then
               --  Try to merge with the tile we just wrote
               if Write_Index > Start_Index
                 and then Line (Write_Index - 1) = Read_Index_Cell_Value
                 and then
                   (not Any_Merge_Done or else Last_Merged /= Write_Index - 1)
               then
                  --  Merge with previous tile
                  if Read_Index_Cell_Value <= Max_Valid_Cell_Value / 2 then
                     Merged_Value := 2 * Read_Index_Cell_Value;
                     Line (Write_Index - 1) := Merged_Value;
                     Line (Read_Index) := Empty_Cell;
                     Last_Merged := Write_Index - 1;
                     Any_Merge_Done := True;
                     if Score <= Score_Type'Last - Score_Type (Merged_Value)
                     then
                        Score := Score + Score_Type (Merged_Value);
                     else
                        Score := Score_Type'Last;
                     end if;
                  else
                     --  Defensive: avoid overflow if merge would exceed max.
                     if Read_Index /= Write_Index then
                        if Write_Index in Start_Index .. End_Index then
                           Line (Write_Index) := Read_Index_Cell_Value;
                        end if;
                        Line (Read_Index) := Empty_Cell;
                     end if;
                     if Write_Index < End_Index + 1 then
                        Write_Index := Write_Index + 1;
                     end if;
                  end if;
               else
                  --  Move tile to write position
                  if Read_Index /= Write_Index then
                     if Write_Index in Start_Index .. End_Index then
                        Line (Write_Index) := Read_Index_Cell_Value;
                     end if;
                     Line (Read_Index) := Empty_Cell;
                  end if;
                  if Write_Index < End_Index + 1 then
                     Write_Index := Write_Index + 1;
                  end if;
               end if;
            end if;
         end;
      end loop;
   end Slide_And_Merge;

   --  Reverses a slice in place (extracted for SPARK verification)
   procedure Reverse_Slice
     (S : in out Slice_Type; Size : Board_Size_Type) is
      Temp       : Cell_Value;
   begin
      if Size <= 1 then
         return;
      end if;

      for Offset in 0 .. (Size / 2 - 1) loop
         declare
            Left  : constant Board_Index :=
              Board_Index (Integer (S'First) + Offset);
            Right : constant Board_Index :=
              Board_Index (Integer (S'First) + Integer (Size) - 1 - Offset);
         begin
            Temp := S (Left);
            S (Left) := S (Right);
            S (Right) := Temp;
         end;
      end loop;
   end Reverse_Slice;

   --  Wrapper handling oppositde direction by reversing existing slice
   procedure Process_Slice
     (Slice                   : in out Slice_Type;
      Size                    : Board_Size_Type;
      Iterate_Ascending_Index : Boolean;
      Score                   : out Score_Type) is
   begin
      if Iterate_Ascending_Index then
         Slide_And_Merge (Slice, Size, Score);
      else
         Reverse_Slice (Slice, Size);
         Slide_And_Merge (Slice, Size, Score);
         Reverse_Slice (Slice, Size);
      end if;
   end Process_Slice;


   function Line_Would_Change
     (Line : Slice_Type;
      Size : Board_Size_Type;
      Iterate_Ascending_Index : Boolean) return Boolean
   is
      Copy         : Slice_Type := Line;
      Unused_Score : Score_Type;
   begin
      Process_Slice (Copy, Size, Iterate_Ascending_Index, Unused_Score);
      return Copy /= Line;
   end Line_Would_Change;

   function Is_Move_Possible
     (Board : Board_Type; Size : Board_Size_Type; Direction : Direction_Type)
      return Boolean
   is
      Slice : Slice_Type := (others => Empty_Cell);
   begin
      case Direction is
         when Up    =>
            for C in Board_Index range 1 .. Board_Index (Size) loop
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Slice (R) := Board (R, C);
               end loop;
               if Line_Would_Change
                    (Slice, Size, Iterate_Ascending_Index => True)
               then
                  return True;
               end if;
            end loop;

         when Down  =>
            for C in Board_Index range 1 .. Board_Index (Size) loop
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Slice (R) := Board (R, C);
               end loop;
               if Line_Would_Change
                    (Slice, Size, Iterate_Ascending_Index => False)
               then
                  return True;
               end if;
            end loop;

         when Left  =>
            for R in Board_Index range 1 .. Board_Index (Size) loop
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Slice (C) := Board (R, C);
               end loop;
               if Line_Would_Change
                    (Slice, Size, Iterate_Ascending_Index => True)
               then
                  return True;
               end if;
            end loop;

         when Right =>
            for R in Board_Index range 1 .. Board_Index (Size) loop
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Slice (C) := Board (R, C);
               end loop;
               if Line_Would_Change
                    (Slice, Size, Iterate_Ascending_Index => False)
               then
                  return True;
               end if;
            end loop;
      end case;
      return False;
   end Is_Move_Possible;

   -- Tiles stop at Reached_Board_End, Merged_With_Tile, or Blocked_By_Tile (see Tile_Stop_Reason)
   procedure Move_Tiles
     (Board     : in out Board_Type;
      Size      : Board_Size_Type;
      Direction : Direction_Type;
      Score     : out Score_Type)
   is
      Line       : Slice_Type := (others => Empty_Cell);
      Line_Score : Score_Type;
   begin
      Score := 0;
      case Direction is
         when Up    =>
            for C in Board_Index range 1 .. Board_Index (Size) loop
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Line (R) := Board (R, C);
               end loop;
               Process_Slice
                 (Line,
                  Size,
                  Iterate_Ascending_Index => True,
                  Score => Line_Score);
               if Score <= Score_Type'Last - Line_Score then
                  Score := Score + Line_Score;
               else
                  Score := Score_Type'Last;
               end if;
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Board (R, C) := Line (R);
               end loop;
            end loop;

         when Down  =>
            for C in Board_Index range 1 .. Board_Index (Size) loop
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Line (R) := Board (R, C);
               end loop;
               Process_Slice
                 (Line,
                  Size,
                  Iterate_Ascending_Index => False,
                  Score => Line_Score);
               if Score <= Score_Type'Last - Line_Score then
                  Score := Score + Line_Score;
               else
                  Score := Score_Type'Last;
               end if;
               for R in Board_Index range 1 .. Board_Index (Size) loop
                  Board (R, C) := Line (R);
               end loop;
            end loop;

         when Left  =>
            for R in Board_Index range 1 .. Board_Index (Size) loop
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Line (C) := Board (R, C);
               end loop;
               Process_Slice
                 (Line,
                  Size,
                  Iterate_Ascending_Index => True,
                  Score => Line_Score);
               if Score <= Score_Type'Last - Line_Score then
                  Score := Score + Line_Score;
               else
                  Score := Score_Type'Last;
               end if;
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Board (R, C) := Line (C);
               end loop;
            end loop;

         when Right =>
            for R in Board_Index range 1 .. Board_Index (Size) loop
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Line (C) := Board (R, C);
               end loop;
               Process_Slice
                 (Line,
                  Size,
                  Iterate_Ascending_Index => False,
                  Score => Line_Score);
               if Score <= Score_Type'Last - Line_Score then
                  Score := Score + Line_Score;
               else
                  Score := Score_Type'Last;
               end if;
               for C in Board_Index range 1 .. Board_Index (Size) loop
                  Board (R, C) := Line (C);
               end loop;
            end loop;
      end case;
   end Move_Tiles;

   function Add_Random_Tile
     (Board : in out Board_Type; Size : Board_Size_Type) return Boolean
   with SPARK_Mode => Off
   is
      C   : constant Natural := Count_Empty_Cells (Board, Size);
      N   : Positive;
      Row : Board_Index;
      Col : Board_Index;
   begin
      if C = 0 then
         return False;
      end if;
      N := Logic.Random.Random_Index (C);
      --  Map the random rank N (1..number of empty cells) to concrete
      --  board coordinates by scanning empties in row-major order.
      Get_Empty_Cell (Board, Size, N, Row, Col);
      Board (Row, Col) := Logic.Random.Generate_Random_Cell_Value;
      return True;
   end Add_Random_Tile;

   function Is_Any_Move_Possible
     (Board : Board_Type; Size : Board_Size_Type) return Boolean is
   begin
      return
        Is_Move_Possible (Board, Size, Up)
        or else Is_Move_Possible (Board, Size, Down)
        or else Is_Move_Possible (Board, Size, Left)
        or else Is_Move_Possible (Board, Size, Right);
   end Is_Any_Move_Possible;

   function Has_Victory_Tile
     (Board : Board_Type; Size : Board_Size_Type) return Boolean is
   begin
      for R in Board_Index range 1 .. Board_Index (Size) loop
         for C in Board_Index range 1 .. Board_Index (Size) loop
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
      return
        State.Status = Playing
        and then Has_Victory_Tile (State.Board, State.Size);
   end Is_First_Victory;

   procedure Update_Game_Status (State : in out Game_State) is
   begin
      case State.Status is
         when Playing                      =>
            if Is_First_Victory (State) then
               State.Status := Victory_Achieved;
            elsif not Is_Any_Move_Possible (State.Board, State.Size) then
               State.Status := Game_Over;
            end if;

         when Continuing                   =>
            if not Is_Any_Move_Possible (State.Board, State.Size) then
               State.Status := Game_Over;
            end if;

         when Victory_Achieved | Game_Over =>
            -- These states are terminal until user action (Continue/Restart)
            null;
      end case;
   end Update_Game_Status;

end Logic.Game;
