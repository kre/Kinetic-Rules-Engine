// comment1 tests the remove comments function

   // comment offset
ruleset foo {
  global {
y = <<
   // comment in extended quote
>>;

z = "http://www.windley.com";

// comment at start of line

x = <|
// JS comment should go
         var userId = /\/users\/([0-9]*)\//.exec("/users/230948/coolio")[1];
         alert(userId);
      |>;
}
}