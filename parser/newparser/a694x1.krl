{
   "dispatch": [{"domain": "refresheverything.com"}],
   "global": [],
   "meta": {
      "description": "\nPepsi Refresh Login     \n",
      "logging": "on",
      "name": "pepsi light"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Password"
               },
               {
                  "type": "var",
                  "val": "frmPwd"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif ($K(\"#user-login\")) {      $K(\"input#emailAddress\").val(frmEmail);      $K(\"input#password\").val(frmPwd);      $K(\"input#httpReferer\").val(\"\");      $K(\"#user-login\").find(\"input[type='submit']\").trigger(\"click\");    }                ",
         "foreach": [],
         "name": "form_login",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/index/login.*(?:&email|\\?email)=([^&]*).*(?:&password|\\?password)=([^&]*)",
            "type": "prim_event",
            "vars": [
               "email",
               "password"
            ]
         }},
         "pre": [
            {
               "lhs": "frmEmail",
               "rhs": {
                  "type": "var",
                  "val": "email"
               },
               "type": "expr"
            },
            {
               "lhs": "frmPwd",
               "rhs": {
                  "type": "var",
                  "val": "password"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Going to"
               },
               {
                  "type": "str",
                  "val": "Dashboard"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif ($K(\"#profile-pcna\").text()==\"Your Profile\") {          window.location=\"/dashboard\";    };            ",
         "foreach": [],
         "name": "go_dashboard",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/index/login.*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Password"
               },
               {
                  "type": "var",
                  "val": "frmPwd"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif ($K(\"#register\")) {      $K(\"input#firstName\").val(frmFname );      $K(\"input#lastName\").val(frmLname );      $K(\"input#emailAddress\").val(frmEmail);      $K(\"input#password\").val(frmPwd);      $K(\"input#passwordCheck\").val(frmPwd);      $K(\"#dobMonth\").val(frmDOBMonth);      $K(\"#dobDay\").append('<option value=\"'+ frmDOBDay + '\" selected=\"selected\">' + frmDOBDay + '<\/option>');      $K(\"#dobYear\").val(frmDOBYear);      $K(\"input#httpReferer\").val(\"\");      $K(\"input#captchaText\").focus();    }                ",
         "foreach": [],
         "name": "light_registration",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/light-registration.*(?:&fname|\\?fname)=([^&]*).*(?:&lname|\\?lname)=([^&]*).*(?:&email|\\?email)=([^&]*).*(?:&password|\\?password)=([^&]*).*(?:&dobMonth|\\?dobMonth)=([^&]*).*(?:&dobDay|\\?dobDay)=([^&]*).*(?:&dobYear|\\?dobYear)=([^&]*)",
            "type": "prim_event",
            "vars": [
               "fname",
               "lname",
               "email",
               "password",
               "dobMonth",
               "dobDay",
               "dobYear"
            ]
         }},
         "pre": [
            {
               "lhs": "frmFname",
               "rhs": {
                  "type": "var",
                  "val": "fname"
               },
               "type": "expr"
            },
            {
               "lhs": "frmLname",
               "rhs": {
                  "type": "var",
                  "val": "lname"
               },
               "type": "expr"
            },
            {
               "lhs": "frmEmail",
               "rhs": {
                  "type": "var",
                  "val": "email"
               },
               "type": "expr"
            },
            {
               "lhs": "frmPwd",
               "rhs": {
                  "type": "var",
                  "val": "password"
               },
               "type": "expr"
            },
            {
               "lhs": "frmDOBMonth",
               "rhs": {
                  "type": "var",
                  "val": "dobMonth"
               },
               "type": "expr"
            },
            {
               "lhs": "frmDOBDay",
               "rhs": {
                  "type": "var",
                  "val": "dobDay"
               },
               "type": "expr"
            },
            {
               "lhs": "frmDOBYear",
               "rhs": {
                  "type": "var",
                  "val": "dobYear"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "dashboard",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      }
   ],
   "ruleset_name": "a694x1"
}
