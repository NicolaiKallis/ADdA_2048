-------------------------------------------------------------------------------
--  Implementation of ghost functions for SPARK verification.
--  This code is NEVER executed at runtime - it exists only to satisfy
--  the SPARK prover's need for executable semantics during analysis.
-------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body Verification.Game_Ghost is

   function Slice_Sum (S : Slice_Type) return Natural is
      Sum : Natural := 0;
   begin
      for I in S'Range loop
         pragma
           Loop_Invariant
             (Sum
              <= Natural (I - S'First)
                 * Natural (Max_Valid_Cell_Value));
         Sum := Sum + Natural (S (I));
      end loop;
      return Sum;
   end Slice_Sum;

   function Non_Empty_Count (S : Slice_Type) return Natural is
      Count : Natural := 0;
   begin
      for I in S'Range loop
         pragma Loop_Invariant (Count <= Natural (I - S'First));
         if S (I) /= Empty_Cell then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Non_Empty_Count;

   function Is_Compacted (S : Slice_Type) return Boolean is
      Found_Empty : Boolean := False;
   begin
      for I in S'Range loop
         if S (I) = Empty_Cell then
            Found_Empty := True;
         elsif Found_Empty then
            --  Found non-empty after empty = not compacted
            return False;
         end if;
      end loop;
      return True;
   end Is_Compacted;

   function All_Valid_Cells (S : Slice_Type) return Boolean
   is (for all I in S'Range => Is_Valid_Cell_Value (S (I)));

end Verification.Game_Ghost;
