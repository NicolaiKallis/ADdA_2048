-------------------------------------------------------------------------------
--  Verification.Game_Ghost
--
--  Ghost functions for SPARK verification of game logic.
--  These functions are used ONLY in contracts and are stripped at runtime.
--
--  Usage in Logic.Game:
--    procedure Slide_And_Merge (Line : in out Slice_Type; Score : out Score_Type)
--      with Pre  => Verification.Game_Ghost.All_Valid_Cells (Line),
--           Post => Verification.Game_Ghost.Slice_Sum (Line'Old) = ...
--
--  These functions help prove:
--    - Sum conservation (tiles don't disappear or appear incorrectly)
--    - Cell validity (all values are legal game values)
--    - Compaction correctness (tiles slide properly)
-------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Types.Game_Types; use Types.Game_Types;

package Verification.Game_Ghost
  with Pure, Ghost
is

   ---------------------------------------------------------------------------
   --  Slice_Sum
   --
   --  Calculates the sum of all cell values in a slice.
   --  Used to prove that sliding/merging conserves total value
   --  (minus score additions from merges).
   ---------------------------------------------------------------------------
   function Slice_Sum (S : Slice_Type) return Natural
   with
     Post => Slice_Sum'Result <= Natural'Last;

   ---------------------------------------------------------------------------
   --  Non_Empty_Count
   --
   --  Counts the number of non-empty cells in a slice.
   --  Used to prove that compaction doesn't lose or create tiles.
   ---------------------------------------------------------------------------
   function Non_Empty_Count (S : Slice_Type) return Natural
   with Post => Non_Empty_Count'Result <= S'Length;

   ---------------------------------------------------------------------------
   --  Is_Compacted
   --
   --  Checks if all non-empty cells are compacted to the front of the slice.
   --  After sliding, there should be no empty cells followed by non-empty cells.
   ---------------------------------------------------------------------------
   function Is_Compacted (S : Slice_Type) return Boolean;

   ---------------------------------------------------------------------------
   --  All_Valid_Cells
   --
   --  Verifies that every cell in the slice contains a valid game value
   --  (either Empty_Cell or a power of 2 within valid range).
   ---------------------------------------------------------------------------
   function All_Valid_Cells (S : Slice_Type) return Boolean
   with
     Post =>
       All_Valid_Cells'Result
       = (for all I in S'Range => Is_Valid_Cell_Value (S (I)));

end Verification.Game_Ghost;
