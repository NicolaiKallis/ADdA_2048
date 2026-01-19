with TUI.Display;
with Types.Game_Types; use Types.Game_Types;
with Logic.Game;

procedure Main is
   Board : Board_Type;
begin
   Logic.Game.Initialize_Board (Board);
   TUI.Display.Show_Game (Board);
end Main;
