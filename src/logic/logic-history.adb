pragma SPARK_Mode (On);

package body Logic.History
  with
    Refined_State =>
      (Undo_State => (Undo_Stack, Undo_Top),
       Redo_State => (Redo_Stack, Redo_Top))
is

   type History_Index is range 0 .. Max_History_Size;
   subtype Valid_Index is History_Index range 1 .. Max_History_Size;

   --  Default snapshot for array initialization
   Default_Snapshot : constant State_Snapshot :=
     (Board      => (others => (others => Empty_Cell)),
      Score      => 0,
      Move_Count => 0);

   type History_Array is array (Valid_Index) of State_Snapshot;

   --  Undo stack (stores states before moves)
   Undo_Stack : History_Array := (others => Default_Snapshot);
   Undo_Top   : History_Index := 0;

   --  Redo stack (stores states that were undone)
   Redo_Stack : History_Array := (others => Default_Snapshot);
   Redo_Top   : History_Index := 0;

   function Undo_Stack_Size return Natural with Refined_Global => Undo_Top is
   begin
      return Natural (Undo_Top);
   end Undo_Stack_Size;

   function Redo_Stack_Size return Natural with Refined_Global => Redo_Top is
   begin
      return Natural (Redo_Top);
   end Redo_Stack_Size;

   procedure Initialize
   with
     Refined_Global => (Output => (Undo_Stack, Undo_Top, Redo_Stack, Redo_Top))
   is
   begin
      Undo_Stack := (others => Default_Snapshot);
      Undo_Top := 0;
      Redo_Stack := (others => Default_Snapshot);
      Redo_Top := 0;
   end Initialize;

   procedure Save_Before_Move (State : Game_State)
   with
     Refined_Global =>
       (In_Out => (Undo_Stack, Undo_Top), Output => (Redo_Stack, Redo_Top))
   is
      Snapshot : State_Snapshot;
   begin
      Snapshot.Board := State.Board;
      Snapshot.Score := State.Score;
      Snapshot.Move_Count := State.Move_Count;

      if Undo_Top < Max_History_Size then
         Undo_Top := Undo_Top + 1;
         Undo_Stack (Undo_Top) := Snapshot;
      else
         --  Shift array left (oldest entry discarded)
         for I in Valid_Index'First .. Valid_Index'Last - 1 loop
            pragma Loop_Invariant (I >= Valid_Index'First);
            pragma
              Loop_Invariant
                (for all J in Valid_Index'First .. I - 1 =>
                   Undo_Stack (J) = Undo_Stack'Loop_Entry (J + 1));
            Undo_Stack (I) := Undo_Stack (I + 1);
         end loop;
         Undo_Stack (Valid_Index'Last) := Snapshot;
      end if;

      --  Clear redo stack when a new move is made
      Redo_Stack := (others => Default_Snapshot);
      Redo_Top := 0;
   end Save_Before_Move;

   procedure Undo
     (Current_Snapshot : in out State_Snapshot; Success : out Boolean)
   with
     Refined_Global =>
       (Input => Undo_Stack, In_Out => (Undo_Top, Redo_Stack, Redo_Top))
   is
      Previous : State_Snapshot;
   begin
      if Undo_Top = 0 then
         Success := False;
         return;
      end if;

      --  Pop from undo stack
      Previous := Undo_Stack (Undo_Top);
      Undo_Top := Undo_Top - 1;

      --  Push current state to redo stack (if space available)
      if Redo_Top < Max_History_Size then
         Redo_Top := Redo_Top + 1;
         Redo_Stack (Redo_Top) := Current_Snapshot;
      end if;

      --  Return the previous state
      Current_Snapshot := Previous;
      Success := True;
   end Undo;

   procedure Redo
     (Current_Snapshot : in out State_Snapshot; Success : out Boolean)
   with
     Refined_Global =>
       (Input => Redo_Stack, In_Out => (Undo_Stack, Undo_Top, Redo_Top))
   is
      Next_State : State_Snapshot;
   begin
      if Redo_Top = 0 then
         Success := False;
         return;
      end if;

      --  Pop from redo stack
      Next_State := Redo_Stack (Redo_Top);
      Redo_Top := Redo_Top - 1;

      --  Push current state to undo stack (if space available)
      if Undo_Top < Max_History_Size then
         Undo_Top := Undo_Top + 1;
         Undo_Stack (Undo_Top) := Current_Snapshot;
      end if;

      Current_Snapshot := Next_State;
      Success := True;
   end Redo;

   function Can_Undo return Boolean with Refined_Global => Undo_Top is
   begin
      return Undo_Top > 0;
   end Can_Undo;

   function Can_Redo return Boolean with Refined_Global => Redo_Top is
   begin
      return Redo_Top > 0;
   end Can_Redo;

end Logic.History;
