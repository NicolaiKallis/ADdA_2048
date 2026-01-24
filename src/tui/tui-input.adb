with Ada.Text_IO;
with Ada.Characters.Handling;
with Logic.User; use Logic.User;

package body TUI.Input is
   procedure Get_User_Input (UserInput : out Input_Command) is
      Input_Line : String (1 .. 100);
      Input_Len  : Natural;
      Char_Cmd   : Character;
   begin
      UserInput := Cmd_Invalid;
      Ada.Text_IO.Get_Line (Input_Line, Input_Len);

      if Input_Len > 0 then
         Char_Cmd := Ada.Characters.Handling.To_Upper (Input_Line (1));

         case Char_Cmd is
            when 'W'    =>
               UserInput := Cmd_Move_Up;

            when 'A'    =>
               UserInput := Cmd_Move_Left;

            when 'S'    =>
               UserInput := Cmd_Move_Down;

            when 'D'    =>
               UserInput := Cmd_Move_Right;

            when 'Q'    =>
               UserInput := Cmd_Quit;

            when 'R'    =>
               UserInput := Cmd_Restart;

            when others =>
               -- edge case
               UserInput := Cmd_Invalid;
         end case;
      end if;
   end Get_User_Input;

end TUI.Input;
