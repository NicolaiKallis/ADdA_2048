pragma SPARK_Mode (On);

with Types.Game_Types; use Types.Game_Types;

with Verification.Game_Ghost;

package Logic.Game is

   function Count_Empty_Cells
     (Board : Board_Type; Size : Board_Size_Type) return Natural
   with
     Pre  => Is_Valid_Board (Board),
     Post => Count_Empty_Cells'Result in 0 .. Size * Size;

   function Is_Board_Full
     (Board : Board_Type; Size : Board_Size_Type) return Boolean
   with
     Pre  => Is_Valid_Board (Board),
     Post => Is_Board_Full'Result = (Count_Empty_Cells (Board, Size) = 0);

   procedure Initialize_New_Game
     (State : out Game_State; Size : Board_Size_Type)
   with
     Post =>
       State.Status = Playing
       and then State.Size = Size
       and then State.Move_Count = 0
       and then State.Score = 0
       and then Is_Valid_Board (State.Board);

   procedure Initialize_Board
     (Board : out Board_Type; Size : Board_Size_Type)
   with
     Post =>
       (for some R in Board_Index =>
          (R <= Board_Index (Size)
           and then
             (for some C in Board_Index =>
                (C <= Board_Index (Size)
                 and then (Board (R, C) = 2 or Board (R, C) = 4)))))
       and then Is_Valid_Board (Board);

   function Add_Random_Tile
     (Board : in out Board_Type; Size : Board_Size_Type) return Boolean
   with SPARK_Mode => Off;

   function Process_Move
     (Board     : in out Board_Type;
      Size      : Board_Size_Type;
      Direction : Direction_Type;
      Score     : out Score_Type) return Boolean
   with SPARK_Mode => Off;

   procedure Move_Tiles
     (Board     : in out Board_Type;
      Size      : Board_Size_Type;
      Direction : Direction_Type;
      Score     : out Score_Type)
   with
     Pre  =>
       Is_Valid_Board (Board)
       and then Is_Move_Possible (Board, Size, Direction),
     Post => True;

   function Is_Move_Possible
     (Board : Board_Type; Size : Board_Size_Type; Direction : Direction_Type)
      return Boolean
   with Pre => Is_Valid_Board (Board);

   function Is_Any_Move_Possible
     (Board : Board_Type; Size : Board_Size_Type) return Boolean
   with Pre => Is_Valid_Board (Board);

   function Has_Victory_Tile
     (Board : Board_Type; Size : Board_Size_Type) return Boolean
   with
     Pre  => Is_Valid_Board (Board),
     Post =>
       (if Has_Victory_Tile'Result
        then
          (for some R in Board_Index =>
             (R <= Board_Index (Size)
              and then
                (for some C in Board_Index =>
                   (C <= Board_Index (Size)
                    and then Board (R, C) >= Victory_Tile_Value)))));

   -- Call this after each move to detect victory or game over
   procedure Update_Game_Status (State : in out Game_State)
   with
     Pre  => Is_Valid_Board (State.Board),
     Post =>
       Is_Valid_Board (State.Board)
       and then State.Board = State.Board'Old
       and then State.Score = State.Score'Old
       and then State.High_Score = State.High_Score'Old
       and then State.Move_Count = State.Move_Count'Old;

private

   procedure Get_Empty_Cell
     (Board  : Board_Type;
      Size   : Board_Size_Type;
      N      : Positive;
      Row    : out Board_Index;
      Column : out Board_Index)
   with
     Pre  =>
      Is_Valid_Board (Board) and then N <= Count_Empty_Cells (Board, Size),
    Post =>
      Row in Board_Index
      and then Column in Board_Index
      and then Row <= Board_Index (Size)
      and then Column <= Board_Index (Size);

   --  Helper method to reverse a slice in place
   procedure Reverse_Slice
     (S : in out Slice_Type; Size : Board_Size_Type)
   with Pre => True, Post => True;

   ---------------------------------------------------------------------------
   --  Slide_And_Merge (Two-Pointer Algorithm)
   --
   --  Core algorithm that slides all tiles toward the beginning of a slice
   --  and merges adjacent tiles of equal value.
   --
   --  Algorithm: Two-Pointer Technique
   --  --------------------------------
   --  Uses two indices traversing the array:
   --
   --    Read_Index  - Scans through every cell (the "reader")
   --    Write_Index - Tracks where to place the next tile (the "writer")
   --
   --  The reader advances every iteration; the writer only advances when
   --  a tile is placed (not merged). This creates a compacted result where
   --  all non-empty tiles are at the front with no gaps.
   --
   --  Merge Rule: A tile can only merge ONCE per move. This prevents
   --  [2,2,4] from incorrectly becoming [8] instead of [4,4].
   --
   --  Complexity Analysis (Big O Notation)
   --  ------------------------------------
   --  Let n = Board_Size (number of cells in a slice).
   --
   --  This implementation:     O(n) time, O(1) space
   --    - Single pass through the array
   --    - In-place modification, no auxiliary data structures
   --
   --  Naive nested-loop approach: O(n^2) time, O(1) space
   --    - Repeatedly scan for tiles to move
   --    - Each tile might require scanning remaining cells
   --
   --  The two-pointer technique achieves optimal linear time complexity
   --  by maintaining the invariant that Write_Index <= Read_Index,
   --  ensuring each cell is visited exactly once.
   --
   --  Example: [2, 0, 2, 4] sliding left
   --  ---------------------------------
   --  Step 1: Read=1 (2), Write=1 -> place at 1, Write=2  [2, 0, 2, 4]
   --  Step 2: Read=2 (0)          -> skip empty           [2, 0, 2, 4]
   --  Step 3: Read=3 (2), Write=2 -> merge with pos 1!    [4, 0, 0, 4]
   --  Step 4: Read=4 (4), Write=2 -> place at 2, Write=3  [4, 4, 0, 0]
   --  Result: [4, 4, 0, 0]
   ---------------------------------------------------------------------------
   procedure Slide_And_Merge
     (Line : in out Slice_Type; Size : Board_Size_Type; Score : out Score_Type)
   with Pre => True, Post => True;

   procedure Process_Slice
     (Slice                   : in out Slice_Type;
      Size                    : Board_Size_Type;
      Iterate_Ascending_Index : Boolean;
      Score                   : out Score_Type)
   with Pre => Verification.Game_Ghost.All_Valid_Cells (Slice), Post => True;

end Logic.Game;
