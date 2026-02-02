with Types.Game_Types; use Types.Game_Types;

package Logic.History is

   Max_History_Size : constant := 10;

   -- Snapshot of game state for undo/redo
   type State_Snapshot is record
      Board      : Board_Type;
      Score      : Score_Type;
      Move_Count : Move_Count_Type;
   end record;

   -- Initialize history (clear all stacks)
   procedure Initialize
   with Post => not Can_Undo and then not Can_Redo;

   procedure Save_Before_Move (State : Game_State)
   with
     Pre  => Is_Valid_Board (State.Board),
     Post => Can_Undo and then not Can_Redo;

   -- Undo: swap current state with previous, returns False if no history
   function Undo (Current_Snapshot : in out State_Snapshot) return Boolean
   with
     Pre  => Is_Valid_Board (Current_Snapshot.Board),
     Post =>
       (if Undo'Result
        then Is_Valid_Board (Current_Snapshot.Board)
        else Current_Snapshot = Current_Snapshot'Old);

   -- Redo: swap current state with next from redo stack
   function Redo (Current_Snapshot : in out State_Snapshot) return Boolean
   with
     Pre  => Is_Valid_Board (Current_Snapshot.Board),
     Post =>
       (if Redo'Result
        then Is_Valid_Board (Current_Snapshot.Board)
        else Current_Snapshot = Current_Snapshot'Old);

   function Can_Undo return Boolean;
   function Can_Redo return Boolean;

end Logic.History;
