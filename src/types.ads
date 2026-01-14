-- Core type definitions for 2048 game

package Game_Types is

   -- Cell_Value represents the value in a single board cell
   -- TODO: Values can go higher than 2048
   type Cell_Value is new Natural range 0 .. 2048;
   Empty_Cell : constant Cell_Value := 0;
   
   -- Board dimensions
   Board_Size : constant := 4;
   type Board_Index is range 1 .. Board_Size;
   
   -- The game board: 4x4 grid of cells
   type Board_Type is array (Board_Index, Board_Index) of Cell_Value;
   
   -- Direction enumeration for move commands
   type Direction is (Up, Down, Left, Right);
   
   -- Game_State record encapsulates all game information
   type Game_State is record
      Board       : Board_Type;
      Score       : Natural := 0;
      Game_Over   : Boolean := False;
      Victory     : Boolean := False;
   end record;
   
   
end Game_Types;