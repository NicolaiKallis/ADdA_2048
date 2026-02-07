with Logic.User;

package TUI.Input is
   use Logic.User;

   --  NOTE: Implemented as a procedure rather than a function (despite an initial
   --  intuition to return a command value) because this subprogram performs input
   --  operations and has observable side effects. This follows established Ada
   --  and SPARK design guidance, which recommends that functions be free of
   --  externally visible effects, while procedures are used to model actions
   --  and interactions.
   --  Sources: Ada 2022 AARM 1.1.5 (bounded-error rationale about side-effecting functions);
   --           (https://adaic.org/resources/add_content/standards/05aarm/html/AA-1-1-5.html)
   --           SPARK Proof Manual 3.3.1 (functions have no explicit side effects)
   --           (https://docs.adacore.com/sparkdocs-docs/Proof_Manual.htm)

   procedure Get_User_Input
     (UserInput   : out Input_Command;
      Input_Char  : out Character;
      Extra_Input : out Boolean);

end TUI.Input;
