with TUI.Display;
with TUI.Input;
with Types.Game_Types; use Types.Game_Types;
with Logic.Game;
with Logic.User; use Logic.User;

procedure Main is
   Board      : Board_Type;
   UserInput  : Input_Command;
   Should_Quit : Boolean;
begin
   Logic.Game.Initialize_Board (Board);
   TUI.Display.Show_Game (Board);

   loop
      TUI.Input.Get_User_Input (UserInput);
      Should_Quit := Logic.User.Handle_User_Input (Board, UserInput);
      exit when Should_Quit;
      TUI.Display.Show_Game (Board);
   end loop;

end Main;
