-- TUI Display implementation for 2048 game

with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Characters.Latin_1;
with Types.Game_Types;

package body TUI.Display is

   use Types.Game_Types;

   -- Format a cell value for display
   -- Empty cells show as dots, numbers are right-aligned
   function Format_Cell (Value : Cell_Value) return String is
      Cell_Width : constant := 5;
   begin
      if Value = Empty_Cell then
         return ".... ";
      else
         declare
            Value_Str : constant String := Natural'Image (Natural (Value));
            Trimmed   : constant String := Ada.Strings.Fixed.Trim (Value_Str, Ada.Strings.Left);
            Padding   : constant Natural := Cell_Width - Trimmed'Length;
         begin
            return (1 .. Padding => ' ') & Trimmed;
         end;
      end if;
   end Format_Cell;

   procedure Show_Board (Board : Board_Type) is
      Horizontal_Line : constant String := "+-----+-----+-----+-----+";
      Vertical_Line   : constant String := "|";
   begin
      Ada.Text_IO.Put_Line (Horizontal_Line);

      for Row in Board_Index loop
         Ada.Text_IO.Put (Vertical_Line);
         for Col in Board_Index loop
            Ada.Text_IO.Put (Format_Cell (Board (Row, Col)));
            Ada.Text_IO.Put (Vertical_Line);
         end loop;
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line (Horizontal_Line);
      end loop;
   end Show_Board;

   procedure Show_Stats (High_Score : Natural; Moves : Natural) is
   begin
      Ada.Text_IO.Put ("High Score: ");
      Ada.Text_IO.Put (Natural'Image (High_Score));
      Ada.Text_IO.Put ("    Moves: ");
      Ada.Text_IO.Put_Line (Natural'Image (Moves));
   end Show_Stats;

   procedure Clear_Screen is
   begin
      -- ANSI escape sequence to clear screen and move cursor to top-left
      Ada.Text_IO.Put (Ada.Characters.Latin_1.ESC & "[2J" & Ada.Characters.Latin_1.ESC & "[H");
   end Clear_Screen;

   procedure Show_Game (Board : Board_Type) is
      -- Static values for now as requested
      High_Score : constant Natural := 2048;
      Moves      : constant Natural := 42;
   begin
      Clear_Screen;
      Ada.Text_IO.Put_Line ("=== 2048 Game ===");
      Ada.Text_IO.New_Line;
      Show_Stats (High_Score, Moves);
      Ada.Text_IO.New_Line;
      Show_Board (Board);
   end Show_Game;

end TUI.Display;
