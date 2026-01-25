with TUI.Display;      use TUI.Display;
with TUI.Input;        use TUI.Input;
with Logic.User;       use Logic.User;
with Logic.Game;       use Logic.Game;
with Types.Game_Types; use Types.Game_Types;

procedure Main is
   State      : Game_State;
   User_Input : Input_Command;
   Quit_Game  : Boolean;

   function Should_Process_Input return Boolean is
   begin
      case State.Status is
         when Playing | Continuing =>
            return True;

         when Victory_Achieved     =>
            return User_Input in User_Cmd_Type;

         when Game_Over            =>
            return User_Input = Cmd_Restart or else User_Input = Cmd_Quit;
      end case;
   end Should_Process_Input;

begin
   Initialize_New_Game (State);
   Show_Game (State);

   loop
      Get_User_Input (User_Input);

      if Should_Process_Input then
         Quit_Game := Handle_User_Input (State, User_Input);
         exit when Quit_Game;
      end if;

      Show_Game (State);
   end loop;

end Main;
