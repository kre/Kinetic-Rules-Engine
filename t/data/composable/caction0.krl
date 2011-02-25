// composable action
ruleset a16x78 {
  meta {
    name "cs_module"
    description <<
      For testing modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     a = 5;
     x = defaction (y) {y};
  }
 
}