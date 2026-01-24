with Logic.Game;
with Types.Game_Types; use Types.Game_Types;

package body Logic.User is

   -- Convert Input_Command move to Direction_Type
   function To_Direction (Move : User_Move_Type) return Direction_Type is
   begin
      case Move is
         when Cmd_Move_Up    =>
            return Up;

         when Cmd_Move_Down  =>
            return Down;

         when Cmd_Move_Left  =>
            return Left;

         when Cmd_Move_Right =>
            return Right;
      end case;
   end To_Direction;

   procedure Handle_User_Move
     (Board : in out Board_Type; Move : User_Move_Type)
   is
      Direction : constant Direction_Type := To_Direction (Move);
      Success   : Boolean;
   begin
      if Logic.Game.Is_Move_Possible (Board, Direction) then
         Success := Logic.Game.Process_Move (Board, Direction);

      end if;
   end Handle_User_Move;

   function Handle_System_Cmd
     (Board : in out Board_Type; Cmd : User_Cmd_Type) return Boolean is
   begin
      case Cmd is
         when Cmd_Restart =>
            Logic.Game.Initialize_Board (Board);
            return False;

         when Cmd_Quit    =>
            return True;
      end case;
   end Handle_System_Cmd;

   function Handle_User_Input
     (Board : in out Board_Type; UserInput : Input_Command) return Boolean is
   begin
      case UserInput is
         when User_Move_Type =>
            Handle_User_Move (Board, UserInput);
            return False;

         when User_Cmd_Type  =>
            return Handle_System_Cmd (Board, UserInput);

         when Cmd_Invalid    =>
            raise Invalid_Input_Error;
      end case;
   end Handle_User_Input;

end Logic.User;
