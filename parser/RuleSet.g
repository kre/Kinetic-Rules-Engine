grammar RuleSet;

//
// This file is part of the Kinetic Rules Engine (KRE)
// Copyright (C) 2007-2011 Kynetx, Inc. 
//
// KRE is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 2 of
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this program; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
// MA 02111-1307 USA
//

options {
  output=AST;
  backtrack=true;
//  memoize=true;
//  language=C;
//  ASTLabelType=pANTLR3_BASE_TREE;

}


// Handle Escaping in string http://stackoverflow.com/questions/504402/how-to-handle-escape-sequences-in-string-literals-in-antlr-3


@header {
	package com.kynetx;
	import java.util.HashMap;
	import java.util.ArrayList;
//	import org.json.*;
}
@lexer::header {
	package com.kynetx;

}

@lexer::members {
	public boolean canbeReg = true;
}


@members {
	public boolean check_operator = false;
	public HashMap rule_json = new HashMap();
	public ArrayList parse_errors = new ArrayList();
	public HashMap current_top = null;

	public boolean checkname = true;


	public void emitErrorMessage(String msg) {
		parse_errors.add(msg);
	}


	public class InvalidToken extends RecognitionException
	{
		String aMessage = "";
		public InvalidToken(String inMessage, org.antlr.runtime.IntStream intstream)
		{
			super(intstream);
			aMessage = inMessage;
		}

		public String getMessage()
		{
			return aMessage;
		}

	}

	public String fix_time(String value)
	{
	    if(value.equals("year") ||
	        value.equals("month") ||
	        value.equals("week") ||
	        value.equals("day") ||
	        value.equals("hour") ||
	        value.equals("minute") ||
	        value.equals("second"))
	      {
	        return value + "s";
	      }
	      return value;
	}

	public String strip_string(String value)
	{
		return value.substring(1,value.length() - 1);
	}

	public boolean isIn(String value,String[] other_values)
	{
		for(int i=0;i<other_values.length;i++)
		{
			if(value.equals(other_values[i]))
				return true;
		}
		return false;
	}
	public String should_have_been(String value,String[] values)
	{
		if(values.length == 0)
		{
			return "Invalid value [" + value + "] found should have been " + values[0];
		}
		else
		{
			String result = "Invalid value [" + value + "] found should have been one of [";
			for(int i=0;i<values.length;i++)
			{
				result = result + values[i];
				if(i < values.length - 1)
				{
					result = result + ", ";
				}
			}
			result = result + "]";
			return result;
		}

	}

	public void cn(String value,String[] values, org.antlr.runtime.IntStream input)  throws InvalidToken
	{
		for(int i=0;i<values.length;i++)
		{
			if(value.equals(values[i]))
				return;
		}
		throw new InvalidToken(should_have_been(value,values), input);
	}
	/*
	 * Strip Crap off that we do not want any more.
	 */
	public String strip_wrappers(String start, String end, String value)
	{
		return value.substring(start.length(),value.length() - end.length());
	}

	public String[] sar(String ... values)
	{
		return values;
	}
	public void store_in_hash(HashMap start_hash,String subhash,String key, Object value)
	{
		HashMap themap = (HashMap)start_hash.get(subhash);
		if(themap == null)
		{
			themap = new HashMap();
			start_hash.put(subhash,themap);
		}
		themap.put(key,value);
	}

	public void  add_to_expression(ArrayList result,String type,String op, Object oresult)
	{
		HashMap tmp = new HashMap();
		tmp.put("op",op);
		tmp.put("type",type);
		tmp.put("result",oresult);
		result.add(tmp);
	}
	public void puts(String str)
	{
		System.out.println(str);
	}

	public HashMap build_exp_result(ArrayList operators)
	{
//		puts("Start " + operators.size() ) ;
		HashMap result = new HashMap();
		ArrayList args_array = new ArrayList();
		result.put("args",args_array);
		for(int i = 0;i < operators.size(); i++)
		{
//			puts("at " + i);
			HashMap value = (HashMap)operators.get(i);

			 // Are we at the end?
			if(i == operators.size() - 1 ||  i == 0)
			{
				if(i == 0)
				{
//					puts("O Opt " + value.get("op") + " - " + i);
					result.put("op",value.get("op"));
					result.put("type",value.get("type"));
				}

				args_array.add(value.get("result"));
			}
			else
			{
				HashMap tmp = new HashMap();
				ArrayList new_args_array = new ArrayList();
				// We really need the next operator for the ast
				HashMap value2 = (HashMap)operators.get(i+1);

				tmp.put("op",value2.get("op"));
				tmp.put("type",value2.get("type"));
				tmp.put("args",new_args_array);

				new_args_array.add(value.get("result"));

				args_array.add(tmp);
				args_array = new_args_array;
			}
		}
//		puts("End " ) ;
		return result;
	}
/*
	    public HashMap build_exp_result(ArrayList operators)
    	{
    //		puts("Start " + operators.size() ) ;
    		HashMap result = new HashMap();
    		ArrayList args_array = new ArrayList();
    		result.put("args",args_array);
    		for(int i = 0;i < operators.size(); i++)
    		{
    //			puts("at " + i);
    			HashMap value = (HashMap)operators.get(i);

    			 // Are we at the end?
    			if(i == operators.size() - 1 ||  i == 0)
    			{
    				if(i == 0)
    				{
    //					puts("O Opt " + value.get("op") + " - " + i);
    					result.put("op",value.get("op"));
    					result.put("type",value.get("type"));
    				}

    				args_array.add(value.get("result"));
    			}
    			else
    			{
    				HashMap tmp = new HashMap();
    				ArrayList new_args_array = new ArrayList();
    				// We really need the next operator for the ast
    				HashMap value2 = (HashMap)operators.get(i+1);

    				tmp.put("op",value2.get("op"));
    				tmp.put("type",value2.get("type"));
    				tmp.put("args",new_args_array);

    				new_args_array.add(value.get("result"));

    				args_array.add(tmp);
    				args_array = new_args_array;
    			}
    		}
    //		puts("End " ) ;
    		return result;
    	}
*/
}




ruleset  options {backtrack=false;}
@init {
 	 rule_json.put("global",new ArrayList());
 	 rule_json.put("dispatch",new ArrayList());
 	 rule_json.put("rules",new ArrayList());
 	 rule_json.put("meta", new HashMap());
	 current_top = rule_json;
}
@after  {
	current_top = null;
}
 	:
 	RULE_SET rulesetname { current_top.put("ruleset_name",$rulesetname.text); }
 	LEFT_CURL
 		meta_block?  dispatch_block? global_block? rule*
	RIGHT_CURL
	EOF
 	;

must_be[String what]
 	:
 	v=VAR { cn($v.text, sar($what),input); }
 	;

must_be_one[String[\] what]
 	:
 	v=VAR { cn($v.text,what,input); }
 	;

 rulesetname
	: VAR|INT
	;
/*

 rule <name> is <active|inactive|test> {

 }

*/
 rule_name
	:
	VAR|INT|OTHER_OPERATORS|LIKE|REPLACE|MATCH
	;

rule
@init{
	 ArrayList rule_block_array = (ArrayList)rule_json.get("rules");
           if(rule_block_array == null)
          	 {
          	    rule_block_array = new ArrayList();
          	    rule_json.put("rules",rule_block_array);
          	 }
	 HashMap current_rule = new HashMap();
	 HashMap actions_result = new HashMap();
	 ArrayList fors = new ArrayList();
}
 	: 	must_be["rule"]
		name=rule_name
        (must_be["is"] ait=must_be_one[sar("active","inactive","test")])?
		LEFT_CURL
 		  select=VAR { cn($select.text, sar("select"),input); } (ptu=using|ptw=when) (f=foreach{ fors.add($f.result);})*
 		  pb=pre_block? SEMI? eb=emit_block? SEMI? (action[actions_result] SEMI?)* cb=callbacks? SEMI? postb=post_block? SEMI?
		RIGHT_CURL {
			HashMap tmp = new HashMap();
			HashMap cond = new HashMap();
			cond.put("val","true");
			cond.put("type","bool");

			if(actions_result.get("cond") != null)
		 	{
				current_rule.put("cond",actions_result.get("cond"));
			}
		 	else
			{
				HashMap condt = new HashMap();
				condt.put("val","true");
				condt.put("type","bool");
				current_rule.put("cond",condt);
			}
			current_rule.put("blocktype",(actions_result.get("blocktype") != null ? actions_result.get("blocktype") : "every"));
            if(actions_result.get("choice") != null) current_rule.put("choice",actions_result.get("choice") );

			current_rule.put("actions",actions_result.get("actions"));
//			if($postb.text != null)
				current_rule.put("post",$postb.result);

			if($pb.text != null)
				current_rule.put("pre",$pb.result);
			else
			    current_rule.put("pre",new ArrayList());

			current_rule.put("name",$name.text);
			current_rule.put("emit",$eb.emit_value);
			current_rule.put("state",$ait.text);
			current_rule.put("callbacks",$cb.result);

			if($ptu.text != null)
			{
			    $ptu.result.put( "foreach",fors);
				current_rule.put("pagetype",$ptu.result);
				}
			else
			{
			    $ptw.result.put("foreach",fors);
				current_rule.put("pagetype",$ptw.result);
			}


            for(int i = 0;i< rule_block_array.size();i++)
            {
                if(((HashMap)rule_block_array.get(i)).get("name").equals($name.text))
                {
			                throw new InvalidToken("Rule names must be unique [" + $name.text + "]", input);
                }
            }
			rule_block_array.add(current_rule);

		}
;


post_block returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
	typ=must_be_one[sar("fired","always","notfired")] LEFT_CURL
		p1=post_statement { temp_list.add($p1.result);} (SEMI p2=post_statement { temp_list.add($p2.result);} )*  SEMI? RIGHT_CURL
		alt=post_alternate? {
		HashMap tmp = new HashMap();
//		tmp.put("alt",$alt.result);
		tmp.put("type",$typ.text);
		tmp.put("cons",temp_list);
//		if($alt.text != null)
		{
			tmp.put("alt",$alt.result);
		}
		$result = tmp;
	}
	;


post_alternate returns[ArrayList result]
@init {
	ArrayList temp_array = new ArrayList();
}
	:
		must_be["else"] LEFT_CURL (p=post_statement {temp_array.add($p.result);} (SEMI p1=post_statement{temp_array.add($p1.result);})* )? SEMI? RIGHT_CURL {
		$result = temp_array;
	};

post_statement returns[HashMap result]
@init {
	HashMap tmp_gc = new HashMap();
}
	: (( pe=persistent_expr
	   | x=xdi_expr
   	 | rs=raise_statement
	   | l=log_statement
	   | sch=schedule_statement
	   | las=must_be["last"]) (gc=guard_clause {  tmp_gc = $gc.result;  } )?)
    {
//	(IF ie=expr)?) {
		if($pe.text != null)
		 	$result = $pe.result ;

		if($l.text != null)
		 	$result = $l.result ;

		if($rs.text != null)
		 	$result = $rs.result ;
		
		if($sch.text != null)
		  $result = $sch.result;
		 	
		if($x.text != null)
		  $result = $x.result;

		if($las.text != null)
		{
			HashMap tmp = new HashMap();
			tmp.put("statement","last");
			tmp.put("type","control");
		 	$result = tmp;
		}

        if($gc.text != null) {
            $result.put("test", tmp_gc);
        } else {
            $result.put("test",null);       
        }

	}

  	;


guard_clause returns[HashMap result]
    : (  IF ie=expr
      |  (ON fin=VAR)
      ) {

         // if($result == null)
         //     $result = new HashMap();
       
		 HashMap tmp = new HashMap();
		 if($ie.text != null) {
			tmp.put("type","if");
		 	tmp.put("expr", $ie.result);
		 } else if ($fin.text != null) {
			tmp.put("type","on");
			tmp.put("value",$fin.text);
         } else {
		 	tmp = null;
		 }
         $result = tmp;

//        $result = "foobar";
    }
    ;

raise_statement returns[HashMap result]
	:
	//must_be["raise"] ('http'|'explicit'|'notification') must_be["event"]  evt=expr f=for_clause? m=modifier_clause? {
	 rd=RAISE  dom=VAR must_be["event"]  evt=expr f=for_clause? (m=modifier_clause| must_be["attributes"] attrs=expr)? {
		HashMap tmp = new HashMap();
		tmp.put("event",$evt.result);
		tmp.put("domain", $dom.text);
		tmp.put("type","raise");
        tmp.put("ruleset",$f.result);
        tmp.put("modifiers",$m.result);
        tmp.put("attributes",$attrs.result);

		$result = tmp;
	}
	;
	
schedule_statement returns[HashMap result]
  :
   rd=SCHEDULE  dom=VAR must_be["event"]  evt=expr sched=schedule_clause? (m=modifier_clause| must_be["attributes"] attrs=expr)? s=setting? {
    HashMap tmp = new HashMap();
    tmp.put("event",$evt.result);
    tmp.put("domain", $dom.text);
    tmp.put("type","schedule");
    tmp.put("timespec",$sched.result);
    tmp.put("modifiers",$m.result);
    tmp.put("attributes",$attrs.result);
    tmp.put("setting",$s.result);

    $result = tmp;
  }
  ;
  

log_statement returns[HashMap result]
	:
    typ = must_be_one[sar("log","error")] 
           (lev = must_be_one[sar("error", "warn", "info", "debug")] e=expr |
            e = expr)
    {

		HashMap tmp = new HashMap();
		tmp.put("type",$typ.text);
        tmp.put("level", $lev.text);
		tmp.put("what",$e.result);
		$result = tmp;
	}
	;

callbacks returns[HashMap result]
	:
	CALLBACKS LEFT_CURL s=success? f=failure? RIGHT_CURL {
		HashMap tmp = new HashMap();
//		if($s.text != null)
		{
			tmp.put("success",$s.result);

		}
//		if($f.text != null)
		{
			tmp.put("failure",$f.result);
		}
		$result = tmp;
	}
	;
	
success returns[ArrayList result]
@init {
	ArrayList tmp_list = new ArrayList();
}
	: SUCCESS LEFT_CURL c=click {tmp_list.add($c.result);}  (SEMI c1=click {tmp_list.add($c1.result);} )* SEMI?  RIGHT_CURL {
		$result = tmp_list;
	}
	;


failure  returns[ArrayList result]
@init {
	ArrayList tmp_list = new ArrayList();
}
	:
	FAILURE LEFT_CURL c=click {tmp_list.add($c.result);}  (SEMI c1=click  {tmp_list.add($c1.result);})*  SEMI?  RIGHT_CURL{
		$result = tmp_list;
	}
	;

click returns[HashMap result]	:
	corc=must_be_one[sar("click","change")] attr=VAR EQUAL val=STRING cl=click_link? {
		HashMap tmp = new HashMap();
		tmp.put("type",$corc.text);
		tmp.put("value",strip_string($val.text));
		tmp.put("attribute",$attr.text);
		tmp.put("trigger",$cl.result);
		$result = tmp;
	}
	;

click_link returns[HashMap result]
	:
	must_be["triggers"] p=persistent_expr  {
		$result = $p.result;
	}
	;

xdi_expr returns[HashMap result]
  :
  xr=xdi_raw {
    $result = $xr.result;
  }
  
  
  ;
  
xdi_raw returns[HashMap result]
  :
  x=XDI {
    HashMap tmp = new HashMap();
      tmp.put("action","xdi_message");
      tmp.put("name","message");
      tmp.put("domain","xdi");
      tmp.put("type","xdi-persistent");
      tmp.put("value",strip_wrappers("<[","]>",$x.text));          
			$result = tmp;
  }
  ;
  

persistent_expr returns[HashMap result]
	:
	//pse=persistent_set_element {
	//	$result = $pse.result;
	//}
	//| 
	pc=persistent_clear  {
		$result = $pc.result;
	}
	| ps=persistent_set {
		$result = $ps.result;
	}
	| pi=persistent_iterate  {
		$result = $pi.result;
	}
   	| tf=trail_forget  {
		$result = $tf.result;
	}
   	| tm=trail_mark  {
		$result = $tm.result;
	}
   	;


persistent_clear returns[HashMap result] 
	:
	CLEAR  dm=VAR_DOMAIN COLON name=VAR LEFT_CURL (hk=expr)? RIGHT_CURL{
		HashMap tmp = new HashMap();
		tmp.put("action","clear_hash_element");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
		tmp.put("hash_element",$hk.result);
		$result = tmp;
	}
	| CLEAR  dm=VAR_DOMAIN COLON name=VAR LEFT_BRACKET (idx=expr)? RIGHT_BRACKET {
		HashMap tmp = new HashMap();
		tmp.put("action","clear_array_element");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
		tmp.put("array_index",$idx.result);
		$result = tmp;
	}	
	| CLEAR  dm=VAR_DOMAIN COLON name=VAR {
		HashMap tmp = new HashMap();
		tmp.put("action","clear");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
		$result = tmp;
	}


	;

persistent_set returns[HashMap result] 
    :
    SET dm=VAR_DOMAIN COLON name=VAR LEFT_CURL (hk=expr)? RIGHT_CURL  vh=expr {
    	HashMap tmp = new HashMap();
    	tmp.put("action","set_hash");
        tmp.put("name",$name.text);
        tmp.put("domain",$dm.text);
        tmp.put("value",$vh.result);
        tmp.put("type","persistent");
        tmp.put("hash_element",$hk.result);
        $result = tmp;
    }
    | SET dm=VAR_DOMAIN COLON name=VAR LEFT_BRACKET (idx=expr)? RIGHT_BRACKET va=expr {
    	HashMap tmp = new HashMap();
    	tmp.put("action","set_array");
        tmp.put("name",$name.text);
        tmp.put("domain",$dm.text);
        tmp.put("value",$va.result);
        tmp.put("type","persistent");
        tmp.put("array_index",$idx.result);
        $result = tmp;
    	
    }
    | SET dm=VAR_DOMAIN COLON name=VAR v=set_to? {
        HashMap tmp = new HashMap();
        tmp.put("action","set");
        tmp.put("name",$name.text);
        tmp.put("domain",$dm.text);
        tmp.put("value",$v.result);
        tmp.put("type","persistent");
        $result = tmp;

    }     
    ;

persistent_iterate returns[HashMap result]
	:
	dm=VAR_DOMAIN COLON name=VAR op=COUNTER_OP v=expr from=counter_start {
		HashMap tmp = new HashMap();
		tmp.put("action","iterator");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
		tmp.put("op",$op.text);
		tmp.put("from",$from.result);
		tmp.put("value",$v.result);
		$result = tmp;
	}
	;
trail_forget returns[HashMap result]
	:
	FORGET  what=STRING must_be["in"]  dm=VAR_DOMAIN COLON name=VAR  {
		HashMap tmp = new HashMap();
		tmp.put("action","forget");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
		tmp.put("regexp",strip_string($what.text));
		$result = tmp;

	}
	;

trail_mark returns[HashMap result]
	:
	MARK dm=VAR_DOMAIN COLON name=VAR t=trail_with? {
		HashMap tmp = new HashMap();
		tmp.put("action","mark");
		tmp.put("name",$name.text);
		tmp.put("domain",$dm.text);
		tmp.put("type","persistent");
//		if($t.text != null)
			tmp.put("with",$t.result);
		$result = tmp;
	}
	;

trail_with returns[Object result]
	:
	WITH e=expr {
		$result = $e.result;
	}
	;

set_to returns[Object result]
    :
    e=expr {
    	$result = $e.result;
    }
    ;

counter_start returns[Object result]
	:
	must_be["from"] e=expr {
	 $result=e.result;
	}
	;


for_clause returns[Object result]
	:
    FOR v=expr
	{
		$result = $v.result;
	}
	;
	
schedule_clause returns[HashMap result]
  
  :
    AT_AT (ex=expr | str=STRING) {
	    HashMap tmp = new HashMap();    
	    if ($str.text != null)
	      tmp.put("once",strip_string($str.text));
	    else
	      tmp.put("once",$ex.result);
	    $result = tmp; }
	    
   | must_be["repeat"] (ex=expr | str=STRING) {
	    HashMap tmp = new HashMap();    
	    if ($str.text != null)
	      tmp.put("repeat",strip_string($str.text));
	    else
	      tmp.put("repeat",$ex.result);
	    $result = tmp; } 
  ;

  
ridversion returns[String result]
    : DOT rv=VAR
    {
        $result = $rv.text;
    }
    ;









action[HashMap result]
@init {
	$result.put("blocktype","every");
	HashMap condt = new HashMap();
	condt.put("val","true");
	condt.put("type","bool");
	$result.put("cond",condt);
	$result.put("actions",new ArrayList());
}
	:
	(conditional_action[result] | unconditional_action[result]) SEMI?
	;

conditional_action[HashMap result]
	: IF e=expr must_be["then"] unconditional_action[result]	 {
		if($e.text == null)
		{
			HashMap tmp = new HashMap();
			tmp.put("type","bool");
			tmp.put("val","true");
			result.put("cond",tmp);
		}
		else
		{
			result.put("cond",$e.result);
		}
	}
	;

unconditional_action[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	: p=primrule {temp_list.add($p.result); result.put("actions",temp_list);}
	  | action_block[result]
	;
action_block[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	: (at=EVERY|(bt=CHOOSE (choicevar=expr)? ))? {
                         if($at.text != null) result.put("blocktype",$at.text);
                         if($bt.text != null) result.put("blocktype",$bt.text);
                         if($choicevar.result != null) result.put("choice",$choicevar.result);
        }
		'{' (p=primrule {temp_list.add($p.result);}
			(';' p=primrule{temp_list.add($p.result);})* ) ';'? '}' {
		result.put("actions",temp_list);
	}
	;

primrule returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:  (label=VAR ARROW_RIGHT)? (
		 src=namespace?  name=(VAR|REPLACE|MATCH|EXTRACT|OTHER_OPERATORS|SUCCESS|FAILURE) LEFT_PAREN (ex=expr{temp_list.add($ex.result);}  (COMMA ex1=expr{temp_list.add($ex1.result);})* )? COMMA?  RIGHT_PAREN  set=setting? m=modifier_clause? {

		 	HashMap tmp = new HashMap();
		 	tmp.put("source",$src.result);
		 	tmp.put("name",$name.text);
		 	tmp.put("args",temp_list);



//            if($set.text != null)
				tmp.put("vars",$set.result);

		 	tmp.put("modifiers",$m.result);
		 	HashMap tmp2 = new HashMap();
			tmp2.put("action",tmp);

//			if($label.text != null)
			tmp2.put("label",$label.text);
			$result = tmp2;

		 }
	|	(label=VAR ARROW_RIGHT)? e=emit_block {
			HashMap tmp = new HashMap();
			tmp.put("emit",$e.emit_value);

//		 	if($label.text != null)
			 	tmp.put("label",$label.text);


			$result = tmp;
		}
	 )

	;

modifier_clause returns[ArrayList result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
	WITH m=modifier {temp_list.add($m.result);} (AND_AND m1=modifier {temp_list.add($m1.result);})*
	{
		$result = temp_list;
	}
	;

modifier returns[HashMap result]
	: name=(VAR|REPLACE|MATCH|EXTRACT|OTHER_OPERATORS|SPECIAL_MODIFIERS|CALLBACKS) EQUAL(e=expr | j=JS | x=XDI) {
		HashMap tmp2 = new HashMap();

		HashMap tmp = new HashMap();
		if($e.text != null)
		{
			tmp2.put("value",$e.result);
		}
		else if($x.text != null)
		{
      tmp.put("type","XDI");
      tmp.put("val",strip_wrappers("<[","]>",$x.text));
      tmp2.put("value",tmp);
		} else {
      tmp.put("type","JS");
      tmp.put("val",strip_wrappers("<|","|>",$j.text));
      tmp2.put("value",tmp);
		  
		}

		tmp2.put("name",$name.text);
		$result = tmp2;
	}
	;







using returns[HashMap result]
	:	USING (p=STRING|r=regex) s=setting? {
			HashMap tmp = new HashMap();
			HashMap evt_expr = new HashMap();
			if($p.text != null)
				evt_expr.put("pattern",strip_string($p.text));
			else
				evt_expr.put("pattern",$r.result);

			evt_expr.put("legacy",1);
			evt_expr.put("type","prim_event");
			evt_expr.put("op","pageview");

//			if($s.text != null)
				evt_expr.put("vars",$s.result);

			tmp.put("event_expr",evt_expr);
			tmp.put("foreach",new ArrayList());
			$result=tmp;
		};

setting returns[ArrayList result]
@init {
	ArrayList sresult = new ArrayList();
}
	:	SETTING LEFT_PAREN (v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN){sresult.add($v.text);} (COMMA v2=(VAR|LIKE|OTHER_OPERATORS|REPLACE|EXTRACT|MATCH|VAR_DOMAIN){sresult.add($v2.text);} )*)? RIGHT_PAREN {
		$result = sresult;
	}
	;


pre_block returns[ArrayList result]
@init {
	ArrayList tmp = new ArrayList();
}	:
	 PRE LEFT_CURL ( decl[tmp] (SEMI decl[tmp])* )? SEMI* RIGHT_CURL {
	 	$result = tmp;
	 }

	 ;
foreach returns[HashMap result]
	:
	FOREACH e=expr s=setting {
		HashMap tmp = new HashMap();
		tmp.put("expr",e.result);
		tmp.put("var",s.result);
		$result = tmp;
	}
	;
when returns[HashMap result]
@init {
}
	:
	//WHEN es=event_seq {
	WHEN es=event_block {
	//WHEN es=event_block_prime {
	//WHEN es=event_list {
		HashMap tmp = new HashMap();
		tmp.put("foreach",new ArrayList());
		tmp.put("event_expr",$es.result);
		$result = tmp;
	}
	;


event_block returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		LEFT_PAREN eb=event_block RIGHT_PAREN {
			$result = eb.result;
		}
		| el=event_logic tf=timeframe? {
			HashMap tmp = el.result;
	      	if($tf.text != null) {
				tmp.put("within",tf.result);
		      	tmp.put("timeframe",$tf.time);
		     } else
		      	tmp.put("timeframe",null);
			$result = tmp;
		}
		| es=event_sequence tf=timeframe? {
			HashMap tmp = es.result;
	      	if($tf.text != null) {
				tmp.put("within",tf.result);
		      	tmp.put("timeframe",$tf.time);
		     } else
		      	tmp.put("timeframe",null);
			$result = tmp;
		}
		| ea=event_arity tf=timeframe? {
			HashMap tmp = ea.result;
	      	if($tf.text != null) {
				tmp.put("within",tf.result);
		      	tmp.put("timeframe",$tf.time);
		     } else
		      	tmp.put("timeframe",null);
			$result = tmp;
		}
		| eg=event_group tf=timeframe? {
			HashMap tmp = eg.result;
	      	if($tf.text != null) {
				tmp.put("within",tf.result);
		      	tmp.put("timeframe",$tf.time);
		     } else
		      	tmp.put("timeframe",null);
			$result = tmp;
		}
		| et=event_at {
			$result = et.result;
		}
		| ebtw=event_between {
			$result = ebtw.result;
		}
		| ez=event_primitive {
			$result = ez.result;
		} 
	;

event_at returns[HashMap result]
	:
		AT_AT LEFT_PAREN dtime=expr RIGHT_PAREN {
			HashMap the_result = new HashMap();
			the_result.put("op","at");
			the_result.put("type","at_event");
			the_result.put("args",dtime.result);
			$result = the_result;
		}
	;
	
event_arity returns[HashMap result]
	:
		OR_OR elist=event_list {
			HashMap the_result = new HashMap();
			the_result.put("op","or");
			the_result.put("type","arity_event");
			the_result.put("args",elist.result);
			$result = the_result;
		}
		| AND_AND elist=event_list {
			HashMap the_result = new HashMap();
			the_result.put("op","and");
			the_result.put("type","arity_event");
			the_result.put("args",elist.result);
			$result = the_result;		
		}
		| op=must_be_one[sar("before","after","then")] elist=event_list {
			HashMap the_result = new HashMap();
			the_result.put("op",$op.text);
			the_result.put("type","arity_event");
			the_result.put("args",elist.result);
			$result = the_result;		
		}
		
	;
	
event_group returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		op=must_be_one[sar("any","repeat","count")] num=expr? elist=event_list agg=aggregates? {
			HashMap the_result = new HashMap();
			the_result.put("type","group_event");
			the_result.put("op",$op.text);
			the_result.put("args",elist.result);
			the_result.put("op_num",$num.result);
			the_result.put("agg_var", $agg.result);
			$result = the_result;
		}
		
	;

aggregates returns[HashMap result] 
@init {
	ArrayList aggvars = new ArrayList();
}
	:
	//:	          SETTING LEFT_PAREN (v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN){sresult.add($v.text);} (COMMA v2=(VAR|LIKE|OTHER_OPERATORS|REPLACE|EXTRACT|MATCH|VAR_DOMAIN){sresult.add($v2.text);} )*)? RIGHT_PAREN {
		aop = AGGREGATORS LEFT_PAREN (v=expr {aggvars.add($v.result);} (COMMA v2=expr {aggvars.add($v2.result);} )*)?  RIGHT_PAREN {
			HashMap tmp = new HashMap();
			tmp.put("agg_op",$aop.text);
			tmp.put("vars",aggvars); 
			$result = tmp;
		}
	;
	
event_list returns[ArrayList result]
@init {
	ArrayList event_list = new ArrayList();
}
	:
		LEFT_PAREN (el1=event_block{event_list.add(el1.result);} (COMMA el2=event_block {event_list.add(el2.result);})*)? RIGHT_PAREN {
			$result = event_list;
		}
	;
	
event_between returns[HashMap result]
	:
		ebtwn=event_primitive (not=NOT)? BETWEEN LEFT_PAREN eb1=event_block COMMA eb2=event_block RIGHT_PAREN {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			if($not.text != null)
				the_result.put("op","notbetween");
			else
				the_result.put("op","between");
			the_result.put("first",eb1.result);
			the_result.put("last",eb2.result );
			the_result.put("mid",ebtwn.result);
			$result = the_result;	
		}
	;	
	
event_sequence returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		ea=event_primitive op=must_be_one[sar("before","after","then")] eb=event_block {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op",$op.text);
			temp_list.add(ea.result); // new
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(eb.result);
			$result = the_result;		
		
		}
		| eabw=event_between op=must_be_one[sar("before","after","then")] eb=event_block {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op",$op.text);
			temp_list.add(eabw.result); // new
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(eb.result);
			$result = the_result;		
		
		}
		;

event_btwn returns[HashMap result]
	:
		ep=event_prim ((not=NOT)?  BETWEEN LEFT_PAREN es1=event_seq COMMA es2=event_seq RIGHT_PAREN)? {


			if($es1.text == null)
			{
				$result = ep.result;
			}
			else
			{
				HashMap the_result = new HashMap();
				the_result.put("type","complex_event");
				if($not.text != null)
					the_result.put("op","notbetween");
				else
					the_result.put("op","between");
				the_result.put("first",es1.result);
				the_result.put("last",es2.result);
				the_result.put("mid",ep.result);
				$result = the_result;

			}
		}
	;


event_logic returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		eo = event_or2 {
			$result = eo.result;
		}
		| ea = event_and2 {
			$result = ea.result;
		}
	;
	
event_or2 returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		ebtw=event_between OR_OR e2=event_block {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op","or");
			temp_list.add(ebtw.result);
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(e2.result);
			$result = the_result;
		
		}
		|		e1=event_primitive OR_OR e2=event_block{
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op","or");
			temp_list.add(e1.result);
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(e2.result);
			$result = the_result;
		}
	
	;
	
event_and2 returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		ebtw=event_between AND_AND e2=event_block {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op","and");
			temp_list.add(ebtw.result);
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(e2.result);
			$result = the_result;
		
		}
		| e1=event_primitive AND_AND e2=event_block {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op","and");
			temp_list.add(e1.result);
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(e2.result);
			$result = the_result;
		
		}
	;

//event_block_prime returns[HashMap result]
//@init {
//	ArrayList temp_list = new ArrayList();
//	//ArrayList temp_list_2 = new ArrayList();
//}
//	:
//		eor=event_block BEFORE es=event_block {
//			HashMap the_result = new HashMap();
//			the_result.put("type","complex_event");
//			the_result.put("op","before");
//			temp_list.add(eor.result); // new
//			the_result.put("args",temp_list);
//			((ArrayList)the_result.get("args")).add(es.result);
//			$result = the_result;		
//		} |
//		eor=event_block
//		{
//			$result = eor.result;
//		}
//
//	;



event_seq returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
	//ArrayList temp_list_2 = new ArrayList();
}
	:
		eor=event_or seq=must_be_one[sar("before","after","then")]    es=event_seq
		{
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op",$seq.text);
			temp_list.add(eor.result); // new
			the_result.put("args",temp_list);
			//((ArrayList)the_result.get("args2")).add(eor.result);
			//the_result.put("args",new ArrayList());
			((ArrayList)the_result.get("args")).add(es.result);
			$result = the_result;		
		} |
		eor=event_or
		{
			$result = eor.result;
		}

	;



event_or returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		ea=event_and  OR_OR es=event_seq {
			HashMap the_result = new HashMap();
			the_result.put("type","complex_event");
			the_result.put("op","or");
			temp_list.add(ea.result);
			the_result.put("args",temp_list);
			((ArrayList)the_result.get("args")).add(es.result);
			$result = the_result;

		} |
		ea=event_and {
			$result=ea.result;
		}
	;
event_and returns[HashMap result]
@init {
	ArrayList temp_list = new ArrayList();
}
	:
		e=event_btwn {temp_list.add(e);} (AND_AND e1=event_btwn { temp_list.add(e1);} )* {

			if(temp_list.size() == 1)
			{
				$result = ((event_btwn_return)temp_list.get(0)).result;
			}
			else
			{
				HashMap the_result = new HashMap();
				the_result.put("type","complex_event");
				the_result.put("op","and");
				the_result.put("args",new ArrayList());
				((ArrayList)the_result.get("args")).add(e.result);
				HashMap last = the_result;


				for(int i = 1; i <temp_list.size(); i++)
				{
					HashMap rtmp = ((event_btwn_return)temp_list.get(i)).result;
					if(i == temp_list.size() - 1)
					{
						((ArrayList)last.get("args")).add(rtmp);
					}
					else
					{
						HashMap tmp = new HashMap();
						tmp.put("type","complex_event");
						tmp.put("op","and");
						tmp.put("args",new ArrayList());
						((ArrayList)tmp.get("args")).add(rtmp);
						((ArrayList)last.get("args")).add(tmp);
						last = 	tmp;
					}
				}

				$result = the_result;

			}
		}
	;


event_primitive returns[HashMap result]
@init {
}

	:
		dom=WEB ei = event_intrinsic {			
			HashMap tmp = ei.result;
			tmp.put("domain","web");
			$result = tmp;
		}
		| dom=VAR ee = event_explicit {
			HashMap tmp = ee.result;
			tmp.put("domain",$dom.text);
			$result = tmp;
		}
		| ei2 = event_intrinsic {
			HashMap tmp = ei2.result;
			tmp.put("domain","web");
			$result = tmp;
			
		}
		//| et = event_temporal {
		//	$result = et.result;
		//}
	;
	
event_explicit returns[HashMap result]
@init {
	ArrayList filters = new ArrayList();
	ArrayList exps = new ArrayList();
}
	: op=(VAR|OTHER_OPERATORS) (ef = event_filter{filters.add(ef.result);}(ef2=event_filter{filters.add(ef2.result);})* )  set=setting? {
		HashMap tmp = new HashMap();
		//tmp.put("domain", $dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		tmp.put("filters",filters);
		$result = tmp;
	}
	| op=(VAR|OTHER_OPERATORS) WHERE (ee = event_expression{exps.add(ee.result);}(ee2 = event_expression{exps.add(ee2.result);})* ) set=setting? {
		HashMap tmp = new HashMap();
		//tmp.put("domain",$dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		tmp.put("exp",exps);
		$result = tmp;
	}
	// select when explicit foo
	| op=(VAR|OTHER_OPERATORS) set=setting? {
		HashMap tmp = new HashMap();
		tmp.put("type","prim_event");
		tmp.put("op",$op.text);
		tmp.put("vars",$set.result);
		$result = tmp;
	}
	//select when mail from #(.*)@windley.com# 
	| ef = event_filter set=setting? {
		HashMap tmp = new HashMap();
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		filters.add(ef.result);
		tmp.put("filters",filters);
		$result = tmp;
	}
	
	
	;
	
event_intrinsic returns[HashMap result]
@init {
}
	:
		ew = event_web {
			$result = ew.result;
		}
		| ep = event_pageview {
			$result = ep.result;
		}
		| eg = event_gen {
			$result = eg.result;
		}
	;


event_gen returns[HashMap result] 
@init{
	ArrayList filters = new ArrayList();
}
	//: op=VAR set=setting? {
	//	HashMap tmp = new HashMap();
	//	tmp.put("op",$op.text);
	//	tmp.put("type","prim_event");
	//	tmp.put("vars",$set.result);
	//	$result = tmp;
	//}
	: op=VAR (ef = event_filter{filters.add(ef.result);})? set=setting? {
		HashMap tmp = new HashMap();
		//tmp.put("domain", $dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		tmp.put("filters",filters);
		$result = tmp;
	
	}
	
	;

	
	
//	: DOT ( o=OTHER_OPERATORS LEFT_PAREN (e=expr {rexprs.add(e.result); } (',' e1=expr {rexprs.add(e1.result); } )*)? RIGHT_PAREN	{
event_web returns[HashMap result]
	:
		opt=must_be_one[sar("submit","click","dblclick","change","update")] elem=STRING on=on_expr?  set=setting? {
			HashMap tmp = new HashMap();
			//tmp.put("domain",$dom.text);
			tmp.put("element",strip_string($elem.text));
			tmp.put("type","prim_event");
			tmp.put("vars",$set.result);
			tmp.put("op",$opt.text);
			tmp.put("on", $on.result);
			$result = tmp;
		} 
		
	
	;	
event_pageview returns[HashMap result]
@init {
	ArrayList filters = new ArrayList();
	ArrayList exps = new ArrayList();
}
	: op=PAGEVIEW WHERE (ee = event_expression{exps.add(ee.result);}(ee2 = event_expression{exps.add(ee2.result);})* ) set=setting? {
		HashMap tmp = new HashMap();
		//tmp.put("domain",$dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		tmp.put("exp",exps);
		$result = tmp;
	}
	| op=PAGEVIEW (ef = event_filter{filters.add(ef.result);}(ef2=event_filter{filters.add(ef2.result);})* )? set=setting? {
		HashMap tmp = new HashMap();
		//tmp.put("domain", $dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$op.text);
		tmp.put("filters",filters);
		$result = tmp;
	} 
	// select when pageview #foop#
	| op=PAGEVIEW (sfilt=STRING | rfilt=regex) set=setting? {
		HashMap tmp = new HashMap();
		HashMap specialCase = new HashMap();
		tmp.put("type","prim_event");
		tmp.put("op",$op.text);
		tmp.put("vars",$set.result);
		specialCase.put("type","default");
		if($sfilt.text != null)
			specialCase.put("pattern",strip_string($sfilt.text));
		else 
			specialCase.put("pattern",$rfilt.result);
		filters.add(specialCase);
		tmp.put("filters",filters);
		$result = tmp;
	}
	;
	
event_filter returns[HashMap result]
	: typ=VAR (sfilt=STRING | rfilt=regex) {
		HashMap tmp = new HashMap();
		if (typ != null)
			tmp.put("type",$typ.text);
		else
			tmp.put("type","default");
		if($sfilt.text != null)
			tmp.put("pattern",strip_string($sfilt.text));
		else 
			tmp.put("pattern",$rfilt.result);
		$result = tmp;
	}
	;

event_expression returns[Object result]
	:
		ezzz=expr {
			$result = $ezzz.result;
		}
	;
	



event_prim returns[HashMap result]
@init {
	ArrayList filters = new ArrayList();
}
	:
	
	web=WEB? opt=must_be_one[sar("submit","click","dblclick","change","update")] elem=STRING on=on_expr?  set=setting? {
		HashMap tmp = new HashMap();

		tmp.put("domain",$web.text);
		tmp.put("element",strip_string($elem.text));
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op",$opt.text);
		tmp.put("on",$on.result);
		$result = tmp;

	}
	| '(' evt=event_seq ')' {
		$result=$evt.result;
	}
	| (custom_event)=>ce=custom_event {
	 	$result = ce.result;
	}
	

	;


custom_event  returns[HashMap result]
@init {
	ArrayList filters = new ArrayList();
	ArrayList exps = new ArrayList();
}
    :
        dom=(VAR|WEB) oper=VAR (filter=event_filter{filters.add($filter.result);})* set=setting?  {
		HashMap tmp = new HashMap();
		tmp.put("domain",$dom.text);
		tmp.put("type","prim_event");
			tmp.put("vars",$set.result);
		tmp.put("op",$oper.text);
		tmp.put("match","event_pageview");
		tmp.put("filters",filters);
		$result = tmp;
		}
	| dom=PAGEVIEW (filter =event_filter{filters.add($filter.result);})* set=setting? {
		HashMap tmp = new HashMap();
		tmp.put("domain",$dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op","filter_list");
		tmp.put("match","mult_event_pageview");
		tmp.put("filters",filters);
		$result = tmp;	
		}
	| web=WEB? PAGEVIEW (spat=STRING|rpat=regex)? set=setting? {
		HashMap tmp = new HashMap();
		tmp.put("domain",$web.text);
		if($spat.text != null)
			tmp.put("pattern",strip_string($spat.text));
		else
			tmp.put("pattern",$rpat.result);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op","pageview");
		tmp.put("match","base_pageview");
		$result = tmp;
	}
	| dom=PAGEVIEW (exp=expr{exps.add($exp.result);})* set=setting?  {
		HashMap tmp = new HashMap();
		tmp.put("domain",$dom.text);
		tmp.put("type","prim_event");
		tmp.put("vars",$set.result);
		tmp.put("op","expression");
		tmp.put("exp",exps);
		tmp.put("xmatch","expression_pageview");
		$result = tmp;
	}

    ;
    
event_exp returns[Object result]
	: e=expr {
		//HashMap tmp = $e.result;;
		//tmp.put("type","expr");
		//tmp.put("rhs",$e.result);
		//$result = tmp;
		$result = $e.result;;
		}
	;

on_expr returns[Object result] : ON
	( 	s=STRING {$result = strip_string($s.text);}
		| r=regex {$result = $r.result;}
	)
	;


	global_block
@init {
	 ArrayList global_block_array = (ArrayList)rule_json.get("global");
	 if(global_block_array == null)
	 {
	    global_block_array = new ArrayList();
	    rule_json.put("global",global_block_array);
	 }
	 boolean found_cache = false;
}
@after  {
}
	: GLOBAL LEFT_CURL
	( emt=emit_block {
		HashMap tmp = new HashMap();
		tmp.put("emit",$emt.emit_value);
		global_block_array.add(tmp);
	}
	| dst=must_be_one[sar("dataset","datasource")] name=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) (COLON dtype=DTYPE)? LEFT_SMALL_ARROW src=STRING (cas=cachable {found_cache =true; })?  {

		HashMap tmp = new HashMap();
		tmp.put("type",$dst.text);
		tmp.put("name",$name.text);
		tmp.put("datatype","JSON");
		if($dtype.text != null)
		{
			tmp.put("datatype",$dtype.text);
	        dtype = null;
		}
		tmp.put("source",strip_string($src.text));
		if(found_cache)
		{
			if($cas.what instanceof HashMap)
			{
				tmp.put("cachable",$cas.what);
			}
			else if($cas.what instanceof Long)
			{
				tmp.put("cachable",((Long)$cas.what).longValue());
			}
			else
			{
				tmp.put("cachable",0);
			}
		}
		else
		{
			tmp.put("cachable",0);
		}

		global_block_array.add(tmp);
		found_cache =false;
	}
	| cemt=css_emit {
		HashMap tmp = new HashMap();
		tmp.put("content",$cemt.emit_value);
		tmp.put("type","css");
		global_block_array.add(tmp);
	}
	| decl[global_block_array]
	| SEMI)*  RIGHT_CURL
	;

//	VAR '=' HTML |
//	VAR '=' JS |
//	VAR '=' expr

decl[ArrayList  block_array]
@init {
}
	:
	var=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) EQUAL (hval=HTML|jval=JS|e=expr) {
		HashMap tmp = new HashMap();
			tmp.put("lhs",$var.text);
		if($hval.text != null)
		{
			tmp.put("rhs",strip_wrappers("<<",">>",$hval.text));
			tmp.put("type","here_doc");
		}
		else if($jval.text != null) {
			tmp.put("rhs",strip_wrappers("<|","|>",$jval.text));
			tmp.put("type","JS");
		}
//    else if($x.text != null)
//    {
//      tmp.put("type","XDI");
//      tmp.put("rhs",strip_wrappers("<[","]>",$x.text));
//    }
		else
		{
			tmp.put("type","expr");
			tmp.put("rhs",$e.result);
		}
		block_array.add(tmp);
	 }
	;


//expr options : function_def | conditional_expression

expr returns[Object result]
@init {
	HashMap result_hash = new HashMap();
}
	: (fd=function_def {
		$result = $fd.result;
	}
	| ad=action_def {
		$result = $ad.result;
	}
	| c=conditional_expression  {
		$result = $c.result;
	})
	;
function_def returns[Object result]
@init {
	ArrayList block_array = new ArrayList();
}
	: FUNCTION LEFT_PAREN args+=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN)? (COMMA args+=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) )* RIGHT_PAREN LEFT_CURL decs+=decl[block_array]? (SEMI decs+=decl[block_array])* SEMI* e1=expr  SEMI* RIGHT_CURL {
		HashMap tmp = new HashMap();
		ArrayList nargs = new ArrayList();
		if($args != null)
		{
			for(int i = 0;i< $args.size();i++)
			{
				nargs.add(((Token)$args.get(i)).getText());
			}
		}
		tmp.put("vars",nargs);
		tmp.put("type","function");
		tmp.put("decls",block_array);
		if($e1.text != null)
			tmp.put("expr",$e1.result);

		$result = tmp;
	}
	;

action_def returns[Object result]
@init{
	ArrayList block_array = new ArrayList();
	ArrayList config_list = new ArrayList();
	HashMap actions_result = new HashMap();
}
	: DEFACTION LEFT_PAREN args+=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN)? (COMMA args+=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) )* RIGHT_PAREN
		LEFT_CURL 
		(CONFIGURE USING m=modifier { config_list.add($m.result);} (AND_AND m1=modifier {config_list.add($m1.result);})* SEMI* )*
		decs+=decl[block_array]? (SEMI decs+=decl[block_array])* SEMI* action[actions_result]  SEMI* 
		RIGHT_CURL 	
	{
		HashMap tmp = new HashMap();
		HashMap conf = new HashMap();
		ArrayList nargs = new ArrayList();
		if($args != null)
		{
			for(int i = 0;i< $args.size();i++)
			{
				nargs.add(((Token)$args.get(i)).getText());
			}
		}
		tmp.put("vars",nargs);
		tmp.put("type","defaction");
		tmp.put("decls",block_array);
        conf.put("configuration", config_list);
        tmp.put("configure",conf); 
       	tmp.put("configure",config_list); 
		tmp.put("blocktype",(actions_result.get("blocktype") != null ? actions_result.get("blocktype") : "every"));
		tmp.put("actions",actions_result.get("actions"));
        if(actions_result.get("choice") != null) tmp.put("choice",actions_result.get("choice") );

		//if($e1.text != null)
		//	tmp.put("expr",$e1.result);

		$result = tmp;
	
	};

conditional_expression returns[Object result]
@init {
	ArrayList tmp_list = new ArrayList();
}
	:  d=disjunction (ARROW_RIGHT e1=expr PIPE e2=expr)?
	   {
	   	if($e1.text == null)
	   	{
		   	$result = $d.result;
		}
		else
		{
		    HashMap tmp = new HashMap();
		    tmp.put("test",$d.result);
		    tmp.put("then",$e1.result);
		    tmp.put("else",$e2.result);
		    tmp.put("type","condexpr");
		    $result = tmp;

		}

	   }
	;


disjunction returns[Object result]
@init {
	boolean found_op = false;
	ArrayList result = new ArrayList();
}
	: me1=equality_expr (op=(OR|AND) me2=equality_expr{
		found_op = true;
		if(result.isEmpty())
		{
			 add_to_expression(result,"pred",$op.text,$me1.result);
			 add_to_expression(result,"pred",$op.text,$me2.result);
		}
		else
			 add_to_expression(result,"pred",$op.text,$me2.result);

	})* {
		if(found_op) {
			$result = build_exp_result(result);
			 }
		else
		{
			$result = $me1.result;
			}
	}
	;


equality_expr returns[Object result]
@init {
	boolean found_op = false;
	ArrayList result = new ArrayList();
}
	: me1=add_expr (op=(PREDOP|LIKE) me2=add_expr {
		found_op = true;
		if(result.isEmpty())
		{
			 add_to_expression(result,"ineq",$op.text,$me1.result);
			 add_to_expression(result,"ineq",$op.text,$me2.result);
		}
		else
			 add_to_expression(result,"ineq",$op.text,$me2.result);
	})* {
		if(found_op)
			$result = build_exp_result(result);
		else
			$result = $me1.result;
	 }
	;

mult_expr returns[Object result]
     @init {
     	boolean found_op = false;
     	ArrayList result = new ArrayList();
     }
     	: me1=unary_expr  (op=MULT_OP me2=unary_expr  {
     		found_op = true;
     		if(result.isEmpty())
     		{
     			 add_to_expression(result,"prim",$op.text,$me1.result);
     			 add_to_expression(result,"prim",$op.text,$me2.result);
     		}
     		else
     			 add_to_expression(result,"prim",$op.text,$me2.result);
     	}
     	)*  {
     		if(found_op)
     			$result = build_exp_result(result);
     		else
     			$result = $me1.result;
      }
     	;



add_expr returns[Object result]
@init {
	boolean found_op = false;
	ArrayList result = new ArrayList();
}
	: me1=mult_expr  (op=('+'|'-'|REX) me2=mult_expr  {
		found_op = true;
		if(result.isEmpty())
		{
			 add_to_expression(result,"prim",$op.text,$me1.result);
			 add_to_expression(result,"prim",$op.text,$me2.result);
		}
		else
			 add_to_expression(result,"prim",$op.text,$me2.result);
	}
	)*  {
		if(found_op)
			$result = build_exp_result(result);
		else
			$result = $me1.result;
 }
	;


unary_expr  returns[Object result] options { backtrack = true; }
@init {

}
	: NOT ue=unary_expr {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("type","pred");
	      	tmp.put("op","negation");
	      	ArrayList tmpar = new ArrayList();
	      	tmpar.add($ue.result);
	      	tmp.put("args",tmpar);
	      	$result = tmp;
	}
	| '-' ue=unary_expr {
      	   	HashMap tmp = new HashMap();
	      	tmp.put("type","prim");
	      	tmp.put("op","NEG");
            // HashMap zero = new HashMap();
            // zero.put("type","num");
            // zero.put("val", 0);
	      	ArrayList tmpar = new ArrayList();
//	      	tmpar.add(zero);
	      	tmpar.add($ue.result);
	      	tmp.put("args",tmpar);
	      	$result = tmp;
	}
	| SEEN rx=expr must_be["in"] vd=VAR_DOMAIN ':' v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) t=timeframe? {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("within",$t.result);
	      	tmp.put("type","seen_timeframe");
	      	tmp.put("var",$v.text);
	      	tmp.put("regexp",$rx.result);
	      	tmp.put("domain",$vd.text);
	      	if($t.text != null)
		      	tmp.put("timeframe",t.time);
		     else
		      	tmp.put("timeframe",null);

	      	$result = tmp;
	}
	| SEEN rx_1=expr op=must_be_one[sar("before","after")] rx_2=expr  must_be["in"] vd=VAR_DOMAIN ':' v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("type","seen_compare");
	      	tmp.put("domain",$vd.text);
	      	tmp.put("regexp_1",$rx_1.result);
	      	tmp.put("regexp_2",$rx_2.result);
	      	tmp.put("var",$v.text);
	      	tmp.put("op",$op.text);
	      	$result = tmp;
	}
	| vd=VAR_DOMAIN COLON v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) pop=(PREDOP|LIKE) e=expr t=timeframe  {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("within",$t.result);
	      	tmp.put("timeframe",t.time);
	      	tmp.put("type","persistent_ineq");
	      	tmp.put("domain",$vd.text);
	      	tmp.put("expr",$e.result);
	      	tmp.put("var",$v.text);
	      	tmp.put("ineq",$pop.text);
	      	$result = tmp;

	}
	| vd=VAR_DOMAIN COLON v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) t=timeframe {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("within",$t.result);
	      	tmp.put("timeframe",t.time);
	      	tmp.put("type","persistent_ineq");
	      	tmp.put("domain",$vd.text);
	      	HashMap tmp2 = new HashMap();
	      	tmp2.put("val","true");
	      	tmp2.put("type","bool");
	      	tmp.put("expr",tmp2);
	      	tmp.put("ineq","==");
	      	tmp.put("var",$v.text);
	      	$result = tmp;

	}
	| roe=regex {
		$result = $roe.result;
	}
	| oe=operator_expr {
		$result = $oe.result;
	}
	;


operator_expr returns[Object result]
@init
{
	ArrayList operators = new ArrayList();
}
	: f=factor  (o=operator { operators.add(o); })* {
		if(operators.size() > 0)
		{
			HashMap the_result = null;
			HashMap last_one = null;
			ArrayList templist = new ArrayList();
			for(int i = 0;i < operators.size();i++)
			{
				RuleSetParser.operator_return current = (RuleSetParser.operator_return)operators.get(i);
				HashMap tmp = new HashMap();
			      	tmp.put("type","operator");
		      		tmp.put("name",current.oper);
				tmp.put("args",current.exprs);
				templist.add(tmp);
			}
			for(int i = (templist.size() - 1);i > -1;i--)
			{
				HashMap current = (HashMap)templist.get(i);
				if(i == (templist.size() - 1))
				{
					the_result = current;
				}
				if(i != 0 )
				{
					current.put("obj",templist.get(i-1));
				}
		      	last_one = current;
			}
			last_one.put("obj",$f.result);
		    $result = the_result;;
		}
		else
		{
			$result = $f.result;
		}
	}
	;

operator returns[String oper,ArrayList exprs]
@init
{
	ArrayList rexprs = new ArrayList();
}
	: DOT ( o=OTHER_OPERATORS LEFT_PAREN (e=expr {rexprs.add(e.result); } (',' e1=expr {rexprs.add(e1.result); } )*)? RIGHT_PAREN	{
      		// Remove .
      		$oper = $o.text;
      		$exprs = rexprs;
      	}
      	|
      	 o1=MATCH LEFT_PAREN e=expr { rexprs.add(e.result); }  RIGHT_PAREN	{
      		// Remove .
      		$oper = $o1.text;
      		$exprs = rexprs;
      	}
      	|
      	 o1=EXTRACT LEFT_PAREN e=expr { rexprs.add(e.result); }  RIGHT_PAREN	{
      		// Remove .
      		$oper = $o1.text;
      		$exprs = rexprs;
      	}
      	|
      	 o2=REPLACE LEFT_PAREN rx=expr {rexprs.add($rx.result); } ',' e1=expr  RIGHT_PAREN	{
	          rexprs.add(e1.result);

      		// Remove .
      		$oper = $o2.text;
      		$exprs = rexprs;
      	} )
	;
//	 'i'|'g'|'m'

// TODO: REGEX needs to be added      | REGEXP
factor returns[Object result] options {backtrack=true;}
@init {
      ArrayList exprs2 = new ArrayList();

}
	: iv=INT {
		HashMap tmp = new HashMap();
		tmp.put("type","num");
		tmp.put("val",Long.parseLong($iv.text.trim()));
		$result = tmp;
	}
      | sv= STRING  {
      		HashMap tmp = new HashMap();
		tmp.put("type","str");
		tmp.put("val",strip_string($sv.text));
		$result = tmp;
	}
      | fv= FLOAT  {
      		HashMap tmp = new HashMap();
		tmp.put("type","num");
		tmp.put("val",Float.parseFloat($fv.text.trim()));
		$result = tmp;
	}
      | bv= (TRUE| FALSE)  {
    HashMap tmp = new HashMap(); 		
		tmp.put("type","bool");
		tmp.put("val",$bv.text);
		$result = tmp;
	}
	| xdi=XDI {
      HashMap tmp = new HashMap();
      tmp.put("type","XDI");
      tmp.put("val",strip_wrappers("<[","]>",$xdi.text));
      $result = tmp;
	}
      | bv=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) LEFT_BRACKET e=expr RIGHT_BRACKET  {
      		HashMap tmp = new HashMap();
		HashMap val = new HashMap();

		HashMap index = new HashMap();
		index.putAll((HashMap)$e.result);
		val.put("var_expr",$bv.text);

		val.put("index",index);
		tmp.put("type","array_ref");

		tmp.put("val",val);
		$result = tmp;
      }
      | n=namespace bv=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) LEFT_BRACKET e=expr RIGHT_BRACKET  {
      		HashMap tmp = new HashMap();
			HashMap val = new HashMap();
			HashMap index = new HashMap();
			index.putAll((HashMap)$e.result);
			val.put("var_expr",$bv.text);
			val.put("index",index);
			tmp.put("type","persistent");
			tmp.put("val",val);
			$result = tmp;
      }
      | bv=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) LEFT_CURL k=hash_key RIGHT_CURL  {
      		HashMap tmp = new HashMap();
			tmp.put("var_expr",$bv.text);
			tmp.put("hash_key",$k.result);
			tmp.put("type","hash_ref");
			$result = tmp;
      }
      | n=namespace bv=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) LEFT_CURL k=hash_key RIGHT_CURL  {
      		HashMap tmp = new HashMap();
	      	tmp.put("domain",$n.text.substring(0,$n.text.length() - 1));
			tmp.put("var_expr",$bv.text);
			tmp.put("hash_key",$k.result);
			tmp.put("type","persistent");
			$result = tmp;
      }
      | n=namespace p=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN|VERSION) LEFT_PAREN (e=expr { exprs2.add($e.result); } ( COMMA e=expr { exprs2.add($e.result);})* )? RIGHT_PAREN  {
	      	HashMap tmp = new HashMap();
	      	tmp.put("type","qualified");
	      	tmp.put("predicate",$p.text);
	      	tmp.put("source",$n.text.substring(0,$n.text.length() - 1));
	      	tmp.put("args",exprs2);
	      	$result = tmp;
      }
      // persistant or qualified variable
      | n=namespace vv=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) {
	      	HashMap tmp = new HashMap();
	      	tmp.put("domain",$n.text.substring(0,$n.text.length() - 1));
	      	tmp.put("name",$vv.text);
	      	tmp.put("type","persistent");
	      	$result = tmp;
      }
      | CURRENT d=VAR_DOMAIN COLON v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("domain",$d.text);
	      	tmp.put("name",$v.text);
	      	tmp.put("type","trail_history");
	      	HashMap tmp2 = new HashMap();
	      	tmp2.put("val","0");
	      	tmp2.put("type","num");
	      	tmp.put("offset",tmp2);
	      	$result = tmp;
      }
      | HISTORY e=expr d=VAR_DOMAIN COLON v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) {
      	      	HashMap tmp = new HashMap();
	      	tmp.put("domain",$d.text);
	      	tmp.put("name",$v.text);
	      	tmp.put("type","trail_history");
      	      	HashMap tmp2 = new HashMap();
	      	tmp2.putAll((HashMap)$e.result);
	      	tmp.put("offset",tmp2);
	      	$result = tmp;
      }
      | v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN) LEFT_PAREN (e=expr{  exprs2.add($e.result); } ( COMMA e=expr {  exprs2.add($e.result); })* )? RIGHT_PAREN	{
	      	HashMap tmp = new HashMap();
	      	tmp.put("type","app");
	      	HashMap tmp2 = new HashMap();
	      	tmp2.put("val",$v.text);
	      	tmp2.put("type","var");
	      	tmp.put("function_expr",tmp2);
	      	tmp.put("args",exprs2);
	      	$result = tmp;

      }
      | LEFT_BRACKET (e=expr { exprs2.add($e.result); } (COMMA e2=expr{	exprs2.add($e2.result);})* )? RIGHT_BRACKET {
      		HashMap tmp = new HashMap();
      		tmp.put("val",exprs2);
      		tmp.put("type","array");

	      	$result = tmp;
      }
      | LEFT_CURL (h1=hash_line {  exprs2.add($h1.result);} (COMMA h2=hash_line { exprs2.add($h2.result); })* )? RIGHT_CURL {
      		HashMap tmp = new HashMap();
      		tmp.put("val",exprs2);
      		tmp.put("type","hashraw");

	      	$result = tmp;
      }
      | LEFT_PAREN e=expr  RIGHT_PAREN { 
            $result=$e.result; 
      }
      | v=(VAR|OTHER_OPERATORS|REPLACE|EXTRACT|MATCH|VAR_DOMAIN)   {
      		HashMap tmp = new HashMap();
		tmp.put("type","var");
		tmp.put("val",$v.text);
		$result = tmp;
      }
      | reg=regex {
	      HashMap tmp = new HashMap();
		tmp.put("type","var");
		tmp.put("val",$reg.result);
		$result = tmp;
      	}
	| nl=NULL {
		HashMap tmp = new HashMap();
		tmp.put("type","null");
		tmp.put("val","__undef__");
		$result = tmp;	
	}

	;

// var_domain: must_be_one[sar("ent","app")];



fragment namespace returns[String result]
	: v=(VAR|OTHER_OPERATORS|LIKE|REPLACE|EXTRACT|MATCH|VAR_DOMAIN|META) ':'
	{
		$result = $v.text;
	}
	;


timeframe returns[Object result,String time]
	:  WITHIN e=expr p=period {
		$result = $e.result;
		$time = fix_time($p.text);
	}

	;
hash_key returns[Object result]
	: k=expr {
		$result = $k.result;
	}
	
	;
		
hash_line  returns[HashMap result]
	: s=expr COLON e=expr  {
		HashMap tmp = new HashMap();
//		tmp.put("lhs",strip_string($s.text));
		tmp.put("lhs",$s.result);
		tmp.put("rhs",$e.result);
//		tmp.put("val",$e.result);
		$result = tmp;
	}
	;

css_emit returns[String emit_value]
	: CSS ( h=HTML {$emit_value = strip_wrappers("<<",">>",$h.text);}
	|h=STRING {$emit_value = strip_string($h.text);}
	)
	;

period
	:
		must_be_one[sar( "years", "months", "weeks", "days", "hours", "minutes", "seconds", "year", "month", "week", "day", "hour", "minute", "second")]
	;

/*	  'years'
	| 'months'
	| 'weeks'
	| 'days'
      	| 'hours'
	| 'minutes'
      	| 'seconds'
      	| 'year'
	| 'month'
 	| 'week'
	| 'day'
	| 'hour'
	| 'minute'
 	| 'second'
 	;
*/

cachable returns[Object what]
@init {
	$what = null;
}
	:
		ca=CACHABLE (FOR tm=INT per=period)? {
 			if($tm.text != null)
 			{
	 			$what = new HashMap();
	 			((HashMap)$what).put("value",$tm.text);
	 			((HashMap)$what).put("period",fix_time($per.text));
	 		}
	 		else if($ca.text != null)
	 		{
	 			$what = new Long(1);
	 		}
	 		else
	 		{
	 			$what = new Long(0);
	 		}
 		}
	;


emit_block  returns[String emit_value]
	: EMIT ( h=HTML {$emit_value = strip_wrappers("<<",">>",$h.text);}
   	       | h=STRING {$emit_value = strip_string($h.text);}
	       | h=JS {$emit_value = strip_wrappers("<|","|>",$h.text);}
	)
	;
meta_block
@init {
	 HashMap meta_block_hash = (HashMap)rule_json.get("meta");

	      if(meta_block_hash == null)
     	 {
     	    meta_block_hash = new HashMap();
     	    rule_json.put("meta",meta_block_hash);
     	 }

	 ArrayList use_list = new ArrayList();
	 HashMap keys_map = new HashMap();
	 HashMap key_values = new HashMap();
	 HashMap provide_keys_map = new HashMap();
     ArrayList provide_list = new ArrayList();
     ArrayList pkey_list = new ArrayList();
     ArrayList prid_list = new ArrayList();
     ArrayList config_list = new ArrayList();
     ArrayList temp_list = new ArrayList();
     

}
@after  {
	if(!keys_map.isEmpty())
	{
		meta_block_hash.put("keys",keys_map);
	}
	if(!use_list.isEmpty())
	{
		meta_block_hash.put("use",use_list);
	}
	if(!provide_keys_map.isEmpty())
	{
		meta_block_hash.put("provides_keys",provide_keys_map);
	}
}
	: META LEFT_CURL
	(  name=must_be_one[sar("description","name","author")] (html_desc=HTML|string_desc=STRING)
		{
			if($string_desc.text != null)
				meta_block_hash.put($name.text,strip_string($string_desc.text));
			else
				meta_block_hash.put($name.text,strip_wrappers("<<",">>",$html_desc.text));
			$html_desc = null;
			$string_desc = null;

		}
	 | key=VAR what=VAR (key_value=STRING
	 	| LEFT_CURL (name_value_pair[key_values] (COMMA name_value_pair[key_values])*) RIGHT_CURL) +  {
	 	/*
	 	This was key VAR but it was changed to VAR VAR in order to not make key reserved.
	 	*/
	 	if(!$key.text.equals("key") )
	 	{
	 	    throw new InvalidToken("Found [" + $key.text + "] should have been key", input);
        }
		if(!key_values.isEmpty())
			keys_map.put($what.text.trim(),key_values);
		else if($key_value.text != null)
			keys_map.put($what.text.trim(),strip_string($key_value.text));
		else
			throw new InvalidToken("key must have a string or key values", input);

        key_values = new HashMap();
	}
	| AUTHZ REQUIRE must_be["user"] {
		HashMap tmp = new HashMap();
		tmp.put("level","user");
		tmp.put("type","require");
		meta_block_hash.put("authz",tmp);
	   }
	| LOGGING onoff=(ON|OFF) {  meta_block_hash.put("logging",$onoff.text); }
	| must_be["errors"] must_be["to"] erid=VAR (VERSION ver=STRING)?	{
		HashMap tmp = new HashMap();
		tmp.put("rid",$erid.text);
		if ($ver.text != null) {
			tmp.put("version",strip_string($ver.text));
		}
		meta_block_hash.put("errors",tmp);
	}
	| SHARABLE onoff=(ON|OFF) {  meta_block_hash.put("sharing",$onoff.text); }
	| USE ( (rtype=(CSS|JAVASCRIPT) must_be["resource"] (url=STRING | nicename=VAR)    {
		HashMap tmp = new HashMap();
		HashMap tmp2 = new HashMap();
		if($url.text != null)
		{
			tmp2.put("location",strip_string($url.text));
			tmp2.put("type","url");
		}
		else
		{
			tmp2.put("location",$nicename.text);
			tmp2.put("type","name");
		}
		tmp.put("resource",tmp2);

		tmp.put("type","resource");
		tmp.put("resource_type",$rtype.text);
		use_list.add(tmp);
	 })
 	| (MODULE  modname=VAR (VERSION ver=STRING)? (ALIAS alias=VAR)? (WITH m=modifier {temp_list.add($m.result);} (AND_AND m1=modifier {temp_list.add($m1.result);})*)?) {
		HashMap tmp = new HashMap();
		tmp.put("name",$modname.text);
		tmp.put("type","module");
        tmp.put("alias",$alias.text);
        if ($ver.text != null) {        	
        	tmp.put("version",strip_string($ver.text));
            $ver = null;
        }
        alias = null;
        tmp.put("modifiers",temp_list);
        temp_list = new ArrayList();
		use_list.add(tmp);
	 })
    | PROVIDE e=VAR { provide_list.add($e.text); } (COMMA e2=VAR { provide_list.add($e2.text);})*  {
      	HashMap tmp = new HashMap();
      	tmp.put("names",provide_list);
        meta_block_hash.put("provide",tmp); 
        }
/*
    | PROVIDE op=OTHER_OPERATORS k=VAR {  pkey_list.add($k.text); } (COMMA k2=VAR { pkey_list.add($k2.text);})*  
    	must_be["to"] r=VAR {  prid_list.add($r.text); } (COMMA r2=VAR { prid_list.add($r2.text);})*
       {
*/
    | PROVIDE op=OTHER_OPERATORS k=VAR   
    	must_be["to"] r=VAR {  prid_list.add($r.text); } (COMMA r2=VAR { prid_list.add($r2.text);})*
       {
          HashMap tmp = new HashMap();
          if(!$op.text.equals("keys") )
          {
              throw new InvalidToken("Found [" + $op.text + "] should have been keys", input);
          }
          tmp.put("provides_keys",pkey_list);
          tmp.put("provides_rids",prid_list);
          provide_keys_map.put($k.text,prid_list);
          prid_list = new ArrayList(); // clear it out
//          meta_block_hash.put("module_keys",tmp);
        }
    | CONFIGURE USING  m=modifier {config_list.add($m.result);} (AND_AND m1=modifier {config_list.add($m1.result);})* {
      	HashMap tmp = new HashMap();
      	tmp.put("configuration", config_list);
        meta_block_hash.put("configure",tmp); 
        }

	)*
	 RIGHT_CURL

	;

dispatch_block
@init {
	 ArrayList dispatch_block_array = (ArrayList)rule_json.get("dispatch");

	 if(dispatch_block_array == null) {
     	dispatch_block_array = new ArrayList();
	 	rule_json.put("dispatch",dispatch_block_array);
     }

}
@after  {
}
	: must_be["dispatch"]  LEFT_CURL ( 
		must_be["domain"] domain=STRING (RIGHT_SMALL_ARROW rsid=STRING)? {
		HashMap tmp = new HashMap();
		tmp.put("domain",strip_string($domain.text));
		if($rsid.text != null)	{
			tmp.put("ruleset_id",strip_string($rsid.text));
			rsid = null;

		} else	{
			tmp.put("ruleset_id",null);
			rsid = null;


		}
		dispatch_block_array.add(tmp);
		}
		
		| IFRAME regexp=STRING {
			HashMap tmp = new HashMap();
			tmp.put("iframe",strip_string($regexp.text));
			dispatch_block_array.add(tmp);
		}
		)*
		RIGHT_CURL
	;



name_value_pair[HashMap key_values]
@init {
	Object value = null;
}
	: k=STRING COLON (
		v=INT {value =$v.text;}
		| v=FLOAT {value = $v.text;}
		| v=STRING {value = strip_string($v.text);})
		{key_values.put(strip_string($k.text),value);}
	;


/*REGEX
    :  '/' ( options {greedy=false;} : .   ) * '/'
    ;

*/
regex returns[HashMap result]
@init {

}
     :
       rx=REX {
            HashMap tmp = new HashMap();
            tmp.put("type","regexp");
            if($rx.text.charAt(0) == '#')
            {
                tmp.put("val",$rx.text);
            }
            else
            {
                tmp.put("val",$rx.text.substring(2,$rx.text.length()));
            }
            $result = tmp;
        }
     ;
     

REX 	: 're/' ((ESC_SEQ)=>ESC_SEQ | '\\/' | ~('/')  )* '/' ('g'|'i'|'m')* |
        're#' ((ESC_SEQ)=>ESC_SEQ | '\\#' | ~('#')  )* '#' ('g'|'i'|'m')* |
        '#'  ((ESC_SEQ)=>ESC_SEQ | '\\#' | ~('#')  )* '#' ('g'|'i'|'m')*
	;



/*regex returns[String result]
@init {
     String data = "";
}
     :
      ( SLASH ((ESC_SEQ)=>r=ESC_SEQ {data = data + $r.text; } |  r=('\\/' |'^'|'&'|'['|']'|'$') {data = data + $r.text; } | r=~(SLASH) {data = data + $r.text; } )* SLASH   { $result = "/" + data + "/"; } )
       |
       ('#' (
            r='\\#' {data = data + $r.text; }
            | r=~('#') {data = data + $r.text; } )+ '#'   { $result = "#" + data + "#"; } )
     ;

*/

// EDOM 
// 	:	(EXPLICIT | SYSTEM);

// RDOM 
// 	:	( HTTP | EXPLICIT);
 	
// fragment HTTP
// 	:	 'http';
 	
// fragment EXPLICIT 
// 	:	'explicit';
 	
// fragment SYSTEM 
// 	:	'system';
 		
 IFRAME : 'iframe';
 RAISE 
 	:	 'raise';
 SCHEDULE : 'schedule';

 ARROW_RIGHT
	:	'=>';
 PIPE :
'|';

 SEMI : ';';
 FUNCTION : 'function';
 DEFACTION: 'defaction';	 
 EQUAL :'=';

 OR
	:	 '||';
 AND
	:	 '&&';


 CONFIGURE : 'configure';
 WITH : 'with';
 USING : 'using';

 SETTING
	:	 'setting';
 PRE : 'pre';

 FOREACH: 'foreach';

 WHEN :'when';
 OR_OR : 'or';
 WHERE
 	:	 'where';
// EXPLICIT
// 	: 'explicit';

// AFTER 
//	:	 'after';
// 	
// BEFORE 
// 	:	 'before';
 
// THEN
// 	:	'then';
 	
 AND_AND : 'and';
 
 AT_AT 
 	:	 'at';

 BETWEEN : 'between';

   WEB: 'web';
  PAGEVIEW :'pageview';


 LEFT_SMALL_ARROW
	:	 '<-';

 RIGHT_SMALL_ARROW
	:	 ' ->';
 GLOBAL: 'global';
 DTYPE
	:('JSON'|'XML'|'RSS'|'HTML');

LIKE	:	'like';
PREDOP: '<=' | '>=' | '<' | '>' | '==' | '!=' | 'eq' | 'neq' | '><' | '<=>' | 'cmp';

//ADD_OP: '+'|'-';

 CALLBACKS : 'callbacks';
 SUCCESS : 'success';
 FAILURE
	:	 'failure';

 FORGET: 'forget';
 MARK:'mark';
 SET: 'set';
 SETE
 	:	'sete';
 CLEAR: 'clear';

 COUNTER_OP: '+='
           | ' -='
 ;

IF: 'if';
CHOOSE 	:	'choose';
EVERY 	:	'every';



COMMENT
    :   '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
    |   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;


WS  :   ( ' '
	| '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;

STRING
    :  '"' ( '\\"' | ~('"') )* '"'  | '\'' ( '\\\'' | ~('\'') )* '\''
    ;

fragment POUND
	:	 '#';



HTML
	: '<<' ( options {greedy=false;} : . )* '>>'
	;

JS
	: '<|' ( options {greedy=false;} : . )* '|>'
	;
	
XDI
  : '<[' ( options {greedy=false;} : . )* ']>'
	;
	
/*fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;
  */
fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;



ESC_SEQ
    :   '\\' ('b'|'d'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\'|'.'|'w'|'s'|'?'|'('|')'|'-')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

/*fragment
ESC_SEQ
    :   '\\' ('b'|'d'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\'|'?'|'.'|'w'|'s'|'('|')'|'-')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;
*/

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    |   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;



/*

 ruleset <name> {
 }

*/
 RULE_SET
	: 'ruleset'
	;

MULT_OP: '*'|'/'|'%'
	;

SPECIAL_MODIFIERS : '_api' | '_rids';

DOT
	:	 '.';

MATCH
	: 'match';

REPLACE
	: 'replace';

EXTRACT
    : 'extract';
    
//ADVERBS
//	: 'after' | 'before' | 'then'
//	;

OTHER_OPERATORS
	: 'pick'|'length'|'as'|'head'|'tail'|'sort'|'index'
    | 'pset'
    | 'filter'|'collect'|'map'|'reduce'|'reverse' | 'range' | 'pairwise'| 'any' | 'all' | 'none' | 'notall'
    | 'substr'| 'uc'|'lc' | 'capitalize' | 'split' | 'sprintf' | 'join' | 'query' | 'trim' 
    | 'has' | 'union' | 'difference' | 'intersection' | 'unique' | 'once' | 'slice'| 'splice'
    | 'duplicates' | 'append' | 'put' | 'delete' | 'keys' | 'values'
    | 'encode' | 'decode' 
    | 'typeof' | 'isnull'
    | 'klog' | 'defaultsTo'
    | 'chr' | 'ord'
    ;

AGGREGATORS
	: 'max' | 'min' | 'sum' | 'avg' | 'push'
	;
 TRUE :'true';
 FALSE :'false';
 CURRENT: 'current';

// KEY
//	:	'key'
//	;
 AUTHZ
	:	'authz'
	;

 REQUIRE
	:
	 'require'
	 ;
 LOGGING
	:'logging';

 SHARABLE
	:'sharing';

 USE
	:	'use'
	;
 PROVIDE
	:	'provide' | 'provides'
	;
 VERSION
 	:	'version'
 	;
 CSS
	:'css';

 JAVASCRIPT
	:'javascript';

 META
	: 'meta'
	;

ON
	:	 'on';

OFF 	: 'off';


 MODULE
	:	'module';

 ALIAS
	:'alias';

 EMIT
	:	'emit'
	;

 CACHABLE
	:'cachable' | 'cacheable'
	;

 FOR
	:	'for'
	;

 WITHIN
	:	'within'
	;

 COLON
	:	 ':';

 HISTORY
	:
	'history'
	;
 RIGHT_PAREN
	: ')'
	;
 LEFT_PAREN
	: '('
	;

 RIGHT_BRACKET
	:	 ']';

 LEFT_BRACKET
	:	'['
	;

 COMMA
	:	','
	;
 LEFT_CURL
	:	 '{';
 RIGHT_CURL
	: '}'
	;
NOT :	'not';
SEEN :'seen';

VAR_DOMAIN:  'ent' | 'app'
    ;

NULL	:	'null';


VAR  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
   ;




INT :	DIGIT+
    ;


FLOAT
    :    DIGIT+ '.' DIGIT*
    |    '.' DIGIT+

    ;

fragment
DIGIT: '0'..'9';
