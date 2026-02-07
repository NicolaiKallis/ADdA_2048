with Logic.User;

package TUI.Input is
   use Logic.User;

   -- procedure instead of function to adhere to Ada 2022 spec
   -- where I/O operations are not allowed in functions.
   -- TODO: Lookup source of this rule.
   procedure Get_User_Input
     (UserInput   : out Input_Command;
      Input_Char  : out Character;
      Extra_Input : out Boolean);

end TUI.Input;
