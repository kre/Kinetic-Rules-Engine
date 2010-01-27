// Rule to test replace_html
ruleset 10 {
  rule inline_html is active {
    select using "/identity-policy/" setting ()

    pre {

      city = geoip:city();

      city_announcement = << 
<div id="kynetx_foo">
<p class="announcement">This is some text!!! It's cool.  
You are in #{city}!</p>
</div> 
      >>;

      second_thing = <<
<div id="second">
<p class="announcement">This is the second div If you want to say something is much 
greater, use &gt;&gt;</p>
</div>
      >>;

    }

    replace_html("kobj_test", (city_announcement + second_thing));

  }
}

// this comment should get removed. parsing errors might leave it
