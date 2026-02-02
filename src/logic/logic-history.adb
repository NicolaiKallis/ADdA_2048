package body Logic.History is

   type History_Index is range 0 .. Max_History_Size;
   subtype Valid_Index is History_Index range 1 .. Max_History_Size;

   type History_Array is array (Valid_Index) of State_Snapshot;

   -- Undo stack (stores states before moves)
   Undo_Stack : History_Array;
   Undo_Top   : History_Index := 0;

   -- Redo stack (stores states that were undone)
   Redo_Stack : History_Array;
   Redo_Top   : History_Index := 0;

   procedure Initialize is
   begin
      Undo_Top := 0;
      Redo_Top := 0;
   end Initialize;

   procedure Save_Before_Move (State : Game_State) is
      Snapshot : State_Snapshot;
   begin
      Snapshot.Board := State.Board;
      Snapshot.Score := State.Score;
      Snapshot.Move_Count := State.Move_Count;

      if Undo_Top < Max_History_Size then
         Undo_Top := Undo_Top + 1;
         Undo_Stack (Undo_Top) := Snapshot;
      else
         for I in Valid_Index'First .. Valid_Index'Last - 1 loop
            Undo_Stack (I) := Undo_Stack (I + 1);
         end loop;
         Undo_Stack (Valid_Index'Last) := Snapshot;
      end if;

      -- Clear redo stack when a new move is made
      Redo_Top := 0;
   end Save_Before_Move;

   function Undo (Current_Snapshot : in Out State_Snapshot) return Boolean is
      Previous : State_Snapshot;
   begin
      if Undo_Top = 0 then
         return False;
      end if;

      -- Pop from undo stack
      Previous := Undo_Stack (Undo_Top);
      Undo_Top := Undo_Top - 1;

      -- Push current state to redo stack
      if Redo_Top < Max_History_Size then
         Redo_Top := Redo_Top + 1;
         Redo_Stack (Redo_Top) := Current_Snapshot;
      end if;

      -- Return the previous state
      Current_Snapshot := Previous;
      return True;
   end Undo;

   function Redo (Current_Snapshot : in Out State_Snapshot) return Boolean is
      Next_State : State_Snapshot;
   begin
      if Redo_Top = 0 then
         return False;
      end if;

      -- Pop from redo stack
      Next_State := Redo_Stack (Redo_Top);
      Redo_Top := Redo_Top - 1;

      -- Push current state to undo stack
      if Undo_Top < Max_History_Size then
         Undo_Top := Undo_Top + 1;
         Undo_Stack (Undo_Top) := Current_Snapshot;
      end if;

      Current_Snapshot := Next_State;
      return True;
   end Redo;

   function Can_Undo return Boolean is
   begin
      return Undo_Top > 0;
   end Can_Undo;

   function Can_Redo return Boolean is
   begin
      return Redo_Top > 0;
   end Can_Redo;

end Logic.History;
