with Types.Game_Types; use Types.Game_Types;

package Logic.Random is

   function Generate_Random_Cell_Value return Cell_Value
   with Post => Generate_Random_Cell_Value'Result in 2 | 4;

   function Random_Index (N : Positive) return Positive
   with Post => Random_Index'Result in 1 .. N;

end Logic.Random;
