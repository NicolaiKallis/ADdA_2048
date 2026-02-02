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
   procedure Initialize;

   procedure Save_Before_Move (State : Game_State);

   -- Undo: swap current state with previous, returns False if no history
   function Undo
     (Current_Snapshot : in out State_Snapshot) return Boolean;

   -- Redo: swap current state with next from redo stack
   function Redo
     (Current_Snapshot : in Out State_Snapshot) return Boolean;

   function Can_Undo return Boolean;
   function Can_Redo return Boolean;

end Logic.History;
