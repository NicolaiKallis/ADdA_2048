with TUI.Display;      use TUI.Display;
with TUI.Input;        use TUI.Input;
with Logic.User;       use Logic.User;
with Logic.Game;       use Logic.Game;
with Logic.History;
with Types.Game_Types; use Types.Game_Types;

procedure Main is
   State         : Game_State;
   User_Input    : Input_Command;
   Input_Char    : Character;
   Extra_Input   : Boolean;
   Quit_Game     : Boolean;
   Move_Executed : Boolean;

begin
   Logic.History.Initialize;
   Initialize_New_Game (State);
   Show_Game (State);

   loop
      Get_User_Input (User_Input, Input_Char, Extra_Input);

      if Should_Process_Input (State, User_Input) then
         Quit_Game := Handle_User_Input (State, User_Input, Move_Executed);
         exit when Quit_Game;
      else
         Move_Executed := True;  --  Input wasn't processed, not a failed move
      end if;

      Show_Game (State);
      Show_Input_Warnings (User_Input, Input_Char, Extra_Input, Move_Executed);
   end loop;

end Main;
