-- TUI Display implementation for 2048 game

with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Characters.Latin_1;
with Types.Game_Types;
with Logic.User; use Logic.User;
with Logic.History;

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
            Trimmed   : constant String :=
              Ada.Strings.Fixed.Trim (Value_Str, Ada.Strings.Left);
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

   procedure Show_Stats (Move_Count : Move_Count_Type; High_Score : Score_Type)
   is
   begin
      Ada.Text_IO.Put ("High Score: ");
      Ada.Text_IO.Put (Score_Type'Image (High_Score));
      Ada.Text_IO.Put ("    Moves: ");
      Ada.Text_IO.Put_Line (Move_Count_Type'Image (Move_Count));
   end Show_Stats;

   procedure Clear_Screen is
   begin
      -- ANSI escape sequence to clear screen and move cursor to top-left
      Ada.Text_IO.Put
        (Ada.Characters.Latin_1.ESC
         & "[2J"
         & Ada.Characters.Latin_1.ESC
         & "[H");
   end Clear_Screen;

   procedure Show_Undo_Redo_Status is
   begin
      if Logic.History.Can_Undo or else Logic.History.Can_Redo then
         Ada.Text_IO.Put ("| ");
         if Logic.History.Can_Undo then
            Ada.Text_IO.Put ("U: Undo ");
         end if;
         if Logic.History.Can_Redo then
            Ada.Text_IO.Put ("Y: Redo ");
         end if;
      end if;
   end Show_Undo_Redo_Status;

   procedure Show_Status_Message (Status : Game_Status) is
   begin
      case Status is
         when Playing          =>
            Ada.Text_IO.Put ("W/A/S/D: Move | R: Restart | Q: Quit");
            Show_Undo_Redo_Status;
            Ada.Text_IO.New_Line;

         when Victory_Achieved =>
            Ada.Text_IO.Put_Line ("*** YOU WIN! ***");
            Ada.Text_IO.Put ("C: Continue | R: Restart | Q: Quit");
            Show_Undo_Redo_Status;
            Ada.Text_IO.New_Line;

         when Continuing       =>
            Ada.Text_IO.Put_Line ("Keep going for a higher score!");
            Ada.Text_IO.Put ("W/A/S/D: Move | R: Restart | Q: Quit");
            Show_Undo_Redo_Status;
            Ada.Text_IO.New_Line;

         when Game_Over        =>
            Ada.Text_IO.Put_Line ("*** GAME OVER ***");
            Ada.Text_IO.Put_Line ("No more moves available!");
            Ada.Text_IO.Put ("R: Restart | Q: Quit");
            Show_Undo_Redo_Status;
            Ada.Text_IO.New_Line;
      end case;
   end Show_Status_Message;

   procedure Show_Game (State : Game_State) is
   begin
      Clear_Screen;
      Ada.Text_IO.Put_Line ("=== 2048 Game ===");
      Ada.Text_IO.New_Line;
      Show_Stats (State.Move_Count, State.High_Score);
      Ada.Text_IO.Put ("Score: ");
      Ada.Text_IO.Put_Line (Score_Type'Image (State.Score));
      Ada.Text_IO.New_Line;
      Show_Board (State.Board);
      Ada.Text_IO.New_Line;
      Show_Status_Message (State.Status);
   end Show_Game;

   procedure Show_Invalid_Input_Warning (Input_Char : Character) is
   begin
      Ada.Text_IO.Put ("Warning: '");
      Ada.Text_IO.Put (Input_Char);
      Ada.Text_IO.Put_Line ("' is not a valid command.");
      Ada.Text_IO.Put_Line
        ("Valid commands: W/A/S/D (move), U (undo), Y (redo), R (restart), Q (quit)");
   end Show_Invalid_Input_Warning;

   procedure Show_Extra_Input_Warning (Input_Char : Character) is
   begin
      Ada.Text_IO.Put ("Note: extra input ignored; using '");
      Ada.Text_IO.Put (Input_Char);
      Ada.Text_IO.Put_Line ("'.");
   end Show_Extra_Input_Warning;

   procedure Show_Input_Warnings
     (User_Input    : Input_Command;
      Input_Char    : Character;
      Extra_Input   : Boolean;
      Move_Executed : Boolean) is
   begin
      if User_Input = Cmd_Invalid and then Input_Char /= ' ' then
         Show_Invalid_Input_Warning (Input_Char);
      end if;

      if Extra_Input then
         Show_Extra_Input_Warning (Input_Char);
      end if;

      if User_Input in User_Move_Type and then not Move_Executed then
         Show_Move_Not_Possible_Warning (To_Direction (User_Input));
      end if;
   end Show_Input_Warnings;

   procedure Show_Move_Not_Possible_Warning (Direction : Direction_Type) is
      Direction_Name : constant String :=
        (case Direction is
           when Up    => "up",
           when Down  => "down",
           when Left  => "left",
           when Right => "right");
   begin
      Ada.Text_IO.Put ("Cannot move ");
      Ada.Text_IO.Put (Direction_Name);
      Ada.Text_IO.Put_Line (" - no tiles can shift in that direction.");
   end Show_Move_Not_Possible_Warning;

end TUI.Display;
