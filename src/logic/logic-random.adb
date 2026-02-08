pragma SPARK_Mode (Off);

with Ada.Numerics.Discrete_Random;

package body Logic.Random is

   -- Values taken based on the offical implementation of the 2048 game
   -- source: https://github.com/gabrielecirulli/2048/blob/master/js/game_manager.js#L71
   Chance_Of_Two  : constant Natural := 90;
   Chance_Of_Four : constant Natural := 10;

   -- For both following subtytes first we define the range of possible values
   -- then we create a customized version of the random library specifically for that range
   subtype Cell_Position_Range is
     Natural range 1 .. Max_Board_Size * Max_Board_Size;
   package Random_Position_Gen is new
     Ada.Numerics.Discrete_Random (Cell_Position_Range);
   Random_Pos_Gen : Random_Position_Gen.Generator;

   subtype Percentage_Range is Natural range 0 .. 100;
   package Percentage_Generator is new
     Ada.Numerics.Discrete_Random (Percentage_Range);
   Percentage_Gen : Percentage_Generator.Generator;

   function Generate_Random_Cell_Value return Cell_Value is
      P : constant Percentage_Range := Percentage_Gen.Random;
   begin
      if P < Chance_Of_Two then
         return 2;
      else
         return 4;
      end if;
   end Generate_Random_Cell_Value;

   function Random_Index (N : Positive) return Positive is
      P : constant Cell_Position_Range := Random_Pos_Gen.Random;
   begin
      -- Ada.Numerics.Discrete_Random is instantiated with a fixed type (i.e 1..16).
      -- The output range is fixed at compile time -> Mapping fixed range into the
      -- current range defined by (1..N).
      return 1 + (Natural (P - 1) mod N);
   end Random_Index;

   -- Reset generators at the beginning of the program
begin
   Percentage_Generator.Reset (Percentage_Gen);
   Random_Position_Gen.Reset (Random_Pos_Gen);
end Logic.Random;
