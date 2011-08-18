// action keywords
ruleset 10 {
rule process_readings {
  select when email received
  pre {
    subject = eventaram("subject");
    textbody = eventaram(“body”);
    url = textbody.extract(re#^(http:\/\/.*)$#);
    item = << <li><a href=”#{url}”>#{subject}</a></li> >>;
  }

  {
    spreadsheet:submitsingle(item);
    email:reply() with
        message = item and
        delete = true;

  }

}

}
