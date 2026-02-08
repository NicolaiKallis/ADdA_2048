with Ada.Text_IO;
with Ada.Characters.Handling;
with Ada.Strings.Fixed;
with Ada.Strings;
with Types.Game_Types;

package body TUI.Menu is

   Min_Board_Size     : constant Positive := Types.Game_Types.Min_Board_Size;
   Default_Board_Size : constant Positive :=
     Types.Game_Types.Default_Board_Size;
   Max_Board_Size     : constant Positive := Types.Game_Types.Max_Board_Size;
   Default_Size_Text  : constant String :=
     Ada.Strings.Fixed.Trim
       (Positive'Image (Default_Board_Size), Ada.Strings.Left);
   Max_Size_Text      : constant String :=
     Ada.Strings.Fixed.Trim
       (Positive'Image (Max_Board_Size), Ada.Strings.Left);
   Min_Size_Text      : constant String :=
     Ada.Strings.Fixed.Trim
       (Positive'Image (Min_Board_Size), Ada.Strings.Left);

   procedure Show_Start_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("=== 2048 ===");
      Ada.Text_IO.Put_Line ("1) Start game");
      Ada.Text_IO.Put_Line ("2) Rules");
      Ada.Text_IO.Put_Line ("3) Help");
      Ada.Text_IO.Put_Line ("Q) Quit");
      Ada.Text_IO.Put ("Select: ");
   end Show_Start_Menu;

   procedure Show_Rules is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("--- Rules ---");
      Ada.Text_IO.Put_Line ("- Move all tiles in one direction.");
      Ada.Text_IO.Put_Line ("- Equal tiles merge into one and add to score.");
      Ada.Text_IO.Put_Line ("- After each valid move, a new 2 or 4 appears.");
      Ada.Text_IO.Put_Line ("- Reach 2048 to win (you can continue).");
      Ada.Text_IO.Put_Line ("- Game ends when no moves are possible.");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Press Enter to return to menu...");
   end Show_Rules;

   procedure Show_Help is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("--- Help / Commands ---");
      Ada.Text_IO.Put_Line ("W/A/S/D : Move tiles");
      Ada.Text_IO.Put_Line ("U       : Undo");
      Ada.Text_IO.Put_Line ("Y       : Redo");
      Ada.Text_IO.Put_Line ("R       : Restart");
      Ada.Text_IO.Put_Line ("C       : Continue after victory");
      Ada.Text_IO.Put_Line ("Q       : Quit");
      Ada.Text_IO.Put_Line
        ("Note: only the first character on a line is used.");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Press Enter to return to menu...");
   end Show_Help;

   procedure Wait_For_Enter is
      Input_Line : String (1 .. 100);
      Input_Len  : Natural;
   begin
      Ada.Text_IO.Get_Line (Input_Line, Input_Len);
   end Wait_For_Enter;

   function Prompt_Board_Size return Types.Game_Types.Board_Size_Type is
      Input_Line : String (1 .. 100);
      Input_Len  : Natural;
      Parsed     : Positive := Default_Board_Size;
   begin
      loop
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put
           ("Board size ("
            & Min_Size_Text
            & "-"
            & Max_Size_Text
            & ", Enter for "
            & Default_Size_Text
            & "): ");
         Ada.Text_IO.Get_Line (Input_Line, Input_Len);

         if Input_Len = 0 then
            return Types.Game_Types.Board_Size_Type (Default_Board_Size);
         end if;

         declare
            Raw     : constant String := Input_Line (1 .. Input_Len);
            Cleaned : constant String :=
              Ada.Strings.Fixed.Trim (Raw, Ada.Strings.Both);
         begin
            if Cleaned'Length = 0 then
               return Types.Game_Types.Board_Size_Type (Default_Board_Size);
            end if;

            begin
               Parsed := Positive'Value (Cleaned);
               if Parsed < Min_Board_Size then
                  Ada.Text_IO.Put_Line
                    ("Minimum board size is " & Min_Size_Text & ".");
               elsif Parsed > Max_Board_Size then
                  Ada.Text_IO.Put_Line
                    ("Maximum board size is " & Max_Size_Text & ".");
               else
                  return Types.Game_Types.Board_Size_Type (Parsed);
               end if;
            exception
               when others =>
                  Ada.Text_IO.Put_Line
                    ("Please enter a valid positive number.");
            end;
         end;
      end loop;
   end Prompt_Board_Size;

   function Get_Menu_Selection return Menu_Selection is
      Input_Line : String (1 .. 100);
      Input_Len  : Natural;
      Choice     : Character := ' ';
      Result     : Menu_Selection :=
        (Action     => Menu_Quit,
         Board_Size => Types.Game_Types.Default_Board_Size);
   begin
      loop
         Show_Start_Menu;
         Ada.Text_IO.Get_Line (Input_Line, Input_Len);
         if Input_Len > 0 then
            Choice := Ada.Characters.Handling.To_Upper (Input_Line (1));
         else
            Choice := ' ';
         end if;

         case Choice is
            when '1'    =>
               Result.Action := Menu_Start_Game;
               Result.Board_Size := Prompt_Board_Size;
               return Result;

            when '2'    =>
               Show_Rules;
               Wait_For_Enter;

            when '3'    =>
               Show_Help;
               Wait_For_Enter;

            when 'Q'    =>
               Result.Action := Menu_Quit;
               return Result;

            when others =>
               Ada.Text_IO.Put_Line ("Invalid selection. Please try again.");
         end case;
      end loop;
   end Get_Menu_Selection;

end TUI.Menu;
