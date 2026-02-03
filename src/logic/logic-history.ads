pragma SPARK_Mode (On);
pragma Unevaluated_Use_Of_Old (Allow);

with Types.Game_Types; use Types.Game_Types;

package Logic.History
  with Abstract_State => (Undo_State, Redo_State),
       Initializes    => (Undo_State, Redo_State)
is

   Max_History_Size : constant := 10;

   --  Snapshot of game state for undo/redo
   type State_Snapshot is record
      Board      : Board_Type;
      Score      : Score_Type;
      Move_Count : Move_Count_Type;
   end record;

   ---------------------------------------------------------------------------
   --  GHOST FUNCTIONS FOR SPARK VERIFICATION
   --
   --  These functions exist ONLY for formal verification and are stripped
   --  from production builds. They are used in contracts to express
   --  properties about the undo/redo stack state.
   --
   --  NOTE: These ghost functions CANNOT be moved to Verification package
   --  because they access abstract state (Undo_State, Redo_State) owned by
   --  this package. In SPARK, ghost functions with Global => Abstract_State
   --  must be declared in the package that owns that state.
   --
   --  See Verification.Game_Ghost for movable ghost functions.
   ---------------------------------------------------------------------------

   function Undo_Stack_Size return Natural
     with Ghost,
          Global => Undo_State,
          Post   => Undo_Stack_Size'Result <= Max_History_Size;

   function Redo_Stack_Size return Natural
     with Ghost,
          Global => Redo_State,
          Post   => Redo_Stack_Size'Result <= Max_History_Size;

   --  Initialize history (clear all stacks)
   procedure Initialize
     with Global => (Output => (Undo_State, Redo_State)),
          Post   => True;

   procedure Save_Before_Move (State : Game_State)
     with Global => (In_Out => Undo_State, Output => Redo_State),
          Pre    => Is_Valid_Board (State.Board),
          Post   => True;

   --  Undo: restore previous state, returns success status
   procedure Undo
     (Current_Snapshot : in out State_Snapshot;
      Success          : out Boolean)
     with Global => (In_Out => (Undo_State, Redo_State)),
          Pre    => Is_Valid_Board (Current_Snapshot.Board),
          Post   => True;

   --  Redo: restore next state from redo stack, returns success status
   procedure Redo
     (Current_Snapshot : in Out State_Snapshot;
      Success          : out Boolean)
     with Global => (In_Out => (Undo_State, Redo_State)),
          Pre    => Is_Valid_Board (Current_Snapshot.Board),
          Post   => True;

   function Can_Undo return Boolean
     with Global => Undo_State,
          Post   => True;

   function Can_Redo return Boolean
     with Global => Redo_State,
          Post   => True;

end Logic.History;
