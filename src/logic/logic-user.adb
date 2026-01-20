package body Logic.User is

   procedure Handle_Move (Move : User_Move_Type) return User_Move_Type is
   begin
      case Move is
         when Move_Up    =>
            Move_Board_Up;

         when Move_Down  =>
            Move_Board_Down;

         when Move_Left  =>
            Move_Board_Left;

         when Move_Right =>
            Move_Board_Right;
      end case;
   end Handle_Move;

   function Handle_System_Cmd (Cmd : User_Cmd_Type) return User_Cmd_Type is
   begin
      case Cmd is
         when Cmd_Restart =>
            Restart_Game;

         when Cmd_Quit    =>
            Quit_Game;
      end case;
   end Handle_System_Cmd;

   function Handle_User_Input (UserInput : Input_Command) return Input_Command
   is
   begin
      case UserInput is
         when User_Move_Type =>
            Handle_Move (UserInput);

         when User_Cmd_Type  =>
            Handle_System_Cmd (UserInput);

         when Cmd_Invalid    =>
            -- TODO: handle invalid input -> raise exception
            raise Invalid_Input_Error;
      end case;
   end Handle_User_Input;

end Logic.User;
