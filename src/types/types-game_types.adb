pragma SPARK_Mode (On);

package body Types.Game_Types is

   function Is_Power_Of_Two (Value : Cell_Value) return Boolean is
      Temp     : Cell_Value := Value;
      Original : constant Cell_Value := Value;
   begin
      if Value = 0 then
         return False;
      end if;

      if Value = 1 then
         return True;   -- mathematically valid edge case

      end if;

      -- Keep dividing by 2 until we reach 1 or find an odd number
      while Temp > 1 loop

         pragma Loop_Invariant (Temp >= 1 and Temp <= Value);
         pragma Loop_Invariant (Temp <= Value);
         pragma Loop_Invariant (Value = Original);

         -- if division result is and odd number, Value is not a power of 2
         if Temp mod 2 /= 0 then
            return False;
         end if;

         Temp := Temp / 2;
      end loop;

      -- If we reached 1, Value was a power of 2
      return True;
   end Is_Power_Of_Two;

   function Is_Valid_Cell_Value (Value : Cell_Value) return Boolean is
   begin
      -- Valid cell values are either a power of 2 or the empty cell
      if Value = Empty_Cell then
         return True;
      end if;

      if Value < Min_Valid_Cell_Value then
         return False;
      end if;

      return Is_Power_Of_Two (Value);
   end Is_Valid_Cell_Value;

   function Is_Valid_Board (Board : Board_Type) return Boolean is
   begin
      for Row in Board_Index loop
         for Col in Board_Index loop
            if not Is_Valid_Cell_Value (Board (Row, Col)) then
               return False;
            end if;
         end loop;
      end loop;
      return True;
   end Is_Valid_Board;

end Types.Game_Types;
