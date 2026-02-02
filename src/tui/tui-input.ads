with Logic.User;

package TUI.Input is
   use Logic.User;

   -- procedure instead of function to adhere to Ada 2022 spec
   -- where I/O operations are not allowed in functions.
   -- TODO: Lookup source of this rule.
   procedure Get_User_Input (UserInput : out Input_Command)
   with
     -- TODO: Assess the useability of this post condition. Remove if necessary
     Post =>
       UserInput = Cmd_Quit
       or UserInput = Cmd_Restart
       or UserInput = Cmd_Continue
       or UserInput = Cmd_Move_Up
       or UserInput = Cmd_Move_Left
       or UserInput = Cmd_Move_Down
       or UserInput = Cmd_Move_Right
       or UserInput = Cmd_Undo
       or UserInput = Cmd_Redo
       or UserInput = Cmd_Invalid;

end TUI.Input;
