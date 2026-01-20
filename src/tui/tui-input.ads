package TUI.Input is

   procedure Get_User_Input (UserInput : out Input_Command)
   with
     Post =>
       UserInput = Cmd_Quit
       or UserInput = Cmd_Restart
       or UserInput = Move_Up
       or UserInput = Move_Left
       or UserInput = Move_Down
       or UserInput = Move_Right;

end TUI.Input;
