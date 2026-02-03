with Logic.Game;
with Logic.History;
with Logic.Highscore;
with Types.Game_Types; use Types.Game_Types;

package body Logic.User is

   -- Convert Input_Command move to Direction_Type
   function To_Direction (Move : User_Move_Type) return Direction_Type is
   begin
      case Move is
         when Cmd_Move_Up    =>
            return Up;

         when Cmd_Move_Down  =>
            return Down;

         when Cmd_Move_Left  =>
            return Left;

         when Cmd_Move_Right =>
            return Right;
      end case;
   end To_Direction;

   procedure Handle_User_Move
     (State : in Out Game_State; User_Move : User_Move_Type)
   is
      Direction  : constant Direction_Type := To_Direction (User_Move);
      Move_Score : Score_Type;
      Success    : Boolean;
      Ignored    : Boolean;
   begin
      if Logic.Game.Is_Move_Possible (State.Board, Direction) then
         -- Save state before move for undo
         Logic.History.Save_Before_Move (State);

         Success :=
           Logic.Game.Process_Move (State.Board, Direction, Move_Score);
         State.Move_Count := State.Move_Count + 1;
         State.Score := State.Score + Move_Score;

         -- Update high score (both in-memory and persisted)
         if State.Score > State.High_Score then
            State.High_Score := State.Score;
            Ignored := Logic.Highscore.Update_Highscore (State.Score);
         end if;

         Logic.Game.Update_Game_Status (State);
      end if;
   end Handle_User_Move;

   procedure Handle_Undo (State : in Out Game_State) is
      Snapshot : Logic.History.State_Snapshot;
      Success  : Boolean;
   begin
      Snapshot.Board := State.Board;
      Snapshot.Score := State.Score;
      Snapshot.Move_Count := State.Move_Count;

      -- Try to undo
      Logic.History.Undo (Snapshot, Success);
      if Success then
         State.Board := Snapshot.Board;
         State.Score := Snapshot.Score;
         State.Move_Count := Snapshot.Move_Count;
         -- Reset status to playing (undo might undo a game over)
         State.Status := Playing;
         -- Re-evaluate game status
         Logic.Game.Update_Game_Status (State);
      end if;
   end Handle_Undo;

   procedure Handle_Redo (State : in Out Game_State) is
      Snapshot : Logic.History.State_Snapshot;
      Success  : Boolean;
   begin
      -- Create snapshot of current state
      Snapshot.Board := State.Board;
      Snapshot.Score := State.Score;
      Snapshot.Move_Count := State.Move_Count;

      -- Try to redo
      Logic.History.Redo (Snapshot, Success);
      if Success then
         State.Board := Snapshot.Board;
         State.Score := Snapshot.Score;
         State.Move_Count := Snapshot.Move_Count;
         -- Re-evaluate game status
         Logic.Game.Update_Game_Status (State);
      end if;
   end Handle_Redo;

   function Handle_System_Cmd
     (State : in Out Game_State; Cmd : User_Cmd_Type) return Boolean is
   begin
      case Cmd is
         when Cmd_Undo     =>
            Handle_Undo (State);
            return False;

         when Cmd_Redo     =>
            Handle_Redo (State);
            return False;

         when Cmd_Restart  =>
            Logic.Game.Initialize_New_Game (State);
            Logic.History.Initialize;
            return False;

         when Cmd_Continue =>
            if State.Status = Victory_Achieved then
               State.Status := Continuing;
            end if;
            return False;

         when Cmd_Quit     =>
            return True;
      end case;
   end Handle_System_Cmd;

   function Handle_User_Input
     (State : in Out Game_State; User_Input : Input_Command) return Boolean is
   begin
      case User_Input is
         when User_Move_Type =>
            Handle_User_Move (State, User_Input);
            return False;

         when User_Cmd_Type  =>
            return Handle_System_Cmd (State, User_Input);

         when Cmd_Invalid    =>
            raise Invalid_Input_Error;
      end case;
   end Handle_User_Input;

end Logic.User;
