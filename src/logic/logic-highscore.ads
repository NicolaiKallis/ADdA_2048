pragma SPARK_Mode (Off);

with Types.Game_Types; use Types.Game_Types;

package Logic.Highscore is

   -- Default filename used to persist high scores.
   Default_Highscore_File : constant String := ".highscore";
   -- Raised when project root cannot be located for score persistence.
   Project_Root_Not_Found : exception;

   -- Load high score from file, returns 0 if file doesn't exist
   function Load_Highscore (Size : Board_Size_Type) return Score_Type
   with Post => Load_Highscore'Result in Score_Type;

   -- Save high score for the given board size.
   procedure Save_Highscore (Size : Board_Size_Type; Score : Score_Type);

   -- Update persisted high score if New_Score is greater.
   function Update_Highscore
     (New_Score : Score_Type; Size : Board_Size_Type) return Boolean;

end Logic.Highscore;
