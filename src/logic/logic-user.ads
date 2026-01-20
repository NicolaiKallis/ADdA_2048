package Logic.User is

   Invalid_Input_Error : exception;

   type Input_Command is
     (Move_Up,
      Move_Down,
      Move_Left,
      Move_Right,
      Cmd_Restart,
      Cmd_Quit,
      Cmd_Invalid);

   subtype User_Move_Type is Input_Command range Move_Up .. Move_Right;
   subtype User_Cmd_Type is Input_Command range Cmd_Restart .. Cmd_Quit;

   procedure Handle_User_Input (UserInput : Input_Command);

   procedure Handle_System_Cmd (Cmd : User_Cmd_Type);

   procedure Handle_User_Move (Move : User_Move_Type);


end Logic.User;
