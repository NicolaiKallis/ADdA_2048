with Types.Game_Types;

package TUI.Menu is

   type Menu_Action is (Menu_Start_Game, Menu_Quit);

   type Menu_Selection is record
      Action     : Menu_Action;
      Board_Size : Types.Game_Types.Board_Size_Type :=
        Types.Game_Types.Default_Board_Size;
   end record;

   function Get_Menu_Selection return Menu_Selection;

end TUI.Menu;
