pragma SPARK_Mode (Off);

with Types.Game_Types; use Types.Game_Types;

package Logic.Highscore is

   Default_Highscore_File : constant String := ".highscore";

   -- Load high score from file, returns 0 if file doesn't exist
   function Load_Highscore return Score_Type
   with Post => Load_Highscore'Result in Score_Type;

   procedure Save_Highscore (Score : Score_Type);

   function Update_Highscore (New_Score : Score_Type) return Boolean;

end Logic.Highscore;
