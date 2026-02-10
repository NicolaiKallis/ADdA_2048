pragma SPARK_Mode (Off);

with Ada.Text_IO;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings;

package body Logic.Highscore is

   function Get_Highscore_Path return String is
      Current_Dir : constant String := Ada.Directories.Current_Directory;
      Search_Dir  : String := Current_Dir;
   begin
      loop
         -- NOTE: These files need to be present to run an Ada program using alire
         -- so they are good candidates to retrieve the root directory in all cases
         if Ada.Directories.Exists
             (Ada.Directories.Compose (Search_Dir, "alire.toml"))
           or else Ada.Directories.Exists
             (Ada.Directories.Compose (Search_Dir, "adda_2048.gpr"))
         then
            return Ada.Directories.Compose
              (Containing_Directory => Search_Dir,
               Name                 => Default_Highscore_File);
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

      raise Project_Root_Not_Found;
   end Get_Highscore_Path;

   subtype Size_Index is Board_Size_Type;
   type Score_Table is array (Size_Index) of Score_Type;

   -- Cached high scores to avoid repeated file reads
   Cached_Scores     : Score_Table := (others => 0);
   Cache_Initialized : Boolean := False;

   function Trimmed (Value : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (Value, Ada.Strings.Both);
   end Trimmed;

   function Size_Image (Size : Board_Size_Type) return String is
   begin
      return Trimmed (Board_Size_Type'Image (Size));
   end Size_Image;

   function Score_Image (Score : Score_Type) return String is
   begin
      return Trimmed (Score_Type'Image (Score));
   end Score_Image;

   procedure Load_All_Scores (Scores : in out Score_Table) is
      File_Path : constant String := Get_Highscore_Path;
      File      : Ada.Text_IO.File_Type;
      Line      : String (1 .. 200);
      Last      : Natural;
   begin
      Scores := (others => 0);

      if not Ada.Directories.Exists (File_Path) then
         return;
      end if;

      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Path);
      while not Ada.Text_IO.End_Of_File (File) loop
         Ada.Text_IO.Get_Line (File, Line, Last);
         if Last = 0 then
            goto Continue;
         end if;

         declare
            Raw       : constant String := Line (1 .. Last);
            Cleaned   : constant String := Trimmed (Raw);
            Delim_Pos : Natural := 0;
         begin
            if Cleaned'Length = 0 then
               goto Continue;
            end if;

            for I in Cleaned'Range loop
               if Cleaned (I) = ' '
                 or else Cleaned (I) = ':'
                 or else Cleaned (I) = '='
               then
                  Delim_Pos := I;
                  exit;
               end if;
            end loop;

            if Delim_Pos = 0 then
               -- Backward compatible: single score defaults to 4x4.
               begin
                  Scores (Default_Board_Size) := Score_Type'Value (Cleaned);
               exception
                  when others =>
                     null;
               end;
            else
               declare
                  Size_Str  : constant String :=
                    Trimmed (Cleaned (Cleaned'First .. Delim_Pos - 1));
                  Score_Str : constant String :=
                    Trimmed (Cleaned (Delim_Pos + 1 .. Cleaned'Last));
                  Size_Val  : Board_Size_Type;
                  Score_Val : Score_Type;
               begin
                  Size_Val := Board_Size_Type'Value (Size_Str);
                  Score_Val := Score_Type'Value (Score_Str);
                  Scores (Size_Val) := Score_Val;
               exception
                  when others =>
                     null;
               end;
            end if;
         end;

         <<Continue>>
         null;
      end loop;
      Ada.Text_IO.Close (File);
   exception
      when Project_Root_Not_Found =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
         raise;

      when others =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
   end Load_All_Scores;

   procedure Save_All_Scores (Scores : Score_Table) is
      File_Path : constant String := Get_Highscore_Path;
      File      : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, File_Path);
      for Size in Size_Index loop
         Ada.Text_IO.Put_Line
           (File,
            Size_Image (Size)
            & "x"
            & Size_Image (Size)
            & ":"
            & " "
            & Score_Image (Scores (Size)));
      end loop;
      Ada.Text_IO.Close (File);
   exception
      when Project_Root_Not_Found =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
         raise;

      when others =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
   end Save_All_Scores;

   procedure Ensure_Cache is
   begin
      if not Cache_Initialized then
         Load_All_Scores (Cached_Scores);
         Cache_Initialized := True;
      end if;
   end Ensure_Cache;

   function Load_Highscore (Size : Board_Size_Type) return Score_Type is
   begin
      Ensure_Cache;
      return Cached_Scores (Size);
   end Load_Highscore;

   procedure Save_Highscore (Size : Board_Size_Type; Score : Score_Type) is
   begin
      Ensure_Cache;
      Cached_Scores (Size) := Score;
      Save_All_Scores (Cached_Scores);
   end Save_Highscore;

   function Update_Highscore
     (New_Score : Score_Type; Size : Board_Size_Type) return Boolean is
   begin
      Ensure_Cache;
      if New_Score > Cached_Scores (Size) then
         Cached_Scores (Size) := New_Score;
         Save_All_Scores (Cached_Scores);
         return True;
      end if;

      return False;
   end Update_Highscore;

end Logic.Highscore;
