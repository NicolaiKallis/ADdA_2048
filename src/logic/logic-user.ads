with Types.Game_Types; use Types.Game_Types;

package Logic.User is

   Invalid_Input_Error : exception;

   -- Canonical command set accepted from user input.
   type Input_Command is
     (Cmd_Move_Up,
      Cmd_Move_Down,
      Cmd_Move_Left,
      Cmd_Move_Right,
      Cmd_Undo,
      Cmd_Redo,
      Cmd_Restart,
      Cmd_Continue,
      Cmd_Quit,
      Cmd_Invalid);

   -- Command subset that corresponds to directional board moves.
   subtype User_Move_Type is Input_Command range Cmd_Move_Up .. Cmd_Move_Right;
   -- Command subset for non-move gameplay/system actions.
   subtype User_Cmd_Type is Input_Command range Cmd_Undo .. Cmd_Quit;

   -- Convert a validated move command into a board direction.
   function To_Direction (Move : User_Move_Type) return Direction_Type;

   -- Gate which inputs are processed based on game status
   function Should_Process_Input
     (State : Game_State; User_Input : Input_Command) return Boolean;

   -- Route one command to the appropriate move/system handler.
   -- Returns True if the game should quit
   -- Move_Executed is True if a move command actually changed the board
   function Handle_User_Input
     (State         : in out Game_State;
      User_Input    : Input_Command;
      Move_Executed : out Boolean) return Boolean
   with
     Pre  => Is_Valid_Board (State.Board),
     Post =>
       Is_Valid_Board (State.Board)
       and then Handle_User_Input'Result = (User_Input = Cmd_Quit);

   -- Process non-move commands like undo, redo, restart, continue, and quit.
   -- Returns True if the game should quit
   function Handle_System_Cmd
     (State : in out Game_State; Cmd : User_Cmd_Type) return Boolean
   with
     Pre  => Is_Valid_Board (State.Board),
     Post =>
       Is_Valid_Board (State.Board)
       and then Handle_System_Cmd'Result = (Cmd = Cmd_Quit);

   -- Execute a directional move command and report whether board state changed.
   -- Move_Executed is True if the move actually changed the board
   procedure Handle_User_Move
     (State         : in out Game_State;
      User_Move     : User_Move_Type;
      Move_Executed : out Boolean)
   with
     Pre  => Is_Valid_Board (State.Board),
     Post => Is_Valid_Board (State.Board);

end Logic.User;
