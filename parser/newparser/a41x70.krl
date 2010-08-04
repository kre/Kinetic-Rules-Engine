{
   "dispatch": [
      {"domain": "www.backcountry.com"},
      {"domain": "www.rei.com"},
      {"domain": "www.walmart.com"},
      {"domain": "www.amazon.com"},
      {"domain": "www.staples.com"},
      {"domain": "store.apple.com"},
      {"domain": "bestbuy.com"},
      {"domain": "nordstrom.com"}
   ],
   "global": [
      {
         "lhs": "data",
         "rhs": {
            "type": "hashraw",
            "val": [
               {
                  "lhs": "firstname",
                  "rhs": {
                     "type": "str",
                     "val": "John"
                  }
               },
               {
                  "lhs": "lastname",
                  "rhs": {
                     "type": "str",
                     "val": "Doe"
                  }
               },
               {
                  "lhs": "cardholdername",
                  "rhs": {
                     "type": "str",
                     "val": "John Doe"
                  }
               },
               {
                  "lhs": "cardtype",
                  "rhs": {
                     "type": "str",
                     "val": "V0"
                  }
               },
               {
                  "lhs": "cc",
                  "rhs": {
                     "type": "str",
                     "val": "0000123412341234"
                  }
               },
               {
                  "lhs": "vcode",
                  "rhs": {
                     "type": "str",
                     "val": "123"
                  }
               },
               {
                  "lhs": "address",
                  "rhs": {
                     "type": "str",
                     "val": "3rd North Cherry Lane"
                  }
               },
               {
                  "lhs": "city",
                  "rhs": {
                     "type": "str",
                     "val": "New York"
                  }
               },
               {
                  "lhs": "state",
                  "rhs": {
                     "type": "str",
                     "val": "NY"
                  }
               },
               {
                  "lhs": "nordstate",
                  "rhs": {
                     "type": "str",
                     "val": "39|0"
                  }
               },
               {
                  "lhs": "country",
                  "rhs": {
                     "type": "str",
                     "val": "us"
                  }
               },
               {
                  "lhs": "nordcountry",
                  "rhs": {
                     "type": "str",
                     "val": "249"
                  }
               },
               {
                  "lhs": "zip",
                  "rhs": {
                     "type": "str",
                     "val": "123456"
                  }
               },
               {
                  "lhs": "email",
                  "rhs": {
                     "type": "str",
                     "val": "john@johndoe.com"
                  }
               },
               {
                  "lhs": "phone",
                  "rhs": {
                     "type": "str",
                     "val": "5552225555"
                  }
               },
               {
                  "lhs": "areacode",
                  "rhs": {
                     "type": "str",
                     "val": "555"
                  }
               },
               {
                  "lhs": "phonenocode",
                  "rhs": {
                     "type": "str",
                     "val": "2225555"
                  }
               },
               {
                  "lhs": "ccmonth",
                  "rhs": {
                     "type": "str",
                     "val": "10"
                  }
               },
               {
                  "lhs": "ccyear",
                  "rhs": {
                     "type": "str",
                     "val": "2011"
                  }
               },
               {
                  "lhs": "billsame",
                  "rhs": {
                     "type": "str",
                     "val": "0"
                  }
               }
            ]
         },
         "type": "expr"
      },
      {
         "lhs": "title",
         "rhs": {
            "type": "str",
            "val": "Visa RightCliq Fast Fill"
         },
         "type": "expr"
      },
      {
         "lhs": "message",
         "rhs": " \n<style>#kGrowl div {float: none;}<\/style>    <div style=\"padding: 7px; background-color: white; color: black; font-size: 18px; text-align: center;\">    <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\"/><br/>        \tDo you want to fast fill?<br/>        <input type=\"button\" value=\"Yes\" onclick=\"KOBJ.FormFill();\"/>    <input type=\"button\" value=\"No\" />    <\/div>        \n ",
         "type": "here_doc"
      },
      {"emit": "\nKOBJ.FormFill = function(button){    \t$K.each(KOBJ.formfillmap, function(key, selector){    \t\t$K(selector).val(data[key.replace(/^\\s+|\\s+$/g,\"\")]);    \t});    };                    "}
   ],
   "meta": {
      "logging": "on",
      "name": "Axciom Demo"
   },
   "rules": [
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"firstname\":\"#b_fname\",  \"lastname\":\"#b_lname\",  \"address\":\"#b_address1\",  \"city\":\"#b_city\",  \"state\":\"#b_state\",  \"zip\":\"#b_zip\",  \"email\":\"#email\",  \"phone\":\"#b_phone\",  \"cc\":\"#mv_credit_card_number\",  \"vcode\":\"#mv_credit_card_cvv2\",  \"ccmonth\":\"#mv_credit_card_exp_month\",  \"ccyear\":\"#mv_credit_card_exp_year\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bc",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www.backcountry.com/store/checkout.html",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"cardholdername \":\"#name\",  \"address\":\"#address1\",  \"city\":\"#city\",  \"state\":\"#state\",  \"zip\":\"#zip\",  \"phone\":\"#voice\",  \"cardtype\":\"#creditCardIssuer\",  \"cc\":\"#sensitiveCreditCard\",  \"cardholdername\":\"#card-name\",  \"ccmonth\":\"#newCreditCardMonth\",  \"ccyear\":\"#newCreditCardYear\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "amazoncard",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www.amazon.com/gp/css/account/cards/view.html(.)+viewID=addCard",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"firstname\":\"#bFirstName\",  \"lastname\":\"#bLastName\",  \"address\":\"#bAddress1\",  \"city\":\"#bCity\",  \"state\":\"#bState\",  \"zip\":\"#bZipCode\",  \"email\":\"#email\",  \"email \":\"#email2\",  \"phone\":\"#bPhone\",  \"firstname \":\"#firstname\",  \"lastname \":\"#lastname\",  \"address \":\"#address\",  \"city \":\"#city\",  \"state \":\"#state\",  \"zip \":\"#zip\",  \"phone \":\"#phonenumber\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "staples",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www.staples.com/office/supplies/StaplesCheckoutFlow",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"firstname\":\"#firstNameField\",  \"lastname\":\"#lastNameField\",  \"address\":\"#streetField\",  \"city\":\"#cityField\",  \"state\":\"#stateField\",  \"zip\":\"#postalCodeField\",  \"areacode\":\"#daytimePhoneAreaCodeField\",  \"phonenocode\":\"#daytimePhoneField\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "dev",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.testsite.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"firstname\":\"input[name='TxtFirstName']\",  \"lastname\":\"input[name='TxtLastName']\",  \"address\":\"input[name='TxtAddress1']\",  \"city\":\"input[name='TxtCity']\",  \"state\":\"input[name='DrpState']\",  \"zip\":\"input[name='TxtPostalCode']\",  \"country\":\"input[name='DrpCountry']\",  \"phone\":\"input[name='TxtPhone1']\",  \"email\":\"input[name='Txtemail1']\",  \"email \":\"input[name='Txtemail2']\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bestbuy",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www-ssl.bestbuy.com/site/olstemplatemapper.jsp",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"email\":\"#ctl00_mainContentPlaceHolder_emailAddress\",  \"email \":\"#ctl00_mainContentPlaceHolder_emailAddressConfirm\",  \"phone\":\"#ctl00_mainContentPlaceHolder_phoneNumber\",  \"firstname\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_firstName\",  \"lastname\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_lastName\",  \"address\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_address1\",  \"city\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_city\",  \"nordstate\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_stateProvince\",  \"zip\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_zipCode\",  \"country\":\"#ctl00_mainContentPlaceHolder_billingAddressForm_country\",  \"billsame\":\"#ctl00_mainContentPlaceHolder_shippingSameAsBilling\"        };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "nordstrom",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://secure.nordstrom.com/AddressSetup.aspx\\?origin=shoppingbag",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nKOBJ.formfillmap = {    \"firstname\":\".firstNameField\",  \"lastname\":\".lastNameField\",  \"address\":\".streetField\",  \"city\":\".cityField\",  \"state\":\".stateField\",  \"zip\":\".postalCodeField\",  \"areacode\":\".daytimePhoneAreaCodeField\",  \"phonenocode\":\".daytimePhoneField\"    };                   "},
            {"action": {
               "args": [
                  {
                     "type": "var",
                     "val": "title"
                  },
                  {
                     "type": "var",
                     "val": "message"
                  }
               ],
               "modifiers": [
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  },
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "input"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "apple",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://store.apple.com/1-800-MY-APPLE/WebObjects/AppleStore.woa/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x70"
}
