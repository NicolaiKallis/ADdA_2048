with Types.Game_Types; use Types.Game_Types;

package Logic.User is

   Invalid_Input_Error : exception;

   type Input_Command is
     (Cmd_Move_Up,
      Cmd_Move_Down,
      Cmd_Move_Left,
      Cmd_Move_Right,
      Cmd_Restart,
      Cmd_Continue,
      Cmd_Quit,
      Cmd_Invalid);

   subtype User_Move_Type is Input_Command range Cmd_Move_Up .. Cmd_Move_Right;
   subtype User_Cmd_Type is Input_Command range Cmd_Restart .. Cmd_Quit;

   -- dispatcher: routes Input_Command to appropriate handler
   -- Returns True if the game should quit
   function Handle_User_Input
     (State : in out Game_State; User_Input : Input_Command)
      return Boolean;

   -- Returns True if the game should quit
   function Handle_System_Cmd
     (State : in out Game_State; Cmd : User_Cmd_Type)
      return Boolean;

   procedure Handle_User_Move
     (State : in out Game_State; User_Move : User_Move_Type);

end Logic.User;
