// Rule to test here_doc
ruleset 10 {

 rule here_doc0 is active {
    select using "/identity-policy/" setting ()

    pre {


      city_announcement = << 
<div id="kynetx_foo">
<p class="announcement">This is some text!!! It's cool.  
You are in #{city}! 
</p>
</div> 
      >>;

      second_thing = <<
<div id="second">
<p>This is the second div If you want to say something is much
greater, use &gt;&gt;</p>
What about <a href="http://www.windley.com">URLs in double quotes</a>?  
</div>
      >>;

      third_thing = <<
K("#searchbutton " + index).html("<img src='https://kynetx-apps.s3.amaz ...' />"); 
>>;

    } 

   //comments in strings shouldn't be deleted
    replace("kobj_test", (city_announcement + (second_thing +    
            "Can we put //comments inside a string?")))
     with remote = "http://www.foo.com";

  }

}
