with TUI.Display;      use TUI.Display;
with TUI.Input;        use TUI.Input;
with Logic.User;       use Logic.User;
with Logic.Game;       use Logic.Game;
with Types.Game_Types; use Types.Game_Types;

procedure Main is
   State      : Game_State;
   User_Input : Input_Command;
   Quit_Game  : Boolean;
begin
   Initialize_New_Game (State);
   Show_Game (State);

   loop
      Get_User_Input (User_Input);
      Quit_Game := Handle_User_Input (State, User_Input);
      exit when Quit_Game;
      Show_Game (State);
   end loop;

end Main;
