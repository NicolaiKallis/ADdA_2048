with Ada.Numerics.Discrete_Random;

package body Logic.Random is

   -- Values taken based on the offical implementation of the 2048 game
   -- source: https://github.com/gabrielecirulli/2048/blob/master/js/game_manager.js#L71
   Chance_Of_Two  : constant Natural := 90;
   Chance_Of_Four : constant Natural := 10;

   -- For both following subtytes first we define the range of possible values
   -- then we create a customized version of the random library specifically for that range
   subtype Cell_Position_Range is Natural range 1 .. Board_Size * Board_Size;
   package Random_Position_Gen is new
     Ada.Numerics.Discrete_Random (Cell_Position_Range);
   Random_Pos_Gen : Random_Position_Gen.Generator;

   subtype Percentage_Range is Natural range 0 .. 100;
   package Percentage_Generator is new
     Ada.Numerics.Discrete_Random (Percentage_Range);

   Percentage_Gen : Percentage_Generator.Generator;

   function Generate_Random_Cell_Value return Cell_Value is
   begin
      return 2 or 4;
   end Generate_Random_Cell_Value;

end Logic.Random;
