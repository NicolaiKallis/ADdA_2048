with Ada.Text_IO;
with Ada.Directories;
with Ada.Environment_Variables;

package body Logic.Highscore is

   function Get_Highscore_Path return String is
      Current_Dir : String := Ada.Directories.Current_Directory;
      Search_Dir  : String := Current_Dir;
   begin
      loop
         -- TODO: Fix this ; instead of searching for .gitignore it should search
         -- more broadly for the level of hierarchy
         if Ada.Directories.Exists (Search_Dir & "/.gitignore") then
            return Search_Dir & "/" & Default_Highscore_File;
         end if;

         -- Try parent directory
         declare
            Parent : constant String :=
              Ada.Directories.Containing_Directory (Search_Dir);
         begin
            exit when Parent = Search_Dir or Parent = "";
            Search_Dir := Parent;
         end;
      end loop;

      -- Fallback
      return Current_Dir & "/" & Default_Highscore_File;
   end Get_Highscore_Path;

   function Load_Highscore return Score_Type is
      File_Path : constant String := Get_Highscore_Path;
      File      : Ada.Text_IO.File_Type;
      Score_Str : String (1 .. 20);
      Last      : Natural;
      Score     : Score_Type := 0;
   begin
      if not Ada.Directories.Exists (File_Path) then
         return 0;
      end if;

      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Path);
      if not Ada.Text_IO.End_Of_File (File) then
         Ada.Text_IO.Get_Line (File, Score_Str, Last);
         if Last > 0 then
            Score := Score_Type'Value (Score_Str (1 .. Last));
         end if;
      end if;
      Ada.Text_IO.Close (File);

      return Score;
   exception
      when others =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
         return 0;
   end Load_Highscore;

   procedure Save_Highscore (Score : Score_Type) is
      File_Path : constant String := Get_Highscore_Path;
      File      : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Path);
      Ada.Text_IO.Put_Line (File, Score_Type'Image (Score));
      Ada.Text_IO.Close (File);
   exception
      when others =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
   end Save_Highscore;

   -- Cached high score to avoid repeated file reads
   Cached_Highscore  : Score_Type := 0;
   Cache_Initialized : Boolean := False;

   function Update_Highscore (New_Score : Score_Type) return Boolean is
   begin
      if not Cache_Initialized then
         Cached_Highscore := Load_Highscore;
         Cache_Initialized := True;
      end if;

      if New_Score > Cached_Highscore then
         Cached_Highscore := New_Score;
         Save_Highscore (New_Score);
         return True;
      end if;

      return False;
   end Update_Highscore;

end Logic.Highscore;
