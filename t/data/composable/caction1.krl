// composable action
ruleset caction1 {
  meta {
    name "ca_module"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     a = 5;
     x = defaction (y) {
     	configure using w = "FOO" and blue = "fiddyfiddyfappap"
        farb = y + blue;
        every {
     	  noop();
     	  alert(farb);
        }
     };
  } 
}