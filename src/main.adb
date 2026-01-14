with Game_Types;
with TUI.Display;

procedure Main is
   Static_Board : constant Game_Types.Board_Type :=
     ((2,    4,    8,    16),
      (4,    8,    16,   32),
      (8,    16,   32,   64),
      (16,   32,   64,   128));
begin
   TUI.Display.Show_Game (Static_Board);
end Main;
