// $ANTLR 3.2 Sep 23, 2009 12:02:23 RuleSet.g 2010-08-09 09:33:33

	package com.kynetx;
	import java.util.HashMap;
	import java.util.ArrayList;
//	import org.json.*;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.antlr.runtime.tree.*;

public class RuleSetParser extends Parser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_SET", "LEFT_CURL", "RIGHT_CURL", "VAR", "INT", "SEMI", "IF", "CALLBACKS", "SUCCESS", "FAILURE", "EQUAL", "STRING", "VAR_DOMAIN", "COLON", "COUNTER_OP", "FORGET", "MARK", "WITH", "FOR", "EVERY", "CHOOSE", "ARROW_RIGHT", "REPLACE", "MATCH", "OTHER_OPERATORS", "LEFT_PAREN", "COMMA", "RIGHT_PAREN", "AND_AND", "JS", "USING", "SETTING", "PRE", "FOREACH", "WHEN", "OR_OR", "NOT", "BETWEEN", "WEB", "PAGEVIEW", "ON", "GLOBAL", "DTYPE", "LEFT_SMALL_ARROW", "HTML", "FUNCTION", "PIPE", "OR", "AND", "PREDOP", "ADD_OP", "MULT_OP", "REX", "SEEN", "DOT", "FLOAT", "TRUE", "FALSE", "LEFT_BRACKET", "RIGHT_BRACKET", "CURRENT", "HISTORY", "WITHIN", "CSS", "CACHABLE", "EMIT", "META", "KEY", "AUTHZ", "REQUIRE", "LOGGING", "OFF", "USE", "JAVASCRIPT", "MODULE", "ALIAS", "RIGHT_SMALL_ARROW", "ESC_SEQ", "COMMENT", "WS", "POUND", "EXPONENT", "HEX_DIGIT", "UNICODE_ESC", "OCTAL_ESC"
    };
    public static final int FUNCTION=49;
    public static final int ARROW_RIGHT=25;
    public static final int EXPONENT=85;
    public static final int LEFT_BRACKET=62;
    public static final int OCTAL_ESC=88;
    public static final int EMIT=69;
    public static final int FOR=22;
    public static final int FLOAT=59;
    public static final int PRE=36;
    public static final int HTML=48;
    public static final int NOT=40;
    public static final int AND=52;
    public static final int CALLBACKS=11;
    public static final int EOF=-1;
    public static final int REQUIRE=73;
    public static final int META=70;
    public static final int IF=10;
    public static final int LEFT_CURL=5;
    public static final int HISTORY=65;
    public static final int SUCCESS=12;
    public static final int RULE_SET=4;
    public static final int RIGHT_PAREN=31;
    public static final int ESC_SEQ=81;
    public static final int REX=56;
    public static final int SETTING=35;
    public static final int CSS=67;
    public static final int USING=34;
    public static final int COMMA=30;
    public static final int OFF=75;
    public static final int REPLACE=26;
    public static final int AND_AND=32;
    public static final int EQUAL=14;
    public static final int FAILURE=13;
    public static final int RIGHT_SMALL_ARROW=80;
    public static final int RIGHT_BRACKET=63;
    public static final int PIPE=50;
    public static final int LEFT_SMALL_ARROW=47;
    public static final int RIGHT_CURL=6;
    public static final int VAR=7;
    public static final int PREDOP=53;
    public static final int COMMENT=82;
    public static final int DOT=58;
    public static final int VAR_DOMAIN=16;
    public static final int WITH=21;
    public static final int AUTHZ=72;
    public static final int MULT_OP=55;
    public static final int OTHER_OPERATORS=28;
    public static final int OR_OR=39;
    public static final int CHOOSE=24;
    public static final int MARK=20;
    public static final int POUND=84;
    public static final int KEY=71;
    public static final int WEB=42;
    public static final int UNICODE_ESC=87;
    public static final int ADD_OP=54;
    public static final int JS=33;
    public static final int EVERY=23;
    public static final int ON=44;
    public static final int HEX_DIGIT=86;
    public static final int CACHABLE=68;
    public static final int MATCH=27;
    public static final int INT=8;
    public static final int MODULE=78;
    public static final int LOGGING=74;
    public static final int TRUE=60;
    public static final int SEMI=9;
    public static final int DTYPE=46;
    public static final int CURRENT=64;
    public static final int SEEN=57;
    public static final int COLON=17;
    public static final int COUNTER_OP=18;
    public static final int WS=83;
    public static final int JAVASCRIPT=77;
    public static final int WHEN=38;
    public static final int OR=51;
    public static final int ALIAS=79;
    public static final int PAGEVIEW=43;
    public static final int WITHIN=66;
    public static final int LEFT_PAREN=29;
    public static final int FORGET=19;
    public static final int FOREACH=37;
    public static final int USE=76;
    public static final int GLOBAL=45;
    public static final int FALSE=61;
    public static final int BETWEEN=41;
    public static final int STRING=15;

    // delegates
    // delegators


        public RuleSetParser(TokenStream input) {
            this(input, new RecognizerSharedState());
        }
        public RuleSetParser(TokenStream input, RecognizerSharedState state) {
            super(input, state);
             
        }
        
    protected TreeAdaptor adaptor = new CommonTreeAdaptor();

    public void setTreeAdaptor(TreeAdaptor adaptor) {
        this.adaptor = adaptor;
    }
    public TreeAdaptor getTreeAdaptor() {
        return adaptor;
    }

    public String[] getTokenNames() { return RuleSetParser.tokenNames; }
    public String getGrammarFileName() { return "RuleSet.g"; }

     
    	public boolean check_operator = false;
    	public HashMap rule_json = new HashMap();
    	public HashMap current_top = null; 

    	public boolean checkname = true;
    	
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


    public static class ruleset_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "ruleset"
    // RuleSet.g:198:1: ruleset options {backtrack=false; } : RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF ;
    public final RuleSetParser.ruleset_return ruleset() throws RecognitionException {
        RuleSetParser.ruleset_return retval = new RuleSetParser.ruleset_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token RULE_SET1=null;
        Token LEFT_CURL3=null;
        Token RIGHT_CURL8=null;
        Token EOF9=null;
        RuleSetParser.rulesetname_return rulesetname2 = null;

        RuleSetParser.meta_block_return meta_block4 = null;

        RuleSetParser.dispatch_block_return dispatch_block5 = null;

        RuleSetParser.global_block_return global_block6 = null;

        RuleSetParser.rule_return rule7 = null;


        Object RULE_SET1_tree=null;
        Object LEFT_CURL3_tree=null;
        Object RIGHT_CURL8_tree=null;
        Object EOF9_tree=null;


         	 rule_json.put("global",new ArrayList());
         	 rule_json.put("dispatch",new ArrayList());
         	 rule_json.put("rules",new ArrayList()); 
         	 rule_json.put("meta", new HashMap());
        	 current_top = rule_json; 

        try {
            // RuleSet.g:209:3: ( RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF )
            // RuleSet.g:210:3: RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF
            {
            root_0 = (Object)adaptor.nil();

            RULE_SET1=(Token)match(input,RULE_SET,FOLLOW_RULE_SET_in_ruleset100); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RULE_SET1_tree = (Object)adaptor.create(RULE_SET1);
            adaptor.addChild(root_0, RULE_SET1_tree);
            }
            pushFollow(FOLLOW_rulesetname_in_ruleset102);
            rulesetname2=rulesetname();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, rulesetname2.getTree());
            if ( state.backtracking==0 ) {
               current_top.put("ruleset_name",(rulesetname2!=null?input.toString(rulesetname2.start,rulesetname2.stop):null)); 
            }
            LEFT_CURL3=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_ruleset109); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL3_tree = (Object)adaptor.create(LEFT_CURL3);
            adaptor.addChild(root_0, LEFT_CURL3_tree);
            }
            // RuleSet.g:212:4: ( meta_block | dispatch_block | global_block | rule )*
            loop1:
            do {
                int alt1=5;
                switch ( input.LA(1) ) {
                case META:
                    {
                    alt1=1;
                    }
                    break;
                case VAR:
                    {
                    int LA1_3 = input.LA(2);

                    if ( (LA1_3==LEFT_CURL) ) {
                        alt1=2;
                    }
                    else if ( ((LA1_3>=VAR && LA1_3<=INT)) ) {
                        alt1=4;
                    }


                    }
                    break;
                case GLOBAL:
                    {
                    alt1=3;
                    }
                    break;

                }

                switch (alt1) {
            	case 1 :
            	    // RuleSet.g:212:6: meta_block
            	    {
            	    pushFollow(FOLLOW_meta_block_in_ruleset116);
            	    meta_block4=meta_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, meta_block4.getTree());

            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:212:19: dispatch_block
            	    {
            	    pushFollow(FOLLOW_dispatch_block_in_ruleset120);
            	    dispatch_block5=dispatch_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, dispatch_block5.getTree());

            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:212:36: global_block
            	    {
            	    pushFollow(FOLLOW_global_block_in_ruleset124);
            	    global_block6=global_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, global_block6.getTree());

            	    }
            	    break;
            	case 4 :
            	    // RuleSet.g:212:51: rule
            	    {
            	    pushFollow(FOLLOW_rule_in_ruleset128);
            	    rule7=rule();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, rule7.getTree());

            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);

            RIGHT_CURL8=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_ruleset134); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL8_tree = (Object)adaptor.create(RIGHT_CURL8);
            adaptor.addChild(root_0, RIGHT_CURL8_tree);
            }
            EOF9=(Token)match(input,EOF,FOLLOW_EOF_in_ruleset138); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EOF9_tree = (Object)adaptor.create(EOF9);
            adaptor.addChild(root_0, EOF9_tree);
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
            if ( state.backtracking==0 ) {
               
              	current_top = null;  

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "ruleset"

    public static class must_be_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "must_be"
    // RuleSet.g:217:1: must_be[String what] : v= VAR ;
    public final RuleSetParser.must_be_return must_be(String what) throws RecognitionException {
        RuleSetParser.must_be_return retval = new RuleSetParser.must_be_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;

        Object v_tree=null;

        try {
            // RuleSet.g:218:3: (v= VAR )
            // RuleSet.g:219:3: v= VAR
            {
            root_0 = (Object)adaptor.nil();

            v=(Token)match(input,VAR,FOLLOW_VAR_in_must_be161); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            v_tree = (Object)adaptor.create(v);
            adaptor.addChild(root_0, v_tree);
            }
            if ( state.backtracking==0 ) {
               cn((v!=null?v.getText():null), sar(what),input); 
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "must_be"

    public static class must_be_one_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "must_be_one"
    // RuleSet.g:222:1: must_be_one[String[] what] : v= VAR ;
    public final RuleSetParser.must_be_one_return must_be_one(String[] what) throws RecognitionException {
        RuleSetParser.must_be_one_return retval = new RuleSetParser.must_be_one_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;

        Object v_tree=null;

        try {
            // RuleSet.g:223:3: (v= VAR )
            // RuleSet.g:224:3: v= VAR
            {
            root_0 = (Object)adaptor.nil();

            v=(Token)match(input,VAR,FOLLOW_VAR_in_must_be_one186); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            v_tree = (Object)adaptor.create(v);
            adaptor.addChild(root_0, v_tree);
            }
            if ( state.backtracking==0 ) {
               cn((v!=null?v.getText():null),what,input); 
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "must_be_one"

    public static class rulesetname_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "rulesetname"
    // RuleSet.g:227:2: rulesetname : ( VAR | INT );
    public final RuleSetParser.rulesetname_return rulesetname() throws RecognitionException {
        RuleSetParser.rulesetname_return retval = new RuleSetParser.rulesetname_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token set10=null;

        Object set10_tree=null;

        try {
            // RuleSet.g:228:2: ( VAR | INT )
            // RuleSet.g:
            {
            root_0 = (Object)adaptor.nil();

            set10=(Token)input.LT(1);
            if ( (input.LA(1)>=VAR && input.LA(1)<=INT) ) {
                input.consume();
                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(set10));
                state.errorRecovery=false;state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "rulesetname"

    public static class rule_name_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "rule_name"
    // RuleSet.g:237:2: rule_name : ( VAR | INT );
    public final RuleSetParser.rule_name_return rule_name() throws RecognitionException {
        RuleSetParser.rule_name_return retval = new RuleSetParser.rule_name_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token set11=null;

        Object set11_tree=null;

        try {
            // RuleSet.g:238:2: ( VAR | INT )
            // RuleSet.g:
            {
            root_0 = (Object)adaptor.nil();

            set11=(Token)input.LT(1);
            if ( (input.LA(1)>=VAR && input.LA(1)<=INT) ) {
                input.consume();
                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(set11));
                state.errorRecovery=false;state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "rule_name"

    public static class rule_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "rule"
    // RuleSet.g:242:1: rule : must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.rule_return rule() throws RecognitionException {
        RuleSetParser.rule_return retval = new RuleSetParser.rule_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token select=null;
        Token LEFT_CURL14=null;
        Token SEMI15=null;
        Token SEMI16=null;
        Token SEMI18=null;
        Token SEMI19=null;
        Token SEMI20=null;
        Token RIGHT_CURL21=null;
        RuleSetParser.rule_name_return name = null;

        RuleSetParser.must_be_one_return ait = null;

        RuleSetParser.using_return ptu = null;

        RuleSetParser.when_return ptw = null;

        RuleSetParser.foreach_return f = null;

        RuleSetParser.pre_block_return pb = null;

        RuleSetParser.emit_block_return eb = null;

        RuleSetParser.callbacks_return cb = null;

        RuleSetParser.post_block_return postb = null;

        RuleSetParser.must_be_return must_be12 = null;

        RuleSetParser.must_be_return must_be13 = null;

        RuleSetParser.action_return action17 = null;


        Object select_tree=null;
        Object LEFT_CURL14_tree=null;
        Object SEMI15_tree=null;
        Object SEMI16_tree=null;
        Object SEMI18_tree=null;
        Object SEMI19_tree=null;
        Object SEMI20_tree=null;
        Object RIGHT_CURL21_tree=null;


        	 ArrayList rule_block_array = (ArrayList)rule_json.get("rules");
        	 HashMap current_rule = new HashMap(); 
        	 HashMap actions_result = new HashMap();
        	 ArrayList fors = new ArrayList();

        try {
            // RuleSet.g:249:3: ( must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:249:6: must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_rule248);
            must_be12=must_be("rule");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be12.getTree());
            pushFollow(FOLLOW_rule_name_in_rule255);
            name=rule_name();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, name.getTree());
            pushFollow(FOLLOW_must_be_in_rule266);
            must_be13=must_be("is");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be13.getTree());
            pushFollow(FOLLOW_must_be_one_in_rule278);
            ait=must_be_one(sar("active","inactive","test"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ait.getTree());
            LEFT_CURL14=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_rule283); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL14_tree = (Object)adaptor.create(LEFT_CURL14);
            adaptor.addChild(root_0, LEFT_CURL14_tree);
            }
            select=(Token)match(input,VAR,FOLLOW_VAR_in_rule293); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            select_tree = (Object)adaptor.create(select);
            adaptor.addChild(root_0, select_tree);
            }
            if ( state.backtracking==0 ) {
               cn((select!=null?select.getText():null), sar("select"),input); 
            }
            // RuleSet.g:255:60: (ptu= using | ptw= when )
            int alt2=2;
            int LA2_0 = input.LA(1);

            if ( (LA2_0==USING) ) {
                alt2=1;
            }
            else if ( (LA2_0==WHEN) ) {
                alt2=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 2, 0, input);

                throw nvae;
            }
            switch (alt2) {
                case 1 :
                    // RuleSet.g:255:61: ptu= using
                    {
                    pushFollow(FOLLOW_using_in_rule300);
                    ptu=using();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ptu.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:255:71: ptw= when
                    {
                    pushFollow(FOLLOW_when_in_rule304);
                    ptw=when();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ptw.getTree());

                    }
                    break;

            }

            // RuleSet.g:255:81: (f= foreach )*
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);

                if ( (LA3_0==FOREACH) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // RuleSet.g:255:82: f= foreach
            	    {
            	    pushFollow(FOLLOW_foreach_in_rule310);
            	    f=foreach();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());
            	    if ( state.backtracking==0 ) {
            	       fors.add((f!=null?f.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop3;
                }
            } while (true);

            // RuleSet.g:256:8: (pb= pre_block )?
            int alt4=2;
            int LA4_0 = input.LA(1);

            if ( (LA4_0==PRE) ) {
                alt4=1;
            }
            switch (alt4) {
                case 1 :
                    // RuleSet.g:0:0: pb= pre_block
                    {
                    pushFollow(FOLLOW_pre_block_in_rule323);
                    pb=pre_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pb.getTree());

                    }
                    break;

            }

            // RuleSet.g:256:20: ( SEMI )?
            int alt5=2;
            int LA5_0 = input.LA(1);

            if ( (LA5_0==SEMI) ) {
                int LA5_1 = input.LA(2);

                if ( (synpred10_RuleSet()) ) {
                    alt5=1;
                }
            }
            switch (alt5) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI15=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule326); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI15_tree = (Object)adaptor.create(SEMI15);
                    adaptor.addChild(root_0, SEMI15_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:256:28: (eb= emit_block )?
            int alt6=2;
            int LA6_0 = input.LA(1);

            if ( (LA6_0==EMIT) ) {
                switch ( input.LA(2) ) {
                    case HTML:
                        {
                        int LA6_3 = input.LA(3);

                        if ( (synpred11_RuleSet()) ) {
                            alt6=1;
                        }
                        }
                        break;
                    case STRING:
                        {
                        int LA6_4 = input.LA(3);

                        if ( (synpred11_RuleSet()) ) {
                            alt6=1;
                        }
                        }
                        break;
                    case JS:
                        {
                        int LA6_5 = input.LA(3);

                        if ( (synpred11_RuleSet()) ) {
                            alt6=1;
                        }
                        }
                        break;
                }

            }
            switch (alt6) {
                case 1 :
                    // RuleSet.g:0:0: eb= emit_block
                    {
                    pushFollow(FOLLOW_emit_block_in_rule331);
                    eb=emit_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, eb.getTree());

                    }
                    break;

            }

            // RuleSet.g:256:41: ( SEMI )?
            int alt7=2;
            int LA7_0 = input.LA(1);

            if ( (LA7_0==SEMI) ) {
                int LA7_1 = input.LA(2);

                if ( (synpred12_RuleSet()) ) {
                    alt7=1;
                }
            }
            switch (alt7) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI16=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule334); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI16_tree = (Object)adaptor.create(SEMI16);
                    adaptor.addChild(root_0, SEMI16_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:256:47: ( action[actions_result] ( SEMI )? )*
            loop9:
            do {
                int alt9=2;
                int LA9_0 = input.LA(1);

                if ( (LA9_0==VAR) ) {
                    int LA9_2 = input.LA(2);

                    if ( (LA9_2==COLON||LA9_2==ARROW_RIGHT||LA9_2==LEFT_PAREN) ) {
                        alt9=1;
                    }


                }
                else if ( (LA9_0==LEFT_CURL||LA9_0==IF||(LA9_0>=EVERY && LA9_0<=CHOOSE)||(LA9_0>=REPLACE && LA9_0<=OTHER_OPERATORS)||LA9_0==EMIT) ) {
                    alt9=1;
                }


                switch (alt9) {
            	case 1 :
            	    // RuleSet.g:256:48: action[actions_result] ( SEMI )?
            	    {
            	    pushFollow(FOLLOW_action_in_rule338);
            	    action17=action(actions_result);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, action17.getTree());
            	    // RuleSet.g:256:71: ( SEMI )?
            	    int alt8=2;
            	    int LA8_0 = input.LA(1);

            	    if ( (LA8_0==SEMI) ) {
            	        int LA8_1 = input.LA(2);

            	        if ( (synpred13_RuleSet()) ) {
            	            alt8=1;
            	        }
            	    }
            	    switch (alt8) {
            	        case 1 :
            	            // RuleSet.g:0:0: SEMI
            	            {
            	            SEMI18=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule341); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            SEMI18_tree = (Object)adaptor.create(SEMI18);
            	            adaptor.addChild(root_0, SEMI18_tree);
            	            }

            	            }
            	            break;

            	    }


            	    }
            	    break;

            	default :
            	    break loop9;
                }
            } while (true);

            // RuleSet.g:256:81: (cb= callbacks )?
            int alt10=2;
            int LA10_0 = input.LA(1);

            if ( (LA10_0==CALLBACKS) ) {
                alt10=1;
            }
            switch (alt10) {
                case 1 :
                    // RuleSet.g:0:0: cb= callbacks
                    {
                    pushFollow(FOLLOW_callbacks_in_rule348);
                    cb=callbacks();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, cb.getTree());

                    }
                    break;

            }

            // RuleSet.g:256:93: ( SEMI )?
            int alt11=2;
            int LA11_0 = input.LA(1);

            if ( (LA11_0==SEMI) ) {
                int LA11_1 = input.LA(2);

                if ( (synpred16_RuleSet()) ) {
                    alt11=1;
                }
            }
            switch (alt11) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI19=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule351); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI19_tree = (Object)adaptor.create(SEMI19);
                    adaptor.addChild(root_0, SEMI19_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:256:104: (postb= post_block )?
            int alt12=2;
            int LA12_0 = input.LA(1);

            if ( (LA12_0==VAR) ) {
                alt12=1;
            }
            switch (alt12) {
                case 1 :
                    // RuleSet.g:0:0: postb= post_block
                    {
                    pushFollow(FOLLOW_post_block_in_rule356);
                    postb=post_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, postb.getTree());

                    }
                    break;

            }

            // RuleSet.g:256:117: ( SEMI )?
            int alt13=2;
            int LA13_0 = input.LA(1);

            if ( (LA13_0==SEMI) ) {
                alt13=1;
            }
            switch (alt13) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI20=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule359); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI20_tree = (Object)adaptor.create(SEMI20);
                    adaptor.addChild(root_0, SEMI20_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL21=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_rule364); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL21_tree = (Object)adaptor.create(RIGHT_CURL21);
            adaptor.addChild(root_0, RIGHT_CURL21_tree);
            }
            if ( state.backtracking==0 ) {

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
              			
              			current_rule.put("actions",actions_result.get("actions"));
              			if((postb!=null?input.toString(postb.start,postb.stop):null) != null)
              				current_rule.put("post",(postb!=null?postb.result:null));
              			
              			if((pb!=null?input.toString(pb.start,pb.stop):null) != null)
              				current_rule.put("pre",(pb!=null?pb.result:null));
              			
              			current_rule.put("name",(name!=null?input.toString(name.start,name.stop):null));
              			current_rule.put("emit",(eb!=null?eb.emit_value:null));
              			current_rule.put("state",(ait!=null?input.toString(ait.start,ait.stop):null));
              			current_rule.put("callbacks",(cb!=null?cb.result:null));
              			
              			if((ptu!=null?input.toString(ptu.start,ptu.stop):null) != null)
              			{
              			    (ptu!=null?ptu.result:null).put( "foreach",fors);
              				current_rule.put("pagetype",(ptu!=null?ptu.result:null));
              				}
              			else
              			{
              			    (ptw!=null?ptw.result:null).put("foreach",fors);
              				current_rule.put("pagetype",(ptw!=null?ptw.result:null));
              			}
              				
              			rule_block_array.add(current_rule);
              			 
              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "rule"

    public static class post_block_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "post_block"
    // RuleSet.g:307:1: post_block returns [HashMap result] : typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )? ;
    public final RuleSetParser.post_block_return post_block() throws RecognitionException {
        RuleSetParser.post_block_return retval = new RuleSetParser.post_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token LEFT_CURL22=null;
        Token SEMI23=null;
        Token SEMI24=null;
        Token RIGHT_CURL25=null;
        RuleSetParser.must_be_one_return typ = null;

        RuleSetParser.post_statement_return p1 = null;

        RuleSetParser.post_statement_return p2 = null;

        RuleSetParser.post_alternate_return alt = null;


        Object LEFT_CURL22_tree=null;
        Object SEMI23_tree=null;
        Object SEMI24_tree=null;
        Object RIGHT_CURL25_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:311:2: (typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )? )
            // RuleSet.g:312:2: typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_post_block395);
            typ=must_be_one(sar("fired","always","notfired"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, typ.getTree());
            LEFT_CURL22=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_post_block398); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL22_tree = (Object)adaptor.create(LEFT_CURL22);
            adaptor.addChild(root_0, LEFT_CURL22_tree);
            }
            pushFollow(FOLLOW_post_statement_in_post_block405);
            p1=post_statement();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p1.getTree());
            if ( state.backtracking==0 ) {
               temp_list.add((p1!=null?p1.result:null));
            }
            // RuleSet.g:313:51: ( SEMI p2= post_statement )*
            loop14:
            do {
                int alt14=2;
                int LA14_0 = input.LA(1);

                if ( (LA14_0==SEMI) ) {
                    int LA14_1 = input.LA(2);

                    if ( (LA14_1==VAR||LA14_1==VAR_DOMAIN||(LA14_1>=FORGET && LA14_1<=MARK)) ) {
                        alt14=1;
                    }


                }


                switch (alt14) {
            	case 1 :
            	    // RuleSet.g:313:52: SEMI p2= post_statement
            	    {
            	    SEMI23=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_block410); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI23_tree = (Object)adaptor.create(SEMI23);
            	    adaptor.addChild(root_0, SEMI23_tree);
            	    }
            	    pushFollow(FOLLOW_post_statement_in_post_block414);
            	    p2=post_statement();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, p2.getTree());
            	    if ( state.backtracking==0 ) {
            	       temp_list.add((p2!=null?p2.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop14;
                }
            } while (true);

            // RuleSet.g:313:109: ( SEMI )?
            int alt15=2;
            int LA15_0 = input.LA(1);

            if ( (LA15_0==SEMI) ) {
                alt15=1;
            }
            switch (alt15) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI24=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_block422); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI24_tree = (Object)adaptor.create(SEMI24);
                    adaptor.addChild(root_0, SEMI24_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL25=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_post_block425); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL25_tree = (Object)adaptor.create(RIGHT_CURL25);
            adaptor.addChild(root_0, RIGHT_CURL25_tree);
            }
            // RuleSet.g:314:6: (alt= post_alternate )?
            int alt16=2;
            int LA16_0 = input.LA(1);

            if ( (LA16_0==VAR) ) {
                alt16=1;
            }
            switch (alt16) {
                case 1 :
                    // RuleSet.g:0:0: alt= post_alternate
                    {
                    pushFollow(FOLLOW_post_alternate_in_post_block431);
                    alt=post_alternate();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, alt.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              //		tmp.put("alt",(alt!=null?alt.result:null));
              		tmp.put("type",(typ!=null?input.toString(typ.start,typ.stop):null));
              		tmp.put("cons",temp_list);
              		if((alt!=null?input.toString(alt.start,alt.stop):null) != null)
              		{
              			tmp.put("alt",(alt!=null?alt.result:null));
              		} 
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "post_block"

    public static class post_alternate_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "post_alternate"
    // RuleSet.g:328:1: post_alternate returns [ArrayList result] : must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.post_alternate_return post_alternate() throws RecognitionException {
        RuleSetParser.post_alternate_return retval = new RuleSetParser.post_alternate_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token LEFT_CURL27=null;
        Token SEMI28=null;
        Token SEMI29=null;
        Token RIGHT_CURL30=null;
        RuleSetParser.post_statement_return p = null;

        RuleSetParser.post_statement_return p1 = null;

        RuleSetParser.must_be_return must_be26 = null;


        Object LEFT_CURL27_tree=null;
        Object SEMI28_tree=null;
        Object SEMI29_tree=null;
        Object RIGHT_CURL30_tree=null;


        	ArrayList temp_array = new ArrayList();

        try {
            // RuleSet.g:332:2: ( must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:333:3: must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_post_alternate458);
            must_be26=must_be("else");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be26.getTree());
            LEFT_CURL27=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_post_alternate461); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL27_tree = (Object)adaptor.create(LEFT_CURL27);
            adaptor.addChild(root_0, LEFT_CURL27_tree);
            }
            // RuleSet.g:333:29: (p= post_statement ( SEMI p1= post_statement )* )?
            int alt18=2;
            int LA18_0 = input.LA(1);

            if ( (LA18_0==VAR||LA18_0==VAR_DOMAIN||(LA18_0>=FORGET && LA18_0<=MARK)) ) {
                alt18=1;
            }
            switch (alt18) {
                case 1 :
                    // RuleSet.g:333:30: p= post_statement ( SEMI p1= post_statement )*
                    {
                    pushFollow(FOLLOW_post_statement_in_post_alternate466);
                    p=post_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
                    if ( state.backtracking==0 ) {
                      temp_array.add((p!=null?p.result:null));
                    }
                    // RuleSet.g:333:76: ( SEMI p1= post_statement )*
                    loop17:
                    do {
                        int alt17=2;
                        int LA17_0 = input.LA(1);

                        if ( (LA17_0==SEMI) ) {
                            int LA17_1 = input.LA(2);

                            if ( (LA17_1==VAR||LA17_1==VAR_DOMAIN||(LA17_1>=FORGET && LA17_1<=MARK)) ) {
                                alt17=1;
                            }


                        }


                        switch (alt17) {
                    	case 1 :
                    	    // RuleSet.g:333:77: SEMI p1= post_statement
                    	    {
                    	    SEMI28=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_alternate471); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    SEMI28_tree = (Object)adaptor.create(SEMI28);
                    	    adaptor.addChild(root_0, SEMI28_tree);
                    	    }
                    	    pushFollow(FOLLOW_post_statement_in_post_alternate475);
                    	    p1=post_statement();

                    	    state._fsp--;
                    	    if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, p1.getTree());
                    	    if ( state.backtracking==0 ) {
                    	      temp_array.add((p1!=null?p1.result:null));
                    	    }

                    	    }
                    	    break;

                    	default :
                    	    break loop17;
                        }
                    } while (true);


                    }
                    break;

            }

            // RuleSet.g:333:134: ( SEMI )?
            int alt19=2;
            int LA19_0 = input.LA(1);

            if ( (LA19_0==SEMI) ) {
                alt19=1;
            }
            switch (alt19) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI29=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_alternate483); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI29_tree = (Object)adaptor.create(SEMI29);
                    adaptor.addChild(root_0, SEMI29_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL30=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_post_alternate486); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL30_tree = (Object)adaptor.create(RIGHT_CURL30);
            adaptor.addChild(root_0, RIGHT_CURL30_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = temp_array;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "post_alternate"

    public static class post_statement_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "post_statement"
    // RuleSet.g:337:1: post_statement returns [HashMap result] : ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? ) ;
    public final RuleSetParser.post_statement_return post_statement() throws RecognitionException {
        RuleSetParser.post_statement_return retval = new RuleSetParser.post_statement_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token IF31=null;
        RuleSetParser.persistent_expr_return pe = null;

        RuleSetParser.raise_statement_return rs = null;

        RuleSetParser.log_statement_return l = null;

        RuleSetParser.must_be_return las = null;

        RuleSetParser.expr_return ie = null;


        Object IF31_tree=null;

        try {
            // RuleSet.g:338:2: ( ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? ) )
            // RuleSet.g:338:4: ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:338:4: ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? )
            // RuleSet.g:338:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )?
            {
            // RuleSet.g:338:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] )
            int alt20=4;
            alt20 = dfa20.predict(input);
            switch (alt20) {
                case 1 :
                    // RuleSet.g:338:6: pe= persistent_expr
                    {
                    pushFollow(FOLLOW_persistent_expr_in_post_statement504);
                    pe=persistent_expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pe.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:339:6: rs= raise_statement
                    {
                    pushFollow(FOLLOW_raise_statement_in_post_statement514);
                    rs=raise_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, rs.getTree());

                    }
                    break;
                case 3 :
                    // RuleSet.g:340:4: l= log_statement
                    {
                    pushFollow(FOLLOW_log_statement_in_post_statement521);
                    l=log_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, l.getTree());

                    }
                    break;
                case 4 :
                    // RuleSet.g:341:4: las= must_be[\"last\"]
                    {
                    pushFollow(FOLLOW_must_be_in_post_statement531);
                    las=must_be("last");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, las.getTree());

                    }
                    break;

            }

            // RuleSet.g:342:2: ( IF ie= expr )?
            int alt21=2;
            int LA21_0 = input.LA(1);

            if ( (LA21_0==IF) ) {
                alt21=1;
            }
            switch (alt21) {
                case 1 :
                    // RuleSet.g:342:3: IF ie= expr
                    {
                    IF31=(Token)match(input,IF,FOLLOW_IF_in_post_statement537); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    IF31_tree = (Object)adaptor.create(IF31);
                    adaptor.addChild(root_0, IF31_tree);
                    }
                    pushFollow(FOLLOW_expr_in_post_statement541);
                    ie=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ie.getTree());

                    }
                    break;

            }


            }

            if ( state.backtracking==0 ) {

              		if((pe!=null?input.toString(pe.start,pe.stop):null) != null)
              		 	retval.result = (pe!=null?pe.result:null) ;
              		 	
              		if((l!=null?input.toString(l.start,l.stop):null) != null)
              		 	retval.result = (l!=null?l.result:null) ;
              		 	
              		if((rs!=null?input.toString(rs.start,rs.stop):null) != null)
              		 	retval.result = (rs!=null?rs.result:null) ;
              		 	
              		if((las!=null?input.toString(las.start,las.stop):null) != null)
              		{
              			HashMap tmp = new HashMap();
              			tmp.put("statement","last");
              			tmp.put("type","control");
              		 	retval.result = tmp;
              		}
              		 	
              		if((ie!=null?input.toString(ie.start,ie.stop):null) != null)
              		{
              			retval.result.put("test",(ie!=null?ie.result:null));
              		} 	
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "post_statement"

    public static class raise_statement_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "raise_statement"
    // RuleSet.g:368:1: raise_statement returns [HashMap result] : must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )? ;
    public final RuleSetParser.raise_statement_return raise_statement() throws RecognitionException {
        RuleSetParser.raise_statement_return retval = new RuleSetParser.raise_statement_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token evt=null;
        RuleSetParser.for_clause_return f = null;

        RuleSetParser.modifier_clause_return m = null;

        RuleSetParser.must_be_return must_be32 = null;

        RuleSetParser.must_be_return must_be33 = null;

        RuleSetParser.must_be_return must_be34 = null;


        Object evt_tree=null;

        try {
            // RuleSet.g:369:2: ( must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )? )
            // RuleSet.g:370:2: must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_raise_statement566);
            must_be32=must_be("raise");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be32.getTree());
            pushFollow(FOLLOW_must_be_in_raise_statement569);
            must_be33=must_be("explicit");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be33.getTree());
            pushFollow(FOLLOW_must_be_in_raise_statement572);
            must_be34=must_be("event");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be34.getTree());
            evt=(Token)match(input,VAR,FOLLOW_VAR_in_raise_statement578); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            evt_tree = (Object)adaptor.create(evt);
            adaptor.addChild(root_0, evt_tree);
            }
            // RuleSet.g:370:66: (f= for_clause )?
            int alt22=2;
            int LA22_0 = input.LA(1);

            if ( (LA22_0==FOR) ) {
                alt22=1;
            }
            switch (alt22) {
                case 1 :
                    // RuleSet.g:0:0: f= for_clause
                    {
                    pushFollow(FOLLOW_for_clause_in_raise_statement582);
                    f=for_clause();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());

                    }
                    break;

            }

            // RuleSet.g:370:80: (m= modifier_clause )?
            int alt23=2;
            int LA23_0 = input.LA(1);

            if ( (LA23_0==WITH) ) {
                alt23=1;
            }
            switch (alt23) {
                case 1 :
                    // RuleSet.g:0:0: m= modifier_clause
                    {
                    pushFollow(FOLLOW_modifier_clause_in_raise_statement587);
                    m=modifier_clause();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, m.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("event",(evt!=null?evt.getText():null));
              		tmp.put("domain","explicit");
              		tmp.put("type","raise");
              		if((f!=null?input.toString(f.start,f.stop):null) != null)
              			tmp.put("rid",(f!=null?f.result:null));
              			
              		if((m!=null?input.toString(m.start,m.stop):null) != null)
              			tmp.put("modifiers",(m!=null?m.result:null));	
              		
              		retval.result = tmp;	
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "raise_statement"

    public static class log_statement_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "log_statement"
    // RuleSet.g:385:1: log_statement returns [HashMap result] : must_be[\"log\"] e= expr ;
    public final RuleSetParser.log_statement_return log_statement() throws RecognitionException {
        RuleSetParser.log_statement_return retval = new RuleSetParser.log_statement_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.must_be_return must_be35 = null;



        try {
            // RuleSet.g:386:2: ( must_be[\"log\"] e= expr )
            // RuleSet.g:387:2: must_be[\"log\"] e= expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_log_statement607);
            must_be35=must_be("log");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be35.getTree());
            pushFollow(FOLLOW_expr_in_log_statement613);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("type","log");
              		tmp.put("what",(e!=null?e.result:null));
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "log_statement"

    public static class callbacks_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "callbacks"
    // RuleSet.g:395:1: callbacks returns [HashMap result] : CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL ;
    public final RuleSetParser.callbacks_return callbacks() throws RecognitionException {
        RuleSetParser.callbacks_return retval = new RuleSetParser.callbacks_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token CALLBACKS36=null;
        Token LEFT_CURL37=null;
        Token RIGHT_CURL38=null;
        RuleSetParser.success_return s = null;

        RuleSetParser.failure_return f = null;


        Object CALLBACKS36_tree=null;
        Object LEFT_CURL37_tree=null;
        Object RIGHT_CURL38_tree=null;

        try {
            // RuleSet.g:396:2: ( CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL )
            // RuleSet.g:397:2: CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            CALLBACKS36=(Token)match(input,CALLBACKS,FOLLOW_CALLBACKS_in_callbacks631); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            CALLBACKS36_tree = (Object)adaptor.create(CALLBACKS36);
            adaptor.addChild(root_0, CALLBACKS36_tree);
            }
            LEFT_CURL37=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_callbacks633); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL37_tree = (Object)adaptor.create(LEFT_CURL37);
            adaptor.addChild(root_0, LEFT_CURL37_tree);
            }
            // RuleSet.g:397:23: (s= success )?
            int alt24=2;
            int LA24_0 = input.LA(1);

            if ( (LA24_0==SUCCESS) ) {
                alt24=1;
            }
            switch (alt24) {
                case 1 :
                    // RuleSet.g:0:0: s= success
                    {
                    pushFollow(FOLLOW_success_in_callbacks637);
                    s=success();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, s.getTree());

                    }
                    break;

            }

            // RuleSet.g:397:34: (f= failure )?
            int alt25=2;
            int LA25_0 = input.LA(1);

            if ( (LA25_0==FAILURE) ) {
                alt25=1;
            }
            switch (alt25) {
                case 1 :
                    // RuleSet.g:0:0: f= failure
                    {
                    pushFollow(FOLLOW_failure_in_callbacks642);
                    f=failure();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());

                    }
                    break;

            }

            RIGHT_CURL38=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_callbacks645); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL38_tree = (Object)adaptor.create(RIGHT_CURL38);
            adaptor.addChild(root_0, RIGHT_CURL38_tree);
            }
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		if((s!=null?input.toString(s.start,s.stop):null) != null)
              		{
              			tmp.put("success",(s!=null?s.result:null));
              			
              		}
              		if((f!=null?input.toString(f.start,f.stop):null) != null)
              		{
              			tmp.put("failure",(f!=null?f.result:null));		
              		}
              		retval.result = tmp; 
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "callbacks"

    public static class success_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "success"
    // RuleSet.g:411:1: success returns [ArrayList result] : SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.success_return success() throws RecognitionException {
        RuleSetParser.success_return retval = new RuleSetParser.success_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token SUCCESS39=null;
        Token LEFT_CURL40=null;
        Token SEMI41=null;
        Token SEMI42=null;
        Token RIGHT_CURL43=null;
        RuleSetParser.click_return c = null;

        RuleSetParser.click_return c1 = null;


        Object SUCCESS39_tree=null;
        Object LEFT_CURL40_tree=null;
        Object SEMI41_tree=null;
        Object SEMI42_tree=null;
        Object RIGHT_CURL43_tree=null;


        	ArrayList tmp_list = new ArrayList();

        try {
            // RuleSet.g:415:2: ( SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL )
            // RuleSet.g:415:4: SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            SUCCESS39=(Token)match(input,SUCCESS,FOLLOW_SUCCESS_in_success667); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            SUCCESS39_tree = (Object)adaptor.create(SUCCESS39);
            adaptor.addChild(root_0, SUCCESS39_tree);
            }
            LEFT_CURL40=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_success669); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL40_tree = (Object)adaptor.create(LEFT_CURL40);
            adaptor.addChild(root_0, LEFT_CURL40_tree);
            }
            pushFollow(FOLLOW_click_in_success673);
            c=click();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, c.getTree());
            if ( state.backtracking==0 ) {
              tmp_list.add((c!=null?c.result:null));
            }
            // RuleSet.g:415:58: ( SEMI c1= click )*
            loop26:
            do {
                int alt26=2;
                int LA26_0 = input.LA(1);

                if ( (LA26_0==SEMI) ) {
                    int LA26_1 = input.LA(2);

                    if ( (LA26_1==VAR) ) {
                        alt26=1;
                    }


                }


                switch (alt26) {
            	case 1 :
            	    // RuleSet.g:415:59: SEMI c1= click
            	    {
            	    SEMI41=(Token)match(input,SEMI,FOLLOW_SEMI_in_success679); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI41_tree = (Object)adaptor.create(SEMI41);
            	    adaptor.addChild(root_0, SEMI41_tree);
            	    }
            	    pushFollow(FOLLOW_click_in_success683);
            	    c1=click();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, c1.getTree());
            	    if ( state.backtracking==0 ) {
            	      tmp_list.add((c1!=null?c1.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop26;
                }
            } while (true);

            // RuleSet.g:415:104: ( SEMI )?
            int alt27=2;
            int LA27_0 = input.LA(1);

            if ( (LA27_0==SEMI) ) {
                alt27=1;
            }
            switch (alt27) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI42=(Token)match(input,SEMI,FOLLOW_SEMI_in_success690); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI42_tree = (Object)adaptor.create(SEMI42);
                    adaptor.addChild(root_0, SEMI42_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL43=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_success694); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL43_tree = (Object)adaptor.create(RIGHT_CURL43);
            adaptor.addChild(root_0, RIGHT_CURL43_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = tmp_list;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "success"

    public static class failure_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "failure"
    // RuleSet.g:421:1: failure returns [ArrayList result] : FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.failure_return failure() throws RecognitionException {
        RuleSetParser.failure_return retval = new RuleSetParser.failure_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token FAILURE44=null;
        Token LEFT_CURL45=null;
        Token SEMI46=null;
        Token SEMI47=null;
        Token RIGHT_CURL48=null;
        RuleSetParser.click_return c = null;

        RuleSetParser.click_return c1 = null;


        Object FAILURE44_tree=null;
        Object LEFT_CURL45_tree=null;
        Object SEMI46_tree=null;
        Object SEMI47_tree=null;
        Object RIGHT_CURL48_tree=null;


        	ArrayList tmp_list = new ArrayList();

        try {
            // RuleSet.g:425:2: ( FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL )
            // RuleSet.g:426:2: FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            FAILURE44=(Token)match(input,FAILURE,FOLLOW_FAILURE_in_failure722); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FAILURE44_tree = (Object)adaptor.create(FAILURE44);
            adaptor.addChild(root_0, FAILURE44_tree);
            }
            LEFT_CURL45=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_failure724); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL45_tree = (Object)adaptor.create(LEFT_CURL45);
            adaptor.addChild(root_0, LEFT_CURL45_tree);
            }
            pushFollow(FOLLOW_click_in_failure728);
            c=click();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, c.getTree());
            if ( state.backtracking==0 ) {
              tmp_list.add((c!=null?c.result:null));
            }
            // RuleSet.g:426:56: ( SEMI c1= click )*
            loop28:
            do {
                int alt28=2;
                int LA28_0 = input.LA(1);

                if ( (LA28_0==SEMI) ) {
                    int LA28_1 = input.LA(2);

                    if ( (LA28_1==VAR) ) {
                        alt28=1;
                    }


                }


                switch (alt28) {
            	case 1 :
            	    // RuleSet.g:426:57: SEMI c1= click
            	    {
            	    SEMI46=(Token)match(input,SEMI,FOLLOW_SEMI_in_failure734); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI46_tree = (Object)adaptor.create(SEMI46);
            	    adaptor.addChild(root_0, SEMI46_tree);
            	    }
            	    pushFollow(FOLLOW_click_in_failure738);
            	    c1=click();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, c1.getTree());
            	    if ( state.backtracking==0 ) {
            	      tmp_list.add((c1!=null?c1.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop28;
                }
            } while (true);

            // RuleSet.g:426:103: ( SEMI )?
            int alt29=2;
            int LA29_0 = input.LA(1);

            if ( (LA29_0==SEMI) ) {
                alt29=1;
            }
            switch (alt29) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI47=(Token)match(input,SEMI,FOLLOW_SEMI_in_failure746); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI47_tree = (Object)adaptor.create(SEMI47);
                    adaptor.addChild(root_0, SEMI47_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL48=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_failure750); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL48_tree = (Object)adaptor.create(RIGHT_CURL48);
            adaptor.addChild(root_0, RIGHT_CURL48_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = tmp_list;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "failure"

    public static class click_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "click"
    // RuleSet.g:431:1: click returns [HashMap result] : corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )? ;
    public final RuleSetParser.click_return click() throws RecognitionException {
        RuleSetParser.click_return retval = new RuleSetParser.click_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token attr=null;
        Token val=null;
        Token EQUAL49=null;
        RuleSetParser.must_be_one_return corc = null;

        RuleSetParser.click_link_return cl = null;


        Object attr_tree=null;
        Object val_tree=null;
        Object EQUAL49_tree=null;

        try {
            // RuleSet.g:431:31: (corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )? )
            // RuleSet.g:432:2: corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_click768);
            corc=must_be_one(sar("click","change"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, corc.getTree());
            attr=(Token)match(input,VAR,FOLLOW_VAR_in_click773); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            attr_tree = (Object)adaptor.create(attr);
            adaptor.addChild(root_0, attr_tree);
            }
            EQUAL49=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_click775); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL49_tree = (Object)adaptor.create(EQUAL49);
            adaptor.addChild(root_0, EQUAL49_tree);
            }
            val=(Token)match(input,STRING,FOLLOW_STRING_in_click779); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            val_tree = (Object)adaptor.create(val);
            adaptor.addChild(root_0, val_tree);
            }
            // RuleSet.g:432:70: (cl= click_link )?
            int alt30=2;
            int LA30_0 = input.LA(1);

            if ( (LA30_0==VAR) ) {
                alt30=1;
            }
            switch (alt30) {
                case 1 :
                    // RuleSet.g:0:0: cl= click_link
                    {
                    pushFollow(FOLLOW_click_link_in_click783);
                    cl=click_link();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, cl.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("type",(corc!=null?input.toString(corc.start,corc.stop):null));
              		tmp.put("value",strip_string((val!=null?val.getText():null)));
              		tmp.put("attribute",(attr!=null?attr.getText():null));
              		tmp.put("trigger",(cl!=null?cl.result:null));
              		retval.result = tmp;	
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "click"

    public static class click_link_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "click_link"
    // RuleSet.g:442:1: click_link returns [HashMap result] : must_be[\"triggers\"] p= persistent_expr ;
    public final RuleSetParser.click_link_return click_link() throws RecognitionException {
        RuleSetParser.click_link_return retval = new RuleSetParser.click_link_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.persistent_expr_return p = null;

        RuleSetParser.must_be_return must_be50 = null;



        try {
            // RuleSet.g:443:2: ( must_be[\"triggers\"] p= persistent_expr )
            // RuleSet.g:444:2: must_be[\"triggers\"] p= persistent_expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_click_link803);
            must_be50=must_be("triggers");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be50.getTree());
            pushFollow(FOLLOW_persistent_expr_in_click_link808);
            p=persistent_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
            if ( state.backtracking==0 ) {

              		retval.result = (p!=null?p.result:null);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "click_link"

    public static class persistent_expr_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "persistent_expr"
    // RuleSet.g:450:1: persistent_expr returns [HashMap result] : (pc= persistent_clear_set | pi= persistent_iterate | tf= trail_forget | tm= trail_mark );
    public final RuleSetParser.persistent_expr_return persistent_expr() throws RecognitionException {
        RuleSetParser.persistent_expr_return retval = new RuleSetParser.persistent_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.persistent_clear_set_return pc = null;

        RuleSetParser.persistent_iterate_return pi = null;

        RuleSetParser.trail_forget_return tf = null;

        RuleSetParser.trail_mark_return tm = null;



        try {
            // RuleSet.g:451:2: (pc= persistent_clear_set | pi= persistent_iterate | tf= trail_forget | tm= trail_mark )
            int alt31=4;
            switch ( input.LA(1) ) {
            case VAR:
                {
                alt31=1;
                }
                break;
            case VAR_DOMAIN:
                {
                alt31=2;
                }
                break;
            case FORGET:
                {
                alt31=3;
                }
                break;
            case MARK:
                {
                alt31=4;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 31, 0, input);

                throw nvae;
            }

            switch (alt31) {
                case 1 :
                    // RuleSet.g:452:2: pc= persistent_clear_set
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_persistent_clear_set_in_persistent_expr830);
                    pc=persistent_clear_set();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pc.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (pc!=null?pc.result:null);
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:455:4: pi= persistent_iterate
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_persistent_iterate_in_persistent_expr840);
                    pi=persistent_iterate();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pi.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (pi!=null?pi.result:null);
                      	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:458:7: tf= trail_forget
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_trail_forget_in_persistent_expr853);
                    tf=trail_forget();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, tf.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (tf!=null?tf.result:null);
                      	
                    }

                    }
                    break;
                case 4 :
                    // RuleSet.g:461:7: tm= trail_mark
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_trail_mark_in_persistent_expr866);
                    tm=trail_mark();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, tm.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (tm!=null?tm.result:null);
                      	
                    }

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "persistent_expr"

    public static class persistent_clear_set_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "persistent_clear_set"
    // RuleSet.g:467:1: persistent_clear_set returns [HashMap result] : cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR ;
    public final RuleSetParser.persistent_clear_set_return persistent_clear_set() throws RecognitionException {
        RuleSetParser.persistent_clear_set_return retval = new RuleSetParser.persistent_clear_set_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token dm=null;
        Token name=null;
        Token COLON51=null;
        RuleSetParser.must_be_one_return cs = null;


        Object dm_tree=null;
        Object name_tree=null;
        Object COLON51_tree=null;

        try {
            // RuleSet.g:468:2: (cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR )
            // RuleSet.g:469:2: cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_persistent_clear_set891);
            cs=must_be_one(sar("clear","set"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, cs.getTree());
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_persistent_clear_set897); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON51=(Token)match(input,COLON,FOLLOW_COLON_in_persistent_clear_set899); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON51_tree = (Object)adaptor.create(COLON51);
            adaptor.addChild(root_0, COLON51_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_persistent_clear_set903); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("action",(cs!=null?input.toString(cs.start,cs.stop):null));
              		tmp.put("name",(name!=null?name.getText():null));
              		tmp.put("domain",(dm!=null?dm.getText():null));
              		tmp.put("type","persistent");
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "persistent_clear_set"

    public static class persistent_iterate_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "persistent_iterate"
    // RuleSet.g:480:1: persistent_iterate returns [HashMap result] : dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start ;
    public final RuleSetParser.persistent_iterate_return persistent_iterate() throws RecognitionException {
        RuleSetParser.persistent_iterate_return retval = new RuleSetParser.persistent_iterate_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token dm=null;
        Token name=null;
        Token op=null;
        Token COLON52=null;
        RuleSetParser.expr_return v = null;

        RuleSetParser.counter_start_return from = null;


        Object dm_tree=null;
        Object name_tree=null;
        Object op_tree=null;
        Object COLON52_tree=null;

        try {
            // RuleSet.g:481:2: (dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start )
            // RuleSet.g:482:2: dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start
            {
            root_0 = (Object)adaptor.nil();

            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_persistent_iterate924); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON52=(Token)match(input,COLON,FOLLOW_COLON_in_persistent_iterate926); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON52_tree = (Object)adaptor.create(COLON52);
            adaptor.addChild(root_0, COLON52_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_persistent_iterate930); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            op=(Token)match(input,COUNTER_OP,FOLLOW_COUNTER_OP_in_persistent_iterate934); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            op_tree = (Object)adaptor.create(op);
            adaptor.addChild(root_0, op_tree);
            }
            pushFollow(FOLLOW_expr_in_persistent_iterate938);
            v=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, v.getTree());
            pushFollow(FOLLOW_counter_start_in_persistent_iterate942);
            from=counter_start();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, from.getTree());
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("action","iterator");
              		tmp.put("name",(name!=null?name.getText():null));
              		tmp.put("domain",(dm!=null?dm.getText():null));
              		tmp.put("type","persistent");
              		tmp.put("op",(op!=null?op.getText():null));
              		tmp.put("from",(from!=null?from.result:null));
              		tmp.put("value",(v!=null?v.result:null));
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "persistent_iterate"

    public static class trail_forget_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "trail_forget"
    // RuleSet.g:494:1: trail_forget returns [HashMap result] : FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR ;
    public final RuleSetParser.trail_forget_return trail_forget() throws RecognitionException {
        RuleSetParser.trail_forget_return retval = new RuleSetParser.trail_forget_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token what=null;
        Token dm=null;
        Token name=null;
        Token FORGET53=null;
        Token COLON55=null;
        RuleSetParser.must_be_return must_be54 = null;


        Object what_tree=null;
        Object dm_tree=null;
        Object name_tree=null;
        Object FORGET53_tree=null;
        Object COLON55_tree=null;

        try {
            // RuleSet.g:495:2: ( FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR )
            // RuleSet.g:496:2: FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR
            {
            root_0 = (Object)adaptor.nil();

            FORGET53=(Token)match(input,FORGET,FOLLOW_FORGET_in_trail_forget959); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FORGET53_tree = (Object)adaptor.create(FORGET53);
            adaptor.addChild(root_0, FORGET53_tree);
            }
            what=(Token)match(input,STRING,FOLLOW_STRING_in_trail_forget964); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            what_tree = (Object)adaptor.create(what);
            adaptor.addChild(root_0, what_tree);
            }
            pushFollow(FOLLOW_must_be_in_trail_forget966);
            must_be54=must_be("in");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be54.getTree());
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_trail_forget972); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON55=(Token)match(input,COLON,FOLLOW_COLON_in_trail_forget974); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON55_tree = (Object)adaptor.create(COLON55);
            adaptor.addChild(root_0, COLON55_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_trail_forget978); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("action","forget");
              		tmp.put("name",(name!=null?name.getText():null));
              		tmp.put("domain",(dm!=null?dm.getText():null));
              		tmp.put("type","persistent");
              		tmp.put("regexp",strip_string((what!=null?what.getText():null)));
              		retval.result = tmp;
              		
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "trail_forget"

    public static class trail_mark_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "trail_mark"
    // RuleSet.g:508:1: trail_mark returns [HashMap result] : MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )? ;
    public final RuleSetParser.trail_mark_return trail_mark() throws RecognitionException {
        RuleSetParser.trail_mark_return retval = new RuleSetParser.trail_mark_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token dm=null;
        Token name=null;
        Token MARK56=null;
        Token COLON57=null;
        RuleSetParser.trail_with_return t = null;


        Object dm_tree=null;
        Object name_tree=null;
        Object MARK56_tree=null;
        Object COLON57_tree=null;

        try {
            // RuleSet.g:509:2: ( MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )? )
            // RuleSet.g:510:2: MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )?
            {
            root_0 = (Object)adaptor.nil();

            MARK56=(Token)match(input,MARK,FOLLOW_MARK_in_trail_mark997); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            MARK56_tree = (Object)adaptor.create(MARK56);
            adaptor.addChild(root_0, MARK56_tree);
            }
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_trail_mark1001); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON57=(Token)match(input,COLON,FOLLOW_COLON_in_trail_mark1003); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON57_tree = (Object)adaptor.create(COLON57);
            adaptor.addChild(root_0, COLON57_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_trail_mark1007); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            // RuleSet.g:510:37: (t= trail_with )?
            int alt32=2;
            int LA32_0 = input.LA(1);

            if ( (LA32_0==WITH) ) {
                alt32=1;
            }
            switch (alt32) {
                case 1 :
                    // RuleSet.g:0:0: t= trail_with
                    {
                    pushFollow(FOLLOW_trail_with_in_trail_mark1011);
                    t=trail_with();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, t.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("action","mark");
              		tmp.put("name",(name!=null?name.getText():null));
              		tmp.put("domain",(dm!=null?dm.getText():null));
              		tmp.put("type","persistent");
              		if((t!=null?input.toString(t.start,t.stop):null) != null)
              			tmp.put("with",(t!=null?t.result:null));
              		retval.result = tmp;		
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "trail_mark"

    public static class trail_with_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "trail_with"
    // RuleSet.g:522:1: trail_with returns [Object result] : WITH e= expr ;
    public final RuleSetParser.trail_with_return trail_with() throws RecognitionException {
        RuleSetParser.trail_with_return retval = new RuleSetParser.trail_with_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITH58=null;
        RuleSetParser.expr_return e = null;


        Object WITH58_tree=null;

        try {
            // RuleSet.g:523:2: ( WITH e= expr )
            // RuleSet.g:524:2: WITH e= expr
            {
            root_0 = (Object)adaptor.nil();

            WITH58=(Token)match(input,WITH,FOLLOW_WITH_in_trail_with1030); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITH58_tree = (Object)adaptor.create(WITH58);
            adaptor.addChild(root_0, WITH58_tree);
            }
            pushFollow(FOLLOW_expr_in_trail_with1034);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {

              		retval.result = (e!=null?e.result:null);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "trail_with"

    public static class counter_start_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "counter_start"
    // RuleSet.g:529:1: counter_start returns [Object result] : must_be[\"from\"] e= expr ;
    public final RuleSetParser.counter_start_return counter_start() throws RecognitionException {
        RuleSetParser.counter_start_return retval = new RuleSetParser.counter_start_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.must_be_return must_be59 = null;



        try {
            // RuleSet.g:530:2: ( must_be[\"from\"] e= expr )
            // RuleSet.g:531:2: must_be[\"from\"] e= expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_counter_start1052);
            must_be59=must_be("from");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be59.getTree());
            pushFollow(FOLLOW_expr_in_counter_start1057);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {

              	 retval.result =e.result;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "counter_start"

    public static class for_clause_return extends ParserRuleReturnScope {
        public String result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "for_clause"
    // RuleSet.g:537:1: for_clause returns [String result] : FOR v= VAR ;
    public final RuleSetParser.for_clause_return for_clause() throws RecognitionException {
        RuleSetParser.for_clause_return retval = new RuleSetParser.for_clause_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token FOR60=null;

        Object v_tree=null;
        Object FOR60_tree=null;

        try {
            // RuleSet.g:538:2: ( FOR v= VAR )
            // RuleSet.g:539:2: FOR v= VAR
            {
            root_0 = (Object)adaptor.nil();

            FOR60=(Token)match(input,FOR,FOLLOW_FOR_in_for_clause1078); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FOR60_tree = (Object)adaptor.create(FOR60);
            adaptor.addChild(root_0, FOR60_tree);
            }
            v=(Token)match(input,VAR,FOLLOW_VAR_in_for_clause1083); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            v_tree = (Object)adaptor.create(v);
            adaptor.addChild(root_0, v_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = (v!=null?v.getText():null);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "for_clause"

    public static class action_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "action"
    // RuleSet.g:553:1: action[HashMap result] : ( conditional_action[result] | unconditional_action[result] ) ( SEMI )? ;
    public final RuleSetParser.action_return action(HashMap result) throws RecognitionException {
        RuleSetParser.action_return retval = new RuleSetParser.action_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token SEMI63=null;
        RuleSetParser.conditional_action_return conditional_action61 = null;

        RuleSetParser.unconditional_action_return unconditional_action62 = null;


        Object SEMI63_tree=null;


        	result.put("blocktype","every");
        	HashMap condt = new HashMap();
        	condt.put("val","true");
        	condt.put("type","bool");
        	result.put("cond",condt);
        	result.put("actions",new ArrayList());

        try {
            // RuleSet.g:562:2: ( ( conditional_action[result] | unconditional_action[result] ) ( SEMI )? )
            // RuleSet.g:563:2: ( conditional_action[result] | unconditional_action[result] ) ( SEMI )?
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:563:2: ( conditional_action[result] | unconditional_action[result] )
            int alt33=2;
            int LA33_0 = input.LA(1);

            if ( (LA33_0==IF) ) {
                alt33=1;
            }
            else if ( (LA33_0==LEFT_CURL||LA33_0==VAR||(LA33_0>=EVERY && LA33_0<=CHOOSE)||(LA33_0>=REPLACE && LA33_0<=OTHER_OPERATORS)||LA33_0==EMIT) ) {
                alt33=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 33, 0, input);

                throw nvae;
            }
            switch (alt33) {
                case 1 :
                    // RuleSet.g:563:3: conditional_action[result]
                    {
                    pushFollow(FOLLOW_conditional_action_in_action1117);
                    conditional_action61=conditional_action(result);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, conditional_action61.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:563:32: unconditional_action[result]
                    {
                    pushFollow(FOLLOW_unconditional_action_in_action1122);
                    unconditional_action62=unconditional_action(result);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, unconditional_action62.getTree());

                    }
                    break;

            }

            // RuleSet.g:563:62: ( SEMI )?
            int alt34=2;
            int LA34_0 = input.LA(1);

            if ( (LA34_0==SEMI) ) {
                int LA34_1 = input.LA(2);

                if ( (synpred43_RuleSet()) ) {
                    alt34=1;
                }
            }
            switch (alt34) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI63=(Token)match(input,SEMI,FOLLOW_SEMI_in_action1126); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI63_tree = (Object)adaptor.create(SEMI63);
                    adaptor.addChild(root_0, SEMI63_tree);
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "action"

    public static class conditional_action_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "conditional_action"
    // RuleSet.g:566:1: conditional_action[HashMap result] : IF e= expr must_be[\"then\"] unconditional_action[result] ;
    public final RuleSetParser.conditional_action_return conditional_action(HashMap result) throws RecognitionException {
        RuleSetParser.conditional_action_return retval = new RuleSetParser.conditional_action_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token IF64=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.must_be_return must_be65 = null;

        RuleSetParser.unconditional_action_return unconditional_action66 = null;


        Object IF64_tree=null;

        try {
            // RuleSet.g:567:2: ( IF e= expr must_be[\"then\"] unconditional_action[result] )
            // RuleSet.g:567:4: IF e= expr must_be[\"then\"] unconditional_action[result]
            {
            root_0 = (Object)adaptor.nil();

            IF64=(Token)match(input,IF,FOLLOW_IF_in_conditional_action1141); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            IF64_tree = (Object)adaptor.create(IF64);
            adaptor.addChild(root_0, IF64_tree);
            }
            pushFollow(FOLLOW_expr_in_conditional_action1145);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_must_be_in_conditional_action1147);
            must_be65=must_be("then");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be65.getTree());
            pushFollow(FOLLOW_unconditional_action_in_conditional_action1150);
            unconditional_action66=unconditional_action(result);

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, unconditional_action66.getTree());
            if ( state.backtracking==0 ) {

              		if((e!=null?input.toString(e.start,e.stop):null) == null)
              		{
              			HashMap tmp = new HashMap();
              			tmp.put("type","bool");
              			tmp.put("val","true");
              			result.put("cond",tmp);
              		}
              		else
              		{
              			result.put("cond",(e!=null?e.result:null));	 
              		}
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "conditional_action"

    public static class unconditional_action_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "unconditional_action"
    // RuleSet.g:582:1: unconditional_action[HashMap result] : (p= primrule | action_block[result] );
    public final RuleSetParser.unconditional_action_return unconditional_action(HashMap result) throws RecognitionException {
        RuleSetParser.unconditional_action_return retval = new RuleSetParser.unconditional_action_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.primrule_return p = null;

        RuleSetParser.action_block_return action_block67 = null;



         
        	ArrayList temp_list = new ArrayList(); 

        try {
            // RuleSet.g:586:2: (p= primrule | action_block[result] )
            int alt35=2;
            int LA35_0 = input.LA(1);

            if ( (LA35_0==VAR||(LA35_0>=REPLACE && LA35_0<=OTHER_OPERATORS)||LA35_0==EMIT) ) {
                alt35=1;
            }
            else if ( (LA35_0==LEFT_CURL||(LA35_0>=EVERY && LA35_0<=CHOOSE)) ) {
                alt35=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 35, 0, input);

                throw nvae;
            }
            switch (alt35) {
                case 1 :
                    // RuleSet.g:586:4: p= primrule
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_primrule_in_unconditional_action1175);
                    p=primrule();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
                    if ( state.backtracking==0 ) {
                      temp_list.add((p!=null?p.result:null)); result.put("actions",temp_list);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:587:6: action_block[result]
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_action_block_in_unconditional_action1185);
                    action_block67=action_block(result);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, action_block67.getTree());

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "unconditional_action"

    public static class action_block_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "action_block"
    // RuleSet.g:589:1: action_block[HashMap result] : (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}' ;
    public final RuleSetParser.action_block_return action_block(HashMap result) throws RecognitionException {
        RuleSetParser.action_block_return retval = new RuleSetParser.action_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token at=null;
        Token char_literal68=null;
        Token char_literal69=null;
        Token char_literal70=null;
        Token char_literal71=null;
        RuleSetParser.primrule_return p = null;


        Object at_tree=null;
        Object char_literal68_tree=null;
        Object char_literal69_tree=null;
        Object char_literal70_tree=null;
        Object char_literal71_tree=null;

         
        	ArrayList temp_list = new ArrayList(); 

        try {
            // RuleSet.g:593:2: ( (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}' )
            // RuleSet.g:593:4: (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}'
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:593:6: (at= ( EVERY | CHOOSE ) )?
            int alt36=2;
            int LA36_0 = input.LA(1);

            if ( ((LA36_0>=EVERY && LA36_0<=CHOOSE)) ) {
                alt36=1;
            }
            switch (alt36) {
                case 1 :
                    // RuleSet.g:0:0: at= ( EVERY | CHOOSE )
                    {
                    at=(Token)input.LT(1);
                    if ( (input.LA(1)>=EVERY && input.LA(1)<=CHOOSE) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(at));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }


                    }
                    break;

            }

            if ( state.backtracking==0 ) {
              result.put("blocktype",(at!=null?at.getText():null)); 
            }
            char_literal68=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_action_block1222); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            char_literal68_tree = (Object)adaptor.create(char_literal68);
            adaptor.addChild(root_0, char_literal68_tree);
            }
            // RuleSet.g:594:7: (p= primrule ( ';' p= primrule )* )
            // RuleSet.g:594:8: p= primrule ( ';' p= primrule )*
            {
            pushFollow(FOLLOW_primrule_in_action_block1227);
            p=primrule();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add((p!=null?p.result:null));
            }
            // RuleSet.g:595:4: ( ';' p= primrule )*
            loop37:
            do {
                int alt37=2;
                int LA37_0 = input.LA(1);

                if ( (LA37_0==SEMI) ) {
                    int LA37_1 = input.LA(2);

                    if ( (LA37_1==VAR||(LA37_1>=REPLACE && LA37_1<=OTHER_OPERATORS)||LA37_1==EMIT) ) {
                        alt37=1;
                    }


                }


                switch (alt37) {
            	case 1 :
            	    // RuleSet.g:595:5: ';' p= primrule
            	    {
            	    char_literal69=(Token)match(input,SEMI,FOLLOW_SEMI_in_action_block1237); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    char_literal69_tree = (Object)adaptor.create(char_literal69);
            	    adaptor.addChild(root_0, char_literal69_tree);
            	    }
            	    pushFollow(FOLLOW_primrule_in_action_block1241);
            	    p=primrule();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
            	    if ( state.backtracking==0 ) {
            	      temp_list.add((p!=null?p.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop37;
                }
            } while (true);


            }

            // RuleSet.g:595:51: ( ';' )?
            int alt38=2;
            int LA38_0 = input.LA(1);

            if ( (LA38_0==SEMI) ) {
                alt38=1;
            }
            switch (alt38) {
                case 1 :
                    // RuleSet.g:0:0: ';'
                    {
                    char_literal70=(Token)match(input,SEMI,FOLLOW_SEMI_in_action_block1248); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal70_tree = (Object)adaptor.create(char_literal70);
                    adaptor.addChild(root_0, char_literal70_tree);
                    }

                    }
                    break;

            }

            char_literal71=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_action_block1251); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            char_literal71_tree = (Object)adaptor.create(char_literal71);
            adaptor.addChild(root_0, char_literal71_tree);
            }
            if ( state.backtracking==0 ) {

              		result.put("actions",temp_list);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "action_block"

    public static class primrule_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "primrule"
    // RuleSet.g:600:1: primrule returns [HashMap result] : (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (m= modifier_clause )? | e= emit_block ) ;
    public final RuleSetParser.primrule_return primrule() throws RecognitionException {
        RuleSetParser.primrule_return retval = new RuleSetParser.primrule_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token label=null;
        Token name=null;
        Token ARROW_RIGHT72=null;
        Token LEFT_PAREN73=null;
        Token COMMA74=null;
        Token COMMA75=null;
        Token RIGHT_PAREN76=null;
        RuleSetParser.namespace_return src = null;

        RuleSetParser.expr_return ex = null;

        RuleSetParser.expr_return ex1 = null;

        RuleSetParser.modifier_clause_return m = null;

        RuleSetParser.emit_block_return e = null;


        Object label_tree=null;
        Object name_tree=null;
        Object ARROW_RIGHT72_tree=null;
        Object LEFT_PAREN73_tree=null;
        Object COMMA74_tree=null;
        Object COMMA75_tree=null;
        Object RIGHT_PAREN76_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:604:2: ( (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (m= modifier_clause )? | e= emit_block ) )
            // RuleSet.g:604:5: (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (m= modifier_clause )? | e= emit_block )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:604:5: (label= VAR ARROW_RIGHT )?
            int alt39=2;
            int LA39_0 = input.LA(1);

            if ( (LA39_0==VAR) ) {
                int LA39_1 = input.LA(2);

                if ( (LA39_1==ARROW_RIGHT) ) {
                    alt39=1;
                }
            }
            switch (alt39) {
                case 1 :
                    // RuleSet.g:604:6: label= VAR ARROW_RIGHT
                    {
                    label=(Token)match(input,VAR,FOLLOW_VAR_in_primrule1278); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    label_tree = (Object)adaptor.create(label);
                    adaptor.addChild(root_0, label_tree);
                    }
                    ARROW_RIGHT72=(Token)match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_primrule1280); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    ARROW_RIGHT72_tree = (Object)adaptor.create(ARROW_RIGHT72);
                    adaptor.addChild(root_0, ARROW_RIGHT72_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:604:30: ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (m= modifier_clause )? | e= emit_block )
            int alt45=2;
            int LA45_0 = input.LA(1);

            if ( (LA45_0==VAR||(LA45_0>=REPLACE && LA45_0<=OTHER_OPERATORS)) ) {
                alt45=1;
            }
            else if ( (LA45_0==EMIT) ) {
                alt45=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 45, 0, input);

                throw nvae;
            }
            switch (alt45) {
                case 1 :
                    // RuleSet.g:605:4: (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (m= modifier_clause )?
                    {
                    // RuleSet.g:605:7: (src= namespace )?
                    int alt40=2;
                    int LA40_0 = input.LA(1);

                    if ( (LA40_0==VAR) ) {
                        int LA40_1 = input.LA(2);

                        if ( (LA40_1==COLON) ) {
                            alt40=1;
                        }
                    }
                    switch (alt40) {
                        case 1 :
                            // RuleSet.g:0:0: src= namespace
                            {
                            pushFollow(FOLLOW_namespace_in_primrule1291);
                            src=namespace();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, src.getTree());

                            }
                            break;

                    }

                    name=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=REPLACE && input.LA(1)<=OTHER_OPERATORS) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(name));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    LEFT_PAREN73=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_primrule1307); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN73_tree = (Object)adaptor.create(LEFT_PAREN73);
                    adaptor.addChild(root_0, LEFT_PAREN73_tree);
                    }
                    // RuleSet.g:605:72: (ex= expr ( COMMA ex1= expr )* )?
                    int alt42=2;
                    int LA42_0 = input.LA(1);

                    if ( (LA42_0==LEFT_CURL||(LA42_0>=VAR && LA42_0<=INT)||(LA42_0>=STRING && LA42_0<=VAR_DOMAIN)||(LA42_0>=REPLACE && LA42_0<=LEFT_PAREN)||LA42_0==NOT||LA42_0==FUNCTION||(LA42_0>=REX && LA42_0<=SEEN)||(LA42_0>=FLOAT && LA42_0<=LEFT_BRACKET)||(LA42_0>=CURRENT && LA42_0<=HISTORY)) ) {
                        alt42=1;
                    }
                    switch (alt42) {
                        case 1 :
                            // RuleSet.g:605:73: ex= expr ( COMMA ex1= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_primrule1312);
                            ex=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, ex.getTree());
                            if ( state.backtracking==0 ) {
                              temp_list.add((ex!=null?ex.result:null));
                            }
                            // RuleSet.g:605:110: ( COMMA ex1= expr )*
                            loop41:
                            do {
                                int alt41=2;
                                int LA41_0 = input.LA(1);

                                if ( (LA41_0==COMMA) ) {
                                    int LA41_1 = input.LA(2);

                                    if ( (LA41_1==LEFT_CURL||(LA41_1>=VAR && LA41_1<=INT)||(LA41_1>=STRING && LA41_1<=VAR_DOMAIN)||(LA41_1>=REPLACE && LA41_1<=LEFT_PAREN)||LA41_1==NOT||LA41_1==FUNCTION||(LA41_1>=REX && LA41_1<=SEEN)||(LA41_1>=FLOAT && LA41_1<=LEFT_BRACKET)||(LA41_1>=CURRENT && LA41_1<=HISTORY)) ) {
                                        alt41=1;
                                    }


                                }


                                switch (alt41) {
                            	case 1 :
                            	    // RuleSet.g:605:111: COMMA ex1= expr
                            	    {
                            	    COMMA74=(Token)match(input,COMMA,FOLLOW_COMMA_in_primrule1317); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA74_tree = (Object)adaptor.create(COMMA74);
                            	    adaptor.addChild(root_0, COMMA74_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_primrule1321);
                            	    ex1=expr();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, ex1.getTree());
                            	    if ( state.backtracking==0 ) {
                            	      temp_list.add((ex1!=null?ex1.result:null));
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop41;
                                }
                            } while (true);


                            }
                            break;

                    }

                    // RuleSet.g:605:160: ( COMMA )?
                    int alt43=2;
                    int LA43_0 = input.LA(1);

                    if ( (LA43_0==COMMA) ) {
                        alt43=1;
                    }
                    switch (alt43) {
                        case 1 :
                            // RuleSet.g:0:0: COMMA
                            {
                            COMMA75=(Token)match(input,COMMA,FOLLOW_COMMA_in_primrule1329); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            COMMA75_tree = (Object)adaptor.create(COMMA75);
                            adaptor.addChild(root_0, COMMA75_tree);
                            }

                            }
                            break;

                    }

                    RIGHT_PAREN76=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_primrule1333); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN76_tree = (Object)adaptor.create(RIGHT_PAREN76);
                    adaptor.addChild(root_0, RIGHT_PAREN76_tree);
                    }
                    // RuleSet.g:605:181: (m= modifier_clause )?
                    int alt44=2;
                    int LA44_0 = input.LA(1);

                    if ( (LA44_0==WITH) ) {
                        alt44=1;
                    }
                    switch (alt44) {
                        case 1 :
                            // RuleSet.g:0:0: m= modifier_clause
                            {
                            pushFollow(FOLLOW_modifier_clause_in_primrule1337);
                            m=modifier_clause();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, m.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		 	
                      		 	HashMap tmp = new HashMap();
                      		 	tmp.put("source",(src!=null?src.result:null));
                      		 	tmp.put("name",(name!=null?name.getText():null));
                      		 	tmp.put("args",temp_list); 
                      		  
                      		 	
                      		 	if((label!=null?label.getText():null) != null) 
                      			 	tmp.put("label",(label!=null?label.getText():null));
                      			 	
                      		 	tmp.put("modifiers",(m!=null?m.result:null));
                      		 	HashMap tmp2 = new HashMap();
                      			tmp2.put("action",tmp); 
                      			if((label!=null?label.getText():null) != null)
                      				tmp2.put("label",(label!=null?label.getText():null));
                      			retval.result = tmp2;
                      		 	
                      		 
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:624:4: e= emit_block
                    {
                    pushFollow(FOLLOW_emit_block_in_primrule1347);
                    e=emit_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    if ( state.backtracking==0 ) {
                       
                      			HashMap tmp = new HashMap();
                      			tmp.put("emit",(e!=null?e.emit_value:null));
                      			retval.result = tmp;
                      		
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "primrule"

    public static class modifier_clause_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "modifier_clause"
    // RuleSet.g:633:1: modifier_clause returns [ArrayList result] : WITH m= modifier ( AND_AND m1= modifier )* ;
    public final RuleSetParser.modifier_clause_return modifier_clause() throws RecognitionException {
        RuleSetParser.modifier_clause_return retval = new RuleSetParser.modifier_clause_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITH77=null;
        Token AND_AND78=null;
        RuleSetParser.modifier_return m = null;

        RuleSetParser.modifier_return m1 = null;


        Object WITH77_tree=null;
        Object AND_AND78_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:637:2: ( WITH m= modifier ( AND_AND m1= modifier )* )
            // RuleSet.g:638:2: WITH m= modifier ( AND_AND m1= modifier )*
            {
            root_0 = (Object)adaptor.nil();

            WITH77=(Token)match(input,WITH,FOLLOW_WITH_in_modifier_clause1379); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITH77_tree = (Object)adaptor.create(WITH77);
            adaptor.addChild(root_0, WITH77_tree);
            }
            pushFollow(FOLLOW_modifier_in_modifier_clause1383);
            m=modifier();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, m.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add((m!=null?m.result:null));
            }
            // RuleSet.g:638:46: ( AND_AND m1= modifier )*
            loop46:
            do {
                int alt46=2;
                int LA46_0 = input.LA(1);

                if ( (LA46_0==AND_AND) ) {
                    alt46=1;
                }


                switch (alt46) {
            	case 1 :
            	    // RuleSet.g:638:47: AND_AND m1= modifier
            	    {
            	    AND_AND78=(Token)match(input,AND_AND,FOLLOW_AND_AND_in_modifier_clause1388); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AND_AND78_tree = (Object)adaptor.create(AND_AND78);
            	    adaptor.addChild(root_0, AND_AND78_tree);
            	    }
            	    pushFollow(FOLLOW_modifier_in_modifier_clause1392);
            	    m1=modifier();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, m1.getTree());
            	    if ( state.backtracking==0 ) {
            	      temp_list.add((m1!=null?m1.result:null));
            	    }

            	    }
            	    break;

            	default :
            	    break loop46;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              		retval.result = temp_list;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "modifier_clause"

    public static class modifier_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "modifier"
    // RuleSet.g:644:1: modifier returns [HashMap result] : name= VAR EQUAL (e= expr | j= JS ) ;
    public final RuleSetParser.modifier_return modifier() throws RecognitionException {
        RuleSetParser.modifier_return retval = new RuleSetParser.modifier_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token name=null;
        Token j=null;
        Token EQUAL79=null;
        RuleSetParser.expr_return e = null;


        Object name_tree=null;
        Object j_tree=null;
        Object EQUAL79_tree=null;

        try {
            // RuleSet.g:645:2: (name= VAR EQUAL (e= expr | j= JS ) )
            // RuleSet.g:645:4: name= VAR EQUAL (e= expr | j= JS )
            {
            root_0 = (Object)adaptor.nil();

            name=(Token)match(input,VAR,FOLLOW_VAR_in_modifier1417); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            EQUAL79=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_modifier1419); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL79_tree = (Object)adaptor.create(EQUAL79);
            adaptor.addChild(root_0, EQUAL79_tree);
            }
            // RuleSet.g:645:18: (e= expr | j= JS )
            int alt47=2;
            int LA47_0 = input.LA(1);

            if ( (LA47_0==LEFT_CURL||(LA47_0>=VAR && LA47_0<=INT)||(LA47_0>=STRING && LA47_0<=VAR_DOMAIN)||(LA47_0>=REPLACE && LA47_0<=LEFT_PAREN)||LA47_0==NOT||LA47_0==FUNCTION||(LA47_0>=REX && LA47_0<=SEEN)||(LA47_0>=FLOAT && LA47_0<=LEFT_BRACKET)||(LA47_0>=CURRENT && LA47_0<=HISTORY)) ) {
                alt47=1;
            }
            else if ( (LA47_0==JS) ) {
                alt47=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 47, 0, input);

                throw nvae;
            }
            switch (alt47) {
                case 1 :
                    // RuleSet.g:645:19: e= expr
                    {
                    pushFollow(FOLLOW_expr_in_modifier1423);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:645:28: j= JS
                    {
                    j=(Token)match(input,JS,FOLLOW_JS_in_modifier1429); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    j_tree = (Object)adaptor.create(j);
                    adaptor.addChild(root_0, j_tree);
                    }

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp2 = new HashMap();
              		
              		HashMap tmp = new HashMap();
              		if((e!=null?input.toString(e.start,e.stop):null) != null)
              		{
              			tmp2.put("value",(e!=null?e.result:null));
              		}
              		else
              		{
              			tmp.put("type","JS");
              			tmp.put("val",strip_wrappers("<|","|>",(j!=null?j.getText():null)));		
              			tmp2.put("value",tmp);
              		}

              		tmp2.put("name",(name!=null?name.getText():null));
              		retval.result = tmp2; 
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "modifier"

    public static class using_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "using"
    // RuleSet.g:671:1: using returns [HashMap result] : USING (p= STRING | r= regex ) (s= setting )? ;
    public final RuleSetParser.using_return using() throws RecognitionException {
        RuleSetParser.using_return retval = new RuleSetParser.using_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token p=null;
        Token USING80=null;
        RuleSetParser.regex_return r = null;

        RuleSetParser.setting_return s = null;


        Object p_tree=null;
        Object USING80_tree=null;

        try {
            // RuleSet.g:672:2: ( USING (p= STRING | r= regex ) (s= setting )? )
            // RuleSet.g:672:4: USING (p= STRING | r= regex ) (s= setting )?
            {
            root_0 = (Object)adaptor.nil();

            USING80=(Token)match(input,USING,FOLLOW_USING_in_using1453); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            USING80_tree = (Object)adaptor.create(USING80);
            adaptor.addChild(root_0, USING80_tree);
            }
            // RuleSet.g:672:10: (p= STRING | r= regex )
            int alt48=2;
            int LA48_0 = input.LA(1);

            if ( (LA48_0==STRING) ) {
                alt48=1;
            }
            else if ( (LA48_0==REX) ) {
                alt48=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 48, 0, input);

                throw nvae;
            }
            switch (alt48) {
                case 1 :
                    // RuleSet.g:672:11: p= STRING
                    {
                    p=(Token)match(input,STRING,FOLLOW_STRING_in_using1458); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    p_tree = (Object)adaptor.create(p);
                    adaptor.addChild(root_0, p_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:672:20: r= regex
                    {
                    pushFollow(FOLLOW_regex_in_using1462);
                    r=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, r.getTree());

                    }
                    break;

            }

            // RuleSet.g:672:30: (s= setting )?
            int alt49=2;
            int LA49_0 = input.LA(1);

            if ( (LA49_0==SETTING) ) {
                alt49=1;
            }
            switch (alt49) {
                case 1 :
                    // RuleSet.g:0:0: s= setting
                    {
                    pushFollow(FOLLOW_setting_in_using1467);
                    s=setting();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, s.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              			HashMap tmp = new HashMap();
              			HashMap evt_expr = new HashMap();
              			if((p!=null?p.getText():null) != null)
              				evt_expr.put("pattern",strip_string((p!=null?p.getText():null)));
              			else
              				evt_expr.put("pattern",(r!=null?r.result:null));
              			
              			evt_expr.put("legacy",1);
              			evt_expr.put("type","prim_event");
              			evt_expr.put("op","pageview");
              			
              			if((s!=null?input.toString(s.start,s.stop):null) != null)
              				evt_expr.put("vars",(s!=null?s.result:null));	
              			
              			tmp.put("event_expr",evt_expr);
              			tmp.put("foreach",new ArrayList());
              			retval.result =tmp;
              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "using"

    public static class setting_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "setting"
    // RuleSet.g:692:1: setting returns [ArrayList result] : SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN ;
    public final RuleSetParser.setting_return setting() throws RecognitionException {
        RuleSetParser.setting_return retval = new RuleSetParser.setting_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token v2=null;
        Token SETTING81=null;
        Token LEFT_PAREN82=null;
        Token COMMA83=null;
        Token RIGHT_PAREN84=null;

        Object v_tree=null;
        Object v2_tree=null;
        Object SETTING81_tree=null;
        Object LEFT_PAREN82_tree=null;
        Object COMMA83_tree=null;
        Object RIGHT_PAREN84_tree=null;


        	ArrayList sresult = new ArrayList();

        try {
            // RuleSet.g:696:2: ( SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN )
            // RuleSet.g:696:4: SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN
            {
            root_0 = (Object)adaptor.nil();

            SETTING81=(Token)match(input,SETTING,FOLLOW_SETTING_in_setting1488); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            SETTING81_tree = (Object)adaptor.create(SETTING81);
            adaptor.addChild(root_0, SETTING81_tree);
            }
            LEFT_PAREN82=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_setting1490); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_PAREN82_tree = (Object)adaptor.create(LEFT_PAREN82);
            adaptor.addChild(root_0, LEFT_PAREN82_tree);
            }
            // RuleSet.g:696:23: (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )* )?
            int alt51=2;
            int LA51_0 = input.LA(1);

            if ( (LA51_0==VAR||(LA51_0>=REPLACE && LA51_0<=OTHER_OPERATORS)) ) {
                alt51=1;
            }
            switch (alt51) {
                case 1 :
                    // RuleSet.g:696:24: v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )*
                    {
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=REPLACE && input.LA(1)<=OTHER_OPERATORS) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    if ( state.backtracking==0 ) {
                      sresult.add((v!=null?v.getText():null));
                    }
                    // RuleSet.g:696:85: ( COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )*
                    loop50:
                    do {
                        int alt50=2;
                        int LA50_0 = input.LA(1);

                        if ( (LA50_0==COMMA) ) {
                            alt50=1;
                        }


                        switch (alt50) {
                    	case 1 :
                    	    // RuleSet.g:696:86: COMMA v2= ( VAR | OTHER_OPERATORS | REPLACE | MATCH )
                    	    {
                    	    COMMA83=(Token)match(input,COMMA,FOLLOW_COMMA_in_setting1507); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    COMMA83_tree = (Object)adaptor.create(COMMA83);
                    	    adaptor.addChild(root_0, COMMA83_tree);
                    	    }
                    	    v2=(Token)input.LT(1);
                    	    if ( input.LA(1)==VAR||(input.LA(1)>=REPLACE && input.LA(1)<=OTHER_OPERATORS) ) {
                    	        input.consume();
                    	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v2));
                    	        state.errorRecovery=false;state.failed=false;
                    	    }
                    	    else {
                    	        if (state.backtracking>0) {state.failed=true; return retval;}
                    	        MismatchedSetException mse = new MismatchedSetException(null,input);
                    	        throw mse;
                    	    }

                    	    if ( state.backtracking==0 ) {
                    	      sresult.add((v2!=null?v2.getText():null));
                    	    }

                    	    }
                    	    break;

                    	default :
                    	    break loop50;
                        }
                    } while (true);


                    }
                    break;

            }

            RIGHT_PAREN84=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_setting1527); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_PAREN84_tree = (Object)adaptor.create(RIGHT_PAREN84);
            adaptor.addChild(root_0, RIGHT_PAREN84_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = sresult;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "setting"

    public static class pre_block_return extends ParserRuleReturnScope {
        public ArrayList result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "pre_block"
    // RuleSet.g:702:1: pre_block returns [ArrayList result] : PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.pre_block_return pre_block() throws RecognitionException {
        RuleSetParser.pre_block_return retval = new RuleSetParser.pre_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token PRE85=null;
        Token LEFT_CURL86=null;
        Token SEMI88=null;
        Token SEMI90=null;
        Token RIGHT_CURL91=null;
        RuleSetParser.decl_return decl87 = null;

        RuleSetParser.decl_return decl89 = null;


        Object PRE85_tree=null;
        Object LEFT_CURL86_tree=null;
        Object SEMI88_tree=null;
        Object SEMI90_tree=null;
        Object RIGHT_CURL91_tree=null;


        	ArrayList tmp = new ArrayList();

        try {
            // RuleSet.g:705:3: ( PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:706:3: PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            PRE85=(Token)match(input,PRE,FOLLOW_PRE_in_pre_block1552); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            PRE85_tree = (Object)adaptor.create(PRE85);
            adaptor.addChild(root_0, PRE85_tree);
            }
            LEFT_CURL86=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_pre_block1554); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL86_tree = (Object)adaptor.create(LEFT_CURL86);
            adaptor.addChild(root_0, LEFT_CURL86_tree);
            }
            // RuleSet.g:706:17: ( decl[tmp] ( SEMI decl[tmp] )* )?
            int alt53=2;
            int LA53_0 = input.LA(1);

            if ( (LA53_0==VAR) ) {
                alt53=1;
            }
            switch (alt53) {
                case 1 :
                    // RuleSet.g:706:19: decl[tmp] ( SEMI decl[tmp] )*
                    {
                    pushFollow(FOLLOW_decl_in_pre_block1558);
                    decl87=decl(tmp);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl87.getTree());
                    // RuleSet.g:706:29: ( SEMI decl[tmp] )*
                    loop52:
                    do {
                        int alt52=2;
                        int LA52_0 = input.LA(1);

                        if ( (LA52_0==SEMI) ) {
                            int LA52_1 = input.LA(2);

                            if ( (LA52_1==VAR) ) {
                                alt52=1;
                            }


                        }


                        switch (alt52) {
                    	case 1 :
                    	    // RuleSet.g:706:30: SEMI decl[tmp]
                    	    {
                    	    SEMI88=(Token)match(input,SEMI,FOLLOW_SEMI_in_pre_block1562); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    SEMI88_tree = (Object)adaptor.create(SEMI88);
                    	    adaptor.addChild(root_0, SEMI88_tree);
                    	    }
                    	    pushFollow(FOLLOW_decl_in_pre_block1564);
                    	    decl89=decl(tmp);

                    	    state._fsp--;
                    	    if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl89.getTree());

                    	    }
                    	    break;

                    	default :
                    	    break loop52;
                        }
                    } while (true);


                    }
                    break;

            }

            // RuleSet.g:706:50: ( SEMI )?
            int alt54=2;
            int LA54_0 = input.LA(1);

            if ( (LA54_0==SEMI) ) {
                alt54=1;
            }
            switch (alt54) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI90=(Token)match(input,SEMI,FOLLOW_SEMI_in_pre_block1572); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI90_tree = (Object)adaptor.create(SEMI90);
                    adaptor.addChild(root_0, SEMI90_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL91=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_pre_block1575); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL91_tree = (Object)adaptor.create(RIGHT_CURL91);
            adaptor.addChild(root_0, RIGHT_CURL91_tree);
            }
            if ( state.backtracking==0 ) {

              	 	retval.result = tmp;
              	 
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "pre_block"

    public static class foreach_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "foreach"
    // RuleSet.g:711:1: foreach returns [HashMap result] : FOREACH e= expr s= setting ;
    public final RuleSetParser.foreach_return foreach() throws RecognitionException {
        RuleSetParser.foreach_return retval = new RuleSetParser.foreach_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token FOREACH92=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.setting_return s = null;


        Object FOREACH92_tree=null;

        try {
            // RuleSet.g:712:2: ( FOREACH e= expr s= setting )
            // RuleSet.g:713:2: FOREACH e= expr s= setting
            {
            root_0 = (Object)adaptor.nil();

            FOREACH92=(Token)match(input,FOREACH,FOLLOW_FOREACH_in_foreach1596); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FOREACH92_tree = (Object)adaptor.create(FOREACH92);
            adaptor.addChild(root_0, FOREACH92_tree);
            }
            pushFollow(FOLLOW_expr_in_foreach1600);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_setting_in_foreach1604);
            s=setting();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, s.getTree());
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("expr",e.result);
              		tmp.put("var",s.result);
              		retval.result = tmp;	
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "foreach"

    public static class when_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "when"
    // RuleSet.g:720:1: when returns [HashMap result] : WHEN es= event_seq ;
    public final RuleSetParser.when_return when() throws RecognitionException {
        RuleSetParser.when_return retval = new RuleSetParser.when_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WHEN93=null;
        RuleSetParser.event_seq_return es = null;


        Object WHEN93_tree=null;



        try {
            // RuleSet.g:723:2: ( WHEN es= event_seq )
            // RuleSet.g:724:2: WHEN es= event_seq
            {
            root_0 = (Object)adaptor.nil();

            WHEN93=(Token)match(input,WHEN,FOLLOW_WHEN_in_when1637); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WHEN93_tree = (Object)adaptor.create(WHEN93);
            adaptor.addChild(root_0, WHEN93_tree);
            }
            pushFollow(FOLLOW_event_seq_in_when1641);
            es=event_seq();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, es.getTree());
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("foreach",new ArrayList());
              		tmp.put("event_expr",(es!=null?es.result:null));
              		retval.result = tmp;		
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "when"

    public static class event_seq_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_seq"
    // RuleSet.g:733:1: event_seq returns [HashMap result] : eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )* ;
    public final RuleSetParser.event_seq_return event_seq() throws RecognitionException {
        RuleSetParser.event_seq_return retval = new RuleSetParser.event_seq_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.event_or_return eor = null;

        RuleSetParser.must_be_one_return tb = null;

        RuleSetParser.event_or_return eor2 = null;




        	ArrayList temp_list = new ArrayList();
        	ArrayList temp_list_2 = new ArrayList();

        try {
            // RuleSet.g:738:2: (eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )* )
            // RuleSet.g:739:3: eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_or_in_event_seq1668);
            eor=event_or();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, eor.getTree());
            // RuleSet.g:739:16: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*
            loop55:
            do {
                int alt55=2;
                alt55 = dfa55.predict(input);
                switch (alt55) {
            	case 1 :
            	    // RuleSet.g:739:17: tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_event_seq1673);
            	    tb=must_be_one(sar("then","before"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, tb.getTree());
            	    pushFollow(FOLLOW_event_or_in_event_seq1678);
            	    eor2=event_or();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, eor2.getTree());
            	    if ( state.backtracking==0 ) {
            	       temp_list_2.add((tb!=null?input.toString(tb.start,tb.stop):null));temp_list.add(eor2);
            	    }

            	    }
            	    break;

            	default :
            	    break loop55;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              			if(temp_list.size() == 0)
              			{ 
              				retval.result = eor.result; 
              			}
              			else 
              			{
              				HashMap the_result = new HashMap();
              				the_result.put("type","complex_event");
              				the_result.put("op",temp_list_2.get(0).toString());
              				the_result.put("args",new ArrayList());
              				((ArrayList)the_result.get("args")).add(eor.result);
              				HashMap last = the_result;
              				
              				for(int i = 0; i <temp_list.size(); i++)
              				{				
              					HashMap rtmp = ((event_or_return)temp_list.get(i)).result;
              					if(i == temp_list.size() - 1)
              					{
              						((ArrayList)last.get("args")).add(rtmp);						
              					}
              					else
              					{	
              						HashMap tmp = new HashMap();
              						tmp.put("type","complex_event");
              						tmp.put("op",temp_list_2.get(i+1).toString());
              						tmp.put("args",new ArrayList());
              						((ArrayList)tmp.get("args")).add(rtmp);
              						((ArrayList)last.get("args")).add(tmp);
              						last = 	tmp;
              					}
              				}
              				
              				retval.result = the_result;
              				
              			}


              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_seq"

    public static class event_or_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_or"
    // RuleSet.g:784:1: event_or returns [HashMap result] : ea= event_and ( OR_OR ea1= event_and )* ;
    public final RuleSetParser.event_or_return event_or() throws RecognitionException {
        RuleSetParser.event_or_return retval = new RuleSetParser.event_or_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token OR_OR94=null;
        RuleSetParser.event_and_return ea = null;

        RuleSetParser.event_and_return ea1 = null;


        Object OR_OR94_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:788:2: (ea= event_and ( OR_OR ea1= event_and )* )
            // RuleSet.g:789:3: ea= event_and ( OR_OR ea1= event_and )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_and_in_event_or1719);
            ea=event_and();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ea.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add(ea);
            }
            // RuleSet.g:789:37: ( OR_OR ea1= event_and )*
            loop56:
            do {
                int alt56=2;
                int LA56_0 = input.LA(1);

                if ( (LA56_0==OR_OR) ) {
                    alt56=1;
                }


                switch (alt56) {
            	case 1 :
            	    // RuleSet.g:789:38: OR_OR ea1= event_and
            	    {
            	    OR_OR94=(Token)match(input,OR_OR,FOLLOW_OR_OR_in_event_or1724); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    OR_OR94_tree = (Object)adaptor.create(OR_OR94);
            	    adaptor.addChild(root_0, OR_OR94_tree);
            	    }
            	    pushFollow(FOLLOW_event_and_in_event_or1728);
            	    ea1=event_and();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, ea1.getTree());
            	    if ( state.backtracking==0 ) {
            	       temp_list.add(ea1);
            	    }

            	    }
            	    break;

            	default :
            	    break loop56;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              			if(temp_list.size() == 1)
              			{ 
              				retval.result = ((event_and_return)temp_list.get(0)).result;
              			}
              			else
              			{
              				HashMap the_result = new HashMap();
              				the_result.put("type","complex_event");
              				the_result.put("op","or");
              				the_result.put("args",new ArrayList());
              				((ArrayList)the_result.get("args")).add(ea.result);
              				HashMap last = the_result;
              				

              				for(int i = 1; i <temp_list.size(); i++)
              				{				
              					HashMap rtmp = ((event_and_return)temp_list.get(i)).result;
              					if(i == temp_list.size() - 1)
              					{
              						((ArrayList)last.get("args")).add(rtmp);						
              					}
              					else
              					{	
              						HashMap tmp = new HashMap();
              						tmp.put("type","complex_event");
              						tmp.put("op","or");
              						tmp.put("args",new ArrayList());
              						((ArrayList)tmp.get("args")).add(rtmp);
              						((ArrayList)last.get("args")).add(tmp);
              						last = 	tmp;
              					}
              				}
              				
              				retval.result = the_result;
              				
              			}

              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_or"

    public static class event_and_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_and"
    // RuleSet.g:829:1: event_and returns [HashMap result] : e= event_btwn ( AND_AND e1= event_btwn )* ;
    public final RuleSetParser.event_and_return event_and() throws RecognitionException {
        RuleSetParser.event_and_return retval = new RuleSetParser.event_and_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token AND_AND95=null;
        RuleSetParser.event_btwn_return e = null;

        RuleSetParser.event_btwn_return e1 = null;


        Object AND_AND95_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:833:2: (e= event_btwn ( AND_AND e1= event_btwn )* )
            // RuleSet.g:834:3: e= event_btwn ( AND_AND e1= event_btwn )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_btwn_in_event_and1757);
            e=event_btwn();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add(e);
            }
            // RuleSet.g:834:36: ( AND_AND e1= event_btwn )*
            loop57:
            do {
                int alt57=2;
                int LA57_0 = input.LA(1);

                if ( (LA57_0==AND_AND) ) {
                    alt57=1;
                }


                switch (alt57) {
            	case 1 :
            	    // RuleSet.g:834:37: AND_AND e1= event_btwn
            	    {
            	    AND_AND95=(Token)match(input,AND_AND,FOLLOW_AND_AND_in_event_and1762); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AND_AND95_tree = (Object)adaptor.create(AND_AND95);
            	    adaptor.addChild(root_0, AND_AND95_tree);
            	    }
            	    pushFollow(FOLLOW_event_btwn_in_event_and1766);
            	    e1=event_btwn();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
            	    if ( state.backtracking==0 ) {
            	       temp_list.add(e1);
            	    }

            	    }
            	    break;

            	default :
            	    break loop57;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              			
              			if(temp_list.size() == 1)
              			{ 
              				retval.result = ((event_btwn_return)temp_list.get(0)).result;
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
              				
              				retval.result = the_result;
              				
              			}
              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_and"

    public static class event_btwn_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_btwn"
    // RuleSet.g:875:1: event_btwn returns [HashMap result] : ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )? ;
    public final RuleSetParser.event_btwn_return event_btwn() throws RecognitionException {
        RuleSetParser.event_btwn_return retval = new RuleSetParser.event_btwn_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token not=null;
        Token BETWEEN96=null;
        Token LEFT_PAREN97=null;
        Token COMMA98=null;
        Token RIGHT_PAREN99=null;
        RuleSetParser.event_prim_return ep = null;

        RuleSetParser.event_seq_return es1 = null;

        RuleSetParser.event_seq_return es2 = null;


        Object not_tree=null;
        Object BETWEEN96_tree=null;
        Object LEFT_PAREN97_tree=null;
        Object COMMA98_tree=null;
        Object RIGHT_PAREN99_tree=null;

        try {
            // RuleSet.g:876:2: (ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )? )
            // RuleSet.g:877:3: ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_prim_in_event_btwn1792);
            ep=event_prim();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ep.getTree());
            // RuleSet.g:877:17: ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )?
            int alt59=2;
            int LA59_0 = input.LA(1);

            if ( ((LA59_0>=NOT && LA59_0<=BETWEEN)) ) {
                alt59=1;
            }
            switch (alt59) {
                case 1 :
                    // RuleSet.g:877:18: (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN
                    {
                    // RuleSet.g:877:18: (not= NOT )?
                    int alt58=2;
                    int LA58_0 = input.LA(1);

                    if ( (LA58_0==NOT) ) {
                        alt58=1;
                    }
                    switch (alt58) {
                        case 1 :
                            // RuleSet.g:877:19: not= NOT
                            {
                            not=(Token)match(input,NOT,FOLLOW_NOT_in_event_btwn1798); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            not_tree = (Object)adaptor.create(not);
                            adaptor.addChild(root_0, not_tree);
                            }

                            }
                            break;

                    }

                    BETWEEN96=(Token)match(input,BETWEEN,FOLLOW_BETWEEN_in_event_btwn1803); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    BETWEEN96_tree = (Object)adaptor.create(BETWEEN96);
                    adaptor.addChild(root_0, BETWEEN96_tree);
                    }
                    LEFT_PAREN97=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_event_btwn1805); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN97_tree = (Object)adaptor.create(LEFT_PAREN97);
                    adaptor.addChild(root_0, LEFT_PAREN97_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_btwn1809);
                    es1=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, es1.getTree());
                    COMMA98=(Token)match(input,COMMA,FOLLOW_COMMA_in_event_btwn1811); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COMMA98_tree = (Object)adaptor.create(COMMA98);
                    adaptor.addChild(root_0, COMMA98_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_btwn1815);
                    es2=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, es2.getTree());
                    RIGHT_PAREN99=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_event_btwn1817); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN99_tree = (Object)adaptor.create(RIGHT_PAREN99);
                    adaptor.addChild(root_0, RIGHT_PAREN99_tree);
                    }

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		
              		
              			if((es1!=null?input.toString(es1.start,es1.stop):null) == null)
              			{ 
              				retval.result = ep.result;
              			}
              			else
              			{
              				HashMap the_result = new HashMap();
              				the_result.put("type","complex_event");
              				if((not!=null?not.getText():null) != null)
              					the_result.put("op","notbetween");
              				else
              					the_result.put("op","between");
              				the_result.put("first",es1.result);
              				the_result.put("last",es2.result);
              				the_result.put("mid",ep.result);
              				retval.result = the_result;
              				
              			}		
              		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_btwn"

    public static class event_prim_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_prim"
    // RuleSet.g:901:1: event_prim returns [HashMap result] : ( ( WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )? | ( WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )? | dom= VAR oper= VAR (filter= event_filter )* (set= setting )? | '(' evt= event_seq ')' );
    public final RuleSetParser.event_prim_return event_prim() throws RecognitionException {
        RuleSetParser.event_prim_return retval = new RuleSetParser.event_prim_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token spat=null;
        Token elem=null;
        Token dom=null;
        Token oper=null;
        Token WEB100=null;
        Token PAGEVIEW101=null;
        Token WEB102=null;
        Token char_literal103=null;
        Token char_literal104=null;
        RuleSetParser.regex_return rpat = null;

        RuleSetParser.setting_return set = null;

        RuleSetParser.must_be_one_return opt = null;

        RuleSetParser.on_expr_return on = null;

        RuleSetParser.event_filter_return filter = null;

        RuleSetParser.event_seq_return evt = null;


        Object spat_tree=null;
        Object elem_tree=null;
        Object dom_tree=null;
        Object oper_tree=null;
        Object WEB100_tree=null;
        Object PAGEVIEW101_tree=null;
        Object WEB102_tree=null;
        Object char_literal103_tree=null;
        Object char_literal104_tree=null;


        	ArrayList filters = new ArrayList();

        try {
            // RuleSet.g:905:2: ( ( WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )? | ( WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )? | dom= VAR oper= VAR (filter= event_filter )* (set= setting )? | '(' evt= event_seq ')' )
            int alt68=4;
            switch ( input.LA(1) ) {
            case WEB:
                {
                int LA68_1 = input.LA(2);

                if ( (LA68_1==VAR) ) {
                    alt68=2;
                }
                else if ( (LA68_1==PAGEVIEW) ) {
                    alt68=1;
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return retval;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 68, 1, input);

                    throw nvae;
                }
                }
                break;
            case PAGEVIEW:
                {
                alt68=1;
                }
                break;
            case VAR:
                {
                int LA68_3 = input.LA(2);

                if ( (LA68_3==VAR) ) {
                    alt68=3;
                }
                else if ( (LA68_3==STRING) ) {
                    alt68=2;
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return retval;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 68, 3, input);

                    throw nvae;
                }
                }
                break;
            case LEFT_PAREN:
                {
                alt68=4;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 68, 0, input);

                throw nvae;
            }

            switch (alt68) {
                case 1 :
                    // RuleSet.g:906:2: ( WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )?
                    {
                    root_0 = (Object)adaptor.nil();

                    // RuleSet.g:906:2: ( WEB )?
                    int alt60=2;
                    int LA60_0 = input.LA(1);

                    if ( (LA60_0==WEB) ) {
                        alt60=1;
                    }
                    switch (alt60) {
                        case 1 :
                            // RuleSet.g:0:0: WEB
                            {
                            WEB100=(Token)match(input,WEB,FOLLOW_WEB_in_event_prim1845); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            WEB100_tree = (Object)adaptor.create(WEB100);
                            adaptor.addChild(root_0, WEB100_tree);
                            }

                            }
                            break;

                    }

                    PAGEVIEW101=(Token)match(input,PAGEVIEW,FOLLOW_PAGEVIEW_in_event_prim1848); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    PAGEVIEW101_tree = (Object)adaptor.create(PAGEVIEW101);
                    adaptor.addChild(root_0, PAGEVIEW101_tree);
                    }
                    // RuleSet.g:906:16: (spat= STRING | rpat= regex )
                    int alt61=2;
                    int LA61_0 = input.LA(1);

                    if ( (LA61_0==STRING) ) {
                        alt61=1;
                    }
                    else if ( (LA61_0==REX) ) {
                        alt61=2;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        NoViableAltException nvae =
                            new NoViableAltException("", 61, 0, input);

                        throw nvae;
                    }
                    switch (alt61) {
                        case 1 :
                            // RuleSet.g:906:17: spat= STRING
                            {
                            spat=(Token)match(input,STRING,FOLLOW_STRING_in_event_prim1853); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            spat_tree = (Object)adaptor.create(spat);
                            adaptor.addChild(root_0, spat_tree);
                            }

                            }
                            break;
                        case 2 :
                            // RuleSet.g:906:29: rpat= regex
                            {
                            pushFollow(FOLLOW_regex_in_event_prim1857);
                            rpat=regex();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, rpat.getTree());

                            }
                            break;

                    }

                    // RuleSet.g:906:44: (set= setting )?
                    int alt62=2;
                    int LA62_0 = input.LA(1);

                    if ( (LA62_0==SETTING) ) {
                        alt62=1;
                    }
                    switch (alt62) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_event_prim1862);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		HashMap tmp = new HashMap();
                      		tmp.put("domain","web");
                      		if((spat!=null?spat.getText():null) != null)
                      			tmp.put("pattern",strip_string((spat!=null?spat.getText():null)));
                      		else
                      			tmp.put("pattern",(rpat!=null?rpat.result:null));
                      		tmp.put("type","prim_event");
                      		tmp.put("vars",(set!=null?set.result:null));
                      		tmp.put("op","pageview");
                      		retval.result = tmp;			
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:918:4: ( WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )?
                    {
                    root_0 = (Object)adaptor.nil();

                    // RuleSet.g:918:4: ( WEB )?
                    int alt63=2;
                    int LA63_0 = input.LA(1);

                    if ( (LA63_0==WEB) ) {
                        alt63=1;
                    }
                    switch (alt63) {
                        case 1 :
                            // RuleSet.g:0:0: WEB
                            {
                            WEB102=(Token)match(input,WEB,FOLLOW_WEB_in_event_prim1871); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            WEB102_tree = (Object)adaptor.create(WEB102);
                            adaptor.addChild(root_0, WEB102_tree);
                            }

                            }
                            break;

                    }

                    pushFollow(FOLLOW_must_be_one_in_event_prim1876);
                    opt=must_be_one(sar("submit","click","dblclick","change","update"));

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, opt.getTree());
                    elem=(Token)match(input,STRING,FOLLOW_STRING_in_event_prim1881); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    elem_tree = (Object)adaptor.create(elem);
                    adaptor.addChild(root_0, elem_tree);
                    }
                    // RuleSet.g:918:91: (on= on_expr )?
                    int alt64=2;
                    int LA64_0 = input.LA(1);

                    if ( (LA64_0==ON) ) {
                        alt64=1;
                    }
                    switch (alt64) {
                        case 1 :
                            // RuleSet.g:0:0: on= on_expr
                            {
                            pushFollow(FOLLOW_on_expr_in_event_prim1885);
                            on=on_expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, on.getTree());

                            }
                            break;

                    }

                    // RuleSet.g:918:105: (set= setting )?
                    int alt65=2;
                    int LA65_0 = input.LA(1);

                    if ( (LA65_0==SETTING) ) {
                        alt65=1;
                    }
                    switch (alt65) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_event_prim1891);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		HashMap tmp = new HashMap();
                      		tmp.put("domain","web");
                      		tmp.put("element",strip_string((elem!=null?elem.getText():null)));
                      		tmp.put("type","prim_event"); 
                      		tmp.put("vars",(set!=null?set.result:null));
                      		tmp.put("op",(opt!=null?input.toString(opt.start,opt.stop):null));
                      		tmp.put("on",(on!=null?on.result:null));
                      		retval.result = tmp;			
                      	
                      	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:929:4: dom= VAR oper= VAR (filter= event_filter )* (set= setting )?
                    {
                    root_0 = (Object)adaptor.nil();

                    dom=(Token)match(input,VAR,FOLLOW_VAR_in_event_prim1901); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    dom_tree = (Object)adaptor.create(dom);
                    adaptor.addChild(root_0, dom_tree);
                    }
                    oper=(Token)match(input,VAR,FOLLOW_VAR_in_event_prim1905); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    oper_tree = (Object)adaptor.create(oper);
                    adaptor.addChild(root_0, oper_tree);
                    }
                    // RuleSet.g:929:21: (filter= event_filter )*
                    loop66:
                    do {
                        int alt66=2;
                        int LA66_0 = input.LA(1);

                        if ( (LA66_0==VAR) ) {
                            int LA66_2 = input.LA(2);

                            if ( (LA66_2==STRING||LA66_2==REX) ) {
                                alt66=1;
                            }


                        }


                        switch (alt66) {
                    	case 1 :
                    	    // RuleSet.g:929:22: filter= event_filter
                    	    {
                    	    pushFollow(FOLLOW_event_filter_in_event_prim1910);
                    	    filter=event_filter();

                    	    state._fsp--;
                    	    if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, filter.getTree());
                    	    if ( state.backtracking==0 ) {
                    	      filters.add((filter!=null?filter.result:null));
                    	    }

                    	    }
                    	    break;

                    	default :
                    	    break loop66;
                        }
                    } while (true);

                    // RuleSet.g:929:77: (set= setting )?
                    int alt67=2;
                    int LA67_0 = input.LA(1);

                    if ( (LA67_0==SETTING) ) {
                        alt67=1;
                    }
                    switch (alt67) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_event_prim1917);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		HashMap tmp = new HashMap();
                      		tmp.put("domain",(dom!=null?dom.getText():null));
                      		tmp.put("type","prim_event");
                      			tmp.put("vars",(set!=null?set.result:null));
                      		tmp.put("op",(oper!=null?oper.getText():null));

                      		tmp.put("filters",filters);
                      		retval.result = tmp;			
                      	
                      	
                    }

                    }
                    break;
                case 4 :
                    // RuleSet.g:940:4: '(' evt= event_seq ')'
                    {
                    root_0 = (Object)adaptor.nil();

                    char_literal103=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_event_prim1927); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal103_tree = (Object)adaptor.create(char_literal103);
                    adaptor.addChild(root_0, char_literal103_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_prim1931);
                    evt=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, evt.getTree());
                    char_literal104=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_event_prim1933); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal104_tree = (Object)adaptor.create(char_literal104);
                    adaptor.addChild(root_0, char_literal104_tree);
                    }
                    if ( state.backtracking==0 ) {

                      		retval.result =(evt!=null?evt.result:null);
                      	
                    }

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_prim"

    public static class event_filter_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_filter"
    // RuleSet.g:946:1: event_filter returns [HashMap result] : typ= VAR (sfilt= STRING | rfilt= regex ) ;
    public final RuleSetParser.event_filter_return event_filter() throws RecognitionException {
        RuleSetParser.event_filter_return retval = new RuleSetParser.event_filter_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token typ=null;
        Token sfilt=null;
        RuleSetParser.regex_return rfilt = null;


        Object typ_tree=null;
        Object sfilt_tree=null;

        try {
            // RuleSet.g:947:2: (typ= VAR (sfilt= STRING | rfilt= regex ) )
            // RuleSet.g:947:4: typ= VAR (sfilt= STRING | rfilt= regex )
            {
            root_0 = (Object)adaptor.nil();

            typ=(Token)match(input,VAR,FOLLOW_VAR_in_event_filter1952); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            typ_tree = (Object)adaptor.create(typ);
            adaptor.addChild(root_0, typ_tree);
            }
            // RuleSet.g:947:12: (sfilt= STRING | rfilt= regex )
            int alt69=2;
            int LA69_0 = input.LA(1);

            if ( (LA69_0==STRING) ) {
                alt69=1;
            }
            else if ( (LA69_0==REX) ) {
                alt69=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 69, 0, input);

                throw nvae;
            }
            switch (alt69) {
                case 1 :
                    // RuleSet.g:947:13: sfilt= STRING
                    {
                    sfilt=(Token)match(input,STRING,FOLLOW_STRING_in_event_filter1957); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    sfilt_tree = (Object)adaptor.create(sfilt);
                    adaptor.addChild(root_0, sfilt_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:947:28: rfilt= regex
                    {
                    pushFollow(FOLLOW_regex_in_event_filter1963);
                    rfilt=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, rfilt.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("type",(typ!=null?typ.getText():null));
              		if((sfilt!=null?sfilt.getText():null) != null)
              			tmp.put("pattern",strip_string((sfilt!=null?sfilt.getText():null)));
              		else
              			tmp.put("pattern",(rfilt!=null?rfilt.result:null));
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "event_filter"

    public static class on_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "on_expr"
    // RuleSet.g:958:1: on_expr returns [Object result] : ON (s= STRING | r= regex ) ;
    public final RuleSetParser.on_expr_return on_expr() throws RecognitionException {
        RuleSetParser.on_expr_return retval = new RuleSetParser.on_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token s=null;
        Token ON105=null;
        RuleSetParser.regex_return r = null;


        Object s_tree=null;
        Object ON105_tree=null;

        try {
            // RuleSet.g:958:32: ( ON (s= STRING | r= regex ) )
            // RuleSet.g:958:34: ON (s= STRING | r= regex )
            {
            root_0 = (Object)adaptor.nil();

            ON105=(Token)match(input,ON,FOLLOW_ON_in_on_expr1982); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            ON105_tree = (Object)adaptor.create(ON105);
            adaptor.addChild(root_0, ON105_tree);
            }
            // RuleSet.g:959:2: (s= STRING | r= regex )
            int alt70=2;
            int LA70_0 = input.LA(1);

            if ( (LA70_0==STRING) ) {
                alt70=1;
            }
            else if ( (LA70_0==REX) ) {
                alt70=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 70, 0, input);

                throw nvae;
            }
            switch (alt70) {
                case 1 :
                    // RuleSet.g:959:5: s= STRING
                    {
                    s=(Token)match(input,STRING,FOLLOW_STRING_in_on_expr1990); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    s_tree = (Object)adaptor.create(s);
                    adaptor.addChild(root_0, s_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.result = strip_string((s!=null?s.getText():null));
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:960:5: r= regex
                    {
                    pushFollow(FOLLOW_regex_in_on_expr2001);
                    r=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, r.getTree());
                    if ( state.backtracking==0 ) {
                      retval.result = (r!=null?r.result:null);
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "on_expr"

    public static class global_block_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "global_block"
    // RuleSet.g:965:2: global_block : GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL ;
    public final RuleSetParser.global_block_return global_block() throws RecognitionException {
        RuleSetParser.global_block_return retval = new RuleSetParser.global_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token name=null;
        Token dtype=null;
        Token src=null;
        Token GLOBAL106=null;
        Token LEFT_CURL107=null;
        Token COLON108=null;
        Token LEFT_SMALL_ARROW109=null;
        Token SEMI111=null;
        Token RIGHT_CURL112=null;
        RuleSetParser.emit_block_return emt = null;

        RuleSetParser.must_be_one_return dst = null;

        RuleSetParser.cachable_return cas = null;

        RuleSetParser.css_emit_return cemt = null;

        RuleSetParser.decl_return decl110 = null;


        Object name_tree=null;
        Object dtype_tree=null;
        Object src_tree=null;
        Object GLOBAL106_tree=null;
        Object LEFT_CURL107_tree=null;
        Object COLON108_tree=null;
        Object LEFT_SMALL_ARROW109_tree=null;
        Object SEMI111_tree=null;
        Object RIGHT_CURL112_tree=null;


        	 ArrayList global_block_array = (ArrayList)rule_json.get("global");
        	 boolean found_cache = false;

        try {
            // RuleSet.g:972:2: ( GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL )
            // RuleSet.g:972:4: GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            GLOBAL106=(Token)match(input,GLOBAL,FOLLOW_GLOBAL_in_global_block2039); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            GLOBAL106_tree = (Object)adaptor.create(GLOBAL106);
            adaptor.addChild(root_0, GLOBAL106_tree);
            }
            LEFT_CURL107=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_global_block2041); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL107_tree = (Object)adaptor.create(LEFT_CURL107);
            adaptor.addChild(root_0, LEFT_CURL107_tree);
            }
            // RuleSet.g:973:2: (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )*
            loop73:
            do {
                int alt73=6;
                switch ( input.LA(1) ) {
                case EMIT:
                    {
                    alt73=1;
                    }
                    break;
                case VAR:
                    {
                    int LA73_3 = input.LA(2);

                    if ( (LA73_3==EQUAL) ) {
                        alt73=4;
                    }
                    else if ( (LA73_3==VAR) ) {
                        alt73=2;
                    }


                    }
                    break;
                case CSS:
                    {
                    alt73=3;
                    }
                    break;
                case SEMI:
                    {
                    alt73=5;
                    }
                    break;

                }

                switch (alt73) {
            	case 1 :
            	    // RuleSet.g:973:4: emt= emit_block
            	    {
            	    pushFollow(FOLLOW_emit_block_in_global_block2048);
            	    emt=emit_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, emt.getTree());
            	    if ( state.backtracking==0 ) {

            	      		HashMap tmp = new HashMap(); 
            	      		tmp.put("emit",(emt!=null?emt.emit_value:null));
            	      		global_block_array.add(tmp);
            	      	
            	    }

            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:978:4: dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )?
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_global_block2058);
            	    dst=must_be_one(sar("dataset","datasource"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, dst.getTree());
            	    name=(Token)match(input,VAR,FOLLOW_VAR_in_global_block2063); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    name_tree = (Object)adaptor.create(name);
            	    adaptor.addChild(root_0, name_tree);
            	    }
            	    // RuleSet.g:978:58: ( COLON dtype= DTYPE )?
            	    int alt71=2;
            	    int LA71_0 = input.LA(1);

            	    if ( (LA71_0==COLON) ) {
            	        alt71=1;
            	    }
            	    switch (alt71) {
            	        case 1 :
            	            // RuleSet.g:978:59: COLON dtype= DTYPE
            	            {
            	            COLON108=(Token)match(input,COLON,FOLLOW_COLON_in_global_block2066); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            COLON108_tree = (Object)adaptor.create(COLON108);
            	            adaptor.addChild(root_0, COLON108_tree);
            	            }
            	            dtype=(Token)match(input,DTYPE,FOLLOW_DTYPE_in_global_block2070); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            dtype_tree = (Object)adaptor.create(dtype);
            	            adaptor.addChild(root_0, dtype_tree);
            	            }

            	            }
            	            break;

            	    }

            	    LEFT_SMALL_ARROW109=(Token)match(input,LEFT_SMALL_ARROW,FOLLOW_LEFT_SMALL_ARROW_in_global_block2074); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    LEFT_SMALL_ARROW109_tree = (Object)adaptor.create(LEFT_SMALL_ARROW109);
            	    adaptor.addChild(root_0, LEFT_SMALL_ARROW109_tree);
            	    }
            	    src=(Token)match(input,STRING,FOLLOW_STRING_in_global_block2078); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    src_tree = (Object)adaptor.create(src);
            	    adaptor.addChild(root_0, src_tree);
            	    }
            	    // RuleSet.g:978:107: (cas= cachable )?
            	    int alt72=2;
            	    int LA72_0 = input.LA(1);

            	    if ( (LA72_0==CACHABLE) ) {
            	        alt72=1;
            	    }
            	    switch (alt72) {
            	        case 1 :
            	            // RuleSet.g:978:108: cas= cachable
            	            {
            	            pushFollow(FOLLOW_cachable_in_global_block2083);
            	            cas=cachable();

            	            state._fsp--;
            	            if (state.failed) return retval;
            	            if ( state.backtracking==0 ) adaptor.addChild(root_0, cas.getTree());
            	            if ( state.backtracking==0 ) {
            	              found_cache =true; 
            	            }

            	            }
            	            break;

            	    }

            	    if ( state.backtracking==0 ) {

            	      	
            	      		HashMap tmp = new HashMap(); 
            	      		tmp.put("type",(dst!=null?input.toString(dst.start,dst.stop):null));	
            	      		tmp.put("name",(name!=null?name.getText():null));
            	      		tmp.put("datatype","JSON");
            	      		if((dtype!=null?dtype.getText():null) != null)
            	      		{
            	      			tmp.put("datatype",(dtype!=null?dtype.getText():null));
            	      		}
            	      		tmp.put("source",strip_string((src!=null?src.getText():null)));
            	      		if(found_cache)
            	      		{
            	      			if((cas!=null?cas.what:null) instanceof HashMap)
            	      			{
            	      				tmp.put("cachable",(cas!=null?cas.what:null));
            	      			}
            	      			else if((cas!=null?cas.what:null) instanceof Long)
            	      			{
            	      				tmp.put("cachable",((Long)(cas!=null?cas.what:null)).longValue());
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

            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:1012:4: cemt= css_emit
            	    {
            	    pushFollow(FOLLOW_css_emit_in_global_block2098);
            	    cemt=css_emit();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, cemt.getTree());
            	    if ( state.backtracking==0 ) {

            	      		HashMap tmp = new HashMap(); 
            	      		tmp.put("content",(cemt!=null?cemt.emit_value:null));
            	      		tmp.put("type","css");
            	      		global_block_array.add(tmp);
            	      	
            	    }

            	    }
            	    break;
            	case 4 :
            	    // RuleSet.g:1018:4: decl[global_block_array]
            	    {
            	    pushFollow(FOLLOW_decl_in_global_block2106);
            	    decl110=decl(global_block_array);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl110.getTree());

            	    }
            	    break;
            	case 5 :
            	    // RuleSet.g:1019:4: SEMI
            	    {
            	    SEMI111=(Token)match(input,SEMI,FOLLOW_SEMI_in_global_block2112); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI111_tree = (Object)adaptor.create(SEMI111);
            	    adaptor.addChild(root_0, SEMI111_tree);
            	    }

            	    }
            	    break;

            	default :
            	    break loop73;
                }
            } while (true);

            RIGHT_CURL112=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_global_block2117); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL112_tree = (Object)adaptor.create(RIGHT_CURL112);
            adaptor.addChild(root_0, RIGHT_CURL112_tree);
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
            if ( state.backtracking==0 ) {


            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "global_block"

    public static class decl_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "decl"
    // RuleSet.g:1026:1: decl[ArrayList block_array] : var= VAR EQUAL (hval= HTML | jval= JS | e= expr ) ;
    public final RuleSetParser.decl_return decl(ArrayList  block_array) throws RecognitionException {
        RuleSetParser.decl_return retval = new RuleSetParser.decl_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token var=null;
        Token hval=null;
        Token jval=null;
        Token EQUAL113=null;
        RuleSetParser.expr_return e = null;


        Object var_tree=null;
        Object hval_tree=null;
        Object jval_tree=null;
        Object EQUAL113_tree=null;



        try {
            // RuleSet.g:1029:2: (var= VAR EQUAL (hval= HTML | jval= JS | e= expr ) )
            // RuleSet.g:1030:2: var= VAR EQUAL (hval= HTML | jval= JS | e= expr )
            {
            root_0 = (Object)adaptor.nil();

            var=(Token)match(input,VAR,FOLLOW_VAR_in_decl2144); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            var_tree = (Object)adaptor.create(var);
            adaptor.addChild(root_0, var_tree);
            }
            EQUAL113=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_decl2146); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL113_tree = (Object)adaptor.create(EQUAL113);
            adaptor.addChild(root_0, EQUAL113_tree);
            }
            // RuleSet.g:1030:16: (hval= HTML | jval= JS | e= expr )
            int alt74=3;
            switch ( input.LA(1) ) {
            case HTML:
                {
                alt74=1;
                }
                break;
            case JS:
                {
                alt74=2;
                }
                break;
            case LEFT_CURL:
            case VAR:
            case INT:
            case STRING:
            case VAR_DOMAIN:
            case REPLACE:
            case MATCH:
            case OTHER_OPERATORS:
            case LEFT_PAREN:
            case NOT:
            case FUNCTION:
            case REX:
            case SEEN:
            case FLOAT:
            case TRUE:
            case FALSE:
            case LEFT_BRACKET:
            case CURRENT:
            case HISTORY:
                {
                alt74=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 74, 0, input);

                throw nvae;
            }

            switch (alt74) {
                case 1 :
                    // RuleSet.g:1030:17: hval= HTML
                    {
                    hval=(Token)match(input,HTML,FOLLOW_HTML_in_decl2151); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    hval_tree = (Object)adaptor.create(hval);
                    adaptor.addChild(root_0, hval_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1030:27: jval= JS
                    {
                    jval=(Token)match(input,JS,FOLLOW_JS_in_decl2155); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    jval_tree = (Object)adaptor.create(jval);
                    adaptor.addChild(root_0, jval_tree);
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1030:35: e= expr
                    {
                    pushFollow(FOLLOW_expr_in_decl2159);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {
               
              		HashMap tmp = new HashMap(); 
              			tmp.put("lhs",(var!=null?var.getText():null));
              		if((hval!=null?hval.getText():null) != null)
              		{
              			tmp.put("rhs",strip_wrappers("<<",">>",(hval!=null?hval.getText():null)));
              			tmp.put("type","here_doc");
              		}
              		else if((jval!=null?jval.getText():null) != null) {
              			tmp.put("rhs",strip_wrappers("<|","|>",(jval!=null?jval.getText():null)));
              			tmp.put("type","JS");
              		}
              		else
              		{
              			tmp.put("type","expr");
              			tmp.put("rhs",(e!=null?e.result:null));		
              		}
              		block_array.add(tmp);
              	 
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "decl"

    public static class expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "expr"
    // RuleSet.g:1054:1: expr returns [Object result] : (fd= function_def | c= conditional_expression ) ;
    public final RuleSetParser.expr_return expr() throws RecognitionException {
        RuleSetParser.expr_return retval = new RuleSetParser.expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.function_def_return fd = null;

        RuleSetParser.conditional_expression_return c = null;




        	HashMap result_hash = new HashMap();

        try {
            // RuleSet.g:1058:2: ( (fd= function_def | c= conditional_expression ) )
            // RuleSet.g:1058:4: (fd= function_def | c= conditional_expression )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:1058:4: (fd= function_def | c= conditional_expression )
            int alt75=2;
            int LA75_0 = input.LA(1);

            if ( (LA75_0==FUNCTION) ) {
                alt75=1;
            }
            else if ( (LA75_0==LEFT_CURL||(LA75_0>=VAR && LA75_0<=INT)||(LA75_0>=STRING && LA75_0<=VAR_DOMAIN)||(LA75_0>=REPLACE && LA75_0<=LEFT_PAREN)||LA75_0==NOT||(LA75_0>=REX && LA75_0<=SEEN)||(LA75_0>=FLOAT && LA75_0<=LEFT_BRACKET)||(LA75_0>=CURRENT && LA75_0<=HISTORY)) ) {
                alt75=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 75, 0, input);

                throw nvae;
            }
            switch (alt75) {
                case 1 :
                    // RuleSet.g:1058:5: fd= function_def
                    {
                    pushFollow(FOLLOW_function_def_in_expr2189);
                    fd=function_def();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, fd.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (fd!=null?fd.result:null);
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1061:4: c= conditional_expression
                    {
                    pushFollow(FOLLOW_conditional_expression_in_expr2198);
                    c=conditional_expression();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, c.getTree());
                    if ( state.backtracking==0 ) {

                      		retval.result = (c!=null?c.result:null);
                      	
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "expr"

    public static class function_def_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "function_def"
    // RuleSet.g:1065:1: function_def returns [Object result] : FUNCTION LEFT_PAREN (args+= VAR )? ( COMMA args+= VAR )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL ;
    public final RuleSetParser.function_def_return function_def() throws RecognitionException {
        RuleSetParser.function_def_return retval = new RuleSetParser.function_def_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token FUNCTION114=null;
        Token LEFT_PAREN115=null;
        Token COMMA116=null;
        Token RIGHT_PAREN117=null;
        Token LEFT_CURL118=null;
        Token SEMI119=null;
        Token SEMI120=null;
        Token RIGHT_CURL121=null;
        Token args=null;
        List list_args=null;
        List list_decs=null;
        RuleSetParser.expr_return e1 = null;

        RuleReturnScope decs = null;
        Object FUNCTION114_tree=null;
        Object LEFT_PAREN115_tree=null;
        Object COMMA116_tree=null;
        Object RIGHT_PAREN117_tree=null;
        Object LEFT_CURL118_tree=null;
        Object SEMI119_tree=null;
        Object SEMI120_tree=null;
        Object RIGHT_CURL121_tree=null;
        Object args_tree=null;


        	ArrayList block_array = new ArrayList();

        try {
            // RuleSet.g:1069:2: ( FUNCTION LEFT_PAREN (args+= VAR )? ( COMMA args+= VAR )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL )
            // RuleSet.g:1069:4: FUNCTION LEFT_PAREN (args+= VAR )? ( COMMA args+= VAR )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            FUNCTION114=(Token)match(input,FUNCTION,FOLLOW_FUNCTION_in_function_def2223); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FUNCTION114_tree = (Object)adaptor.create(FUNCTION114);
            adaptor.addChild(root_0, FUNCTION114_tree);
            }
            LEFT_PAREN115=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_function_def2225); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_PAREN115_tree = (Object)adaptor.create(LEFT_PAREN115);
            adaptor.addChild(root_0, LEFT_PAREN115_tree);
            }
            // RuleSet.g:1069:28: (args+= VAR )?
            int alt76=2;
            int LA76_0 = input.LA(1);

            if ( (LA76_0==VAR) ) {
                alt76=1;
            }
            switch (alt76) {
                case 1 :
                    // RuleSet.g:0:0: args+= VAR
                    {
                    args=(Token)match(input,VAR,FOLLOW_VAR_in_function_def2229); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    args_tree = (Object)adaptor.create(args);
                    adaptor.addChild(root_0, args_tree);
                    }
                    if (list_args==null) list_args=new ArrayList();
                    list_args.add(args);


                    }
                    break;

            }

            // RuleSet.g:1069:35: ( COMMA args+= VAR )*
            loop77:
            do {
                int alt77=2;
                int LA77_0 = input.LA(1);

                if ( (LA77_0==COMMA) ) {
                    alt77=1;
                }


                switch (alt77) {
            	case 1 :
            	    // RuleSet.g:1069:36: COMMA args+= VAR
            	    {
            	    COMMA116=(Token)match(input,COMMA,FOLLOW_COMMA_in_function_def2233); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    COMMA116_tree = (Object)adaptor.create(COMMA116);
            	    adaptor.addChild(root_0, COMMA116_tree);
            	    }
            	    args=(Token)match(input,VAR,FOLLOW_VAR_in_function_def2237); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    args_tree = (Object)adaptor.create(args);
            	    adaptor.addChild(root_0, args_tree);
            	    }
            	    if (list_args==null) list_args=new ArrayList();
            	    list_args.add(args);


            	    }
            	    break;

            	default :
            	    break loop77;
                }
            } while (true);

            RIGHT_PAREN117=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_function_def2242); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_PAREN117_tree = (Object)adaptor.create(RIGHT_PAREN117);
            adaptor.addChild(root_0, RIGHT_PAREN117_tree);
            }
            LEFT_CURL118=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_function_def2244); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL118_tree = (Object)adaptor.create(LEFT_CURL118);
            adaptor.addChild(root_0, LEFT_CURL118_tree);
            }
            // RuleSet.g:1069:81: (decs+= decl[block_array] )?
            int alt78=2;
            int LA78_0 = input.LA(1);

            if ( (LA78_0==VAR) ) {
                int LA78_1 = input.LA(2);

                if ( (LA78_1==EQUAL) ) {
                    alt78=1;
                }
            }
            switch (alt78) {
                case 1 :
                    // RuleSet.g:0:0: decs+= decl[block_array]
                    {
                    pushFollow(FOLLOW_decl_in_function_def2248);
                    decs=decl(block_array);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, decs.getTree());
                    if (list_decs==null) list_decs=new ArrayList();
                    list_decs.add(decs.getTree());


                    }
                    break;

            }

            // RuleSet.g:1069:102: ( SEMI decs+= decl[block_array] )*
            loop79:
            do {
                int alt79=2;
                int LA79_0 = input.LA(1);

                if ( (LA79_0==SEMI) ) {
                    int LA79_1 = input.LA(2);

                    if ( (LA79_1==VAR) ) {
                        int LA79_3 = input.LA(3);

                        if ( (LA79_3==EQUAL) ) {
                            alt79=1;
                        }


                    }


                }


                switch (alt79) {
            	case 1 :
            	    // RuleSet.g:1069:103: SEMI decs+= decl[block_array]
            	    {
            	    SEMI119=(Token)match(input,SEMI,FOLLOW_SEMI_in_function_def2253); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI119_tree = (Object)adaptor.create(SEMI119);
            	    adaptor.addChild(root_0, SEMI119_tree);
            	    }
            	    pushFollow(FOLLOW_decl_in_function_def2257);
            	    decs=decl(block_array);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decs.getTree());
            	    if (list_decs==null) list_decs=new ArrayList();
            	    list_decs.add(decs.getTree());


            	    }
            	    break;

            	default :
            	    break loop79;
                }
            } while (true);

            // RuleSet.g:1069:134: ( SEMI )?
            int alt80=2;
            int LA80_0 = input.LA(1);

            if ( (LA80_0==SEMI) ) {
                alt80=1;
            }
            switch (alt80) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI120=(Token)match(input,SEMI,FOLLOW_SEMI_in_function_def2262); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI120_tree = (Object)adaptor.create(SEMI120);
                    adaptor.addChild(root_0, SEMI120_tree);
                    }

                    }
                    break;

            }

            pushFollow(FOLLOW_expr_in_function_def2267);
            e1=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
            RIGHT_CURL121=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_function_def2269); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL121_tree = (Object)adaptor.create(RIGHT_CURL121);
            adaptor.addChild(root_0, RIGHT_CURL121_tree);
            }
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		ArrayList nargs = new ArrayList();
              		if(list_args != null)
              		{
              			for(int i = 0;i< list_args.size();i++)
              			{
              				nargs.add(((Token)list_args.get(i)).getText());
              			}
              		}
              		tmp.put("vars",nargs);
              		tmp.put("type","function");
              		tmp.put("decls",block_array); 
              		if((e1!=null?input.toString(e1.start,e1.stop):null) != null)
              			tmp.put("expr",(e1!=null?e1.result:null));	
              				
              		retval.result = tmp;		
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "function_def"

    public static class conditional_expression_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "conditional_expression"
    // RuleSet.g:1089:1: conditional_expression returns [Object result] : d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )? ;
    public final RuleSetParser.conditional_expression_return conditional_expression() throws RecognitionException {
        RuleSetParser.conditional_expression_return retval = new RuleSetParser.conditional_expression_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ARROW_RIGHT122=null;
        Token PIPE123=null;
        RuleSetParser.disjunction_return d = null;

        RuleSetParser.expr_return e1 = null;

        RuleSetParser.expr_return e2 = null;


        Object ARROW_RIGHT122_tree=null;
        Object PIPE123_tree=null;


        	ArrayList tmp_list = new ArrayList();

        try {
            // RuleSet.g:1093:2: (d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )? )
            // RuleSet.g:1093:5: d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_disjunction_in_conditional_expression2295);
            d=disjunction();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, d.getTree());
            // RuleSet.g:1093:19: ( ARROW_RIGHT e1= expr PIPE e2= expr )?
            int alt81=2;
            int LA81_0 = input.LA(1);

            if ( (LA81_0==ARROW_RIGHT) ) {
                alt81=1;
            }
            switch (alt81) {
                case 1 :
                    // RuleSet.g:1093:20: ARROW_RIGHT e1= expr PIPE e2= expr
                    {
                    ARROW_RIGHT122=(Token)match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_conditional_expression2298); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    ARROW_RIGHT122_tree = (Object)adaptor.create(ARROW_RIGHT122);
                    adaptor.addChild(root_0, ARROW_RIGHT122_tree);
                    }
                    pushFollow(FOLLOW_expr_in_conditional_expression2302);
                    e1=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
                    PIPE123=(Token)match(input,PIPE,FOLLOW_PIPE_in_conditional_expression2304); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    PIPE123_tree = (Object)adaptor.create(PIPE123);
                    adaptor.addChild(root_0, PIPE123_tree);
                    }
                    pushFollow(FOLLOW_expr_in_conditional_expression2308);
                    e2=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e2.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {
               
              	   	if((e1!=null?input.toString(e1.start,e1.stop):null) == null)
              	   	{
              		   	retval.result = (d!=null?d.result:null); 
              		}
              		else
              		{
              		    HashMap tmp = new HashMap();
              		    tmp.put("test",(d!=null?d.result:null));
              		    tmp.put("then",(e1!=null?e1.result:null));
              		    tmp.put("else",(e2!=null?e2.result:null));
              		    tmp.put("type","condexpr");
              		    retval.result = tmp;
              			
              		}
              		   
              	   
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "conditional_expression"

    public static class disjunction_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "disjunction"
    // RuleSet.g:1114:1: disjunction returns [Object result] : me1= equality_expr (op= ( OR | AND ) me2= equality_expr )* ;
    public final RuleSetParser.disjunction_return disjunction() throws RecognitionException {
        RuleSetParser.disjunction_return retval = new RuleSetParser.disjunction_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token op=null;
        RuleSetParser.equality_expr_return me1 = null;

        RuleSetParser.equality_expr_return me2 = null;


        Object op_tree=null;


        	boolean found_op = false;
        	ArrayList result = new ArrayList();

        try {
            // RuleSet.g:1119:2: (me1= equality_expr (op= ( OR | AND ) me2= equality_expr )* )
            // RuleSet.g:1119:4: me1= equality_expr (op= ( OR | AND ) me2= equality_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_equality_expr_in_disjunction2340);
            me1=equality_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1119:22: (op= ( OR | AND ) me2= equality_expr )*
            loop82:
            do {
                int alt82=2;
                int LA82_0 = input.LA(1);

                if ( ((LA82_0>=OR && LA82_0<=AND)) ) {
                    alt82=1;
                }


                switch (alt82) {
            	case 1 :
            	    // RuleSet.g:1119:23: op= ( OR | AND ) me2= equality_expr
            	    {
            	    op=(Token)input.LT(1);
            	    if ( (input.LA(1)>=OR && input.LA(1)<=AND) ) {
            	        input.consume();
            	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(op));
            	        state.errorRecovery=false;state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }

            	    pushFollow(FOLLOW_equality_expr_in_disjunction2353);
            	    me2=equality_expr();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, me2.getTree());
            	    if ( state.backtracking==0 ) {

            	      		found_op = true;
            	      		if(result.isEmpty())
            	      		{
            	      			 add_to_expression(result,"pred",(op!=null?op.getText():null),(me1!=null?me1.result:null));
            	      			 add_to_expression(result,"pred",(op!=null?op.getText():null),(me2!=null?me2.result:null));
            	      		}			 
            	      		else
            	      			 add_to_expression(result,"pred",(op!=null?op.getText():null),(me2!=null?me2.result:null));

            	      	
            	    }

            	    }
            	    break;

            	default :
            	    break loop82;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              		if(found_op)
              			retval.result = build_exp_result(result); 
              		else
              			retval.result = (me1!=null?me1.result:null);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "disjunction"

    public static class equality_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "equality_expr"
    // RuleSet.g:1138:1: equality_expr returns [Object result] : me1= add_expr (op= PREDOP me2= add_expr )* ;
    public final RuleSetParser.equality_expr_return equality_expr() throws RecognitionException {
        RuleSetParser.equality_expr_return retval = new RuleSetParser.equality_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token op=null;
        RuleSetParser.add_expr_return me1 = null;

        RuleSetParser.add_expr_return me2 = null;


        Object op_tree=null;


        	boolean found_op = false;
        	ArrayList result = new ArrayList();

        try {
            // RuleSet.g:1143:2: (me1= add_expr (op= PREDOP me2= add_expr )* )
            // RuleSet.g:1143:4: me1= add_expr (op= PREDOP me2= add_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_add_expr_in_equality_expr2384);
            me1=add_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1143:17: (op= PREDOP me2= add_expr )*
            loop83:
            do {
                int alt83=2;
                int LA83_0 = input.LA(1);

                if ( (LA83_0==PREDOP) ) {
                    alt83=1;
                }


                switch (alt83) {
            	case 1 :
            	    // RuleSet.g:1143:18: op= PREDOP me2= add_expr
            	    {
            	    op=(Token)match(input,PREDOP,FOLLOW_PREDOP_in_equality_expr2389); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    op_tree = (Object)adaptor.create(op);
            	    adaptor.addChild(root_0, op_tree);
            	    }
            	    pushFollow(FOLLOW_add_expr_in_equality_expr2393);
            	    me2=add_expr();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, me2.getTree());
            	    if ( state.backtracking==0 ) {

            	      		found_op = true;
            	      		if(result.isEmpty())
            	      		{
            	      			 add_to_expression(result,"ineq",(op!=null?op.getText():null),(me1!=null?me1.result:null));
            	      			 add_to_expression(result,"ineq",(op!=null?op.getText():null),(me2!=null?me2.result:null));
            	      		}
            	      		else
            	      			 add_to_expression(result,"ineq",(op!=null?op.getText():null),(me2!=null?me2.result:null));
            	      	
            	    }

            	    }
            	    break;

            	default :
            	    break loop83;
                }
            } while (true);

            if ( state.backtracking==0 ) {
               
              		if(found_op)
              			retval.result = build_exp_result(result); 
              		else
              			retval.result = (me1!=null?me1.result:null);
              	 
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "equality_expr"

    public static class add_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "add_expr"
    // RuleSet.g:1161:1: add_expr returns [Object result] : me1= unary_expr (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )* ;
    public final RuleSetParser.add_expr_return add_expr() throws RecognitionException {
        RuleSetParser.add_expr_return retval = new RuleSetParser.add_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token op=null;
        RuleSetParser.unary_expr_return me1 = null;

        RuleSetParser.unary_expr_return me2 = null;


        Object op_tree=null;


        	boolean found_op = false;
        	ArrayList result = new ArrayList();

        try {
            // RuleSet.g:1166:2: (me1= unary_expr (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )* )
            // RuleSet.g:1166:4: me1= unary_expr (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_unary_expr_in_add_expr2427);
            me1=unary_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1166:20: (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )*
            loop84:
            do {
                int alt84=2;
                alt84 = dfa84.predict(input);
                switch (alt84) {
            	case 1 :
            	    // RuleSet.g:1166:21: op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr
            	    {
            	    op=(Token)input.LT(1);
            	    if ( (input.LA(1)>=ADD_OP && input.LA(1)<=REX) ) {
            	        input.consume();
            	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(op));
            	        state.errorRecovery=false;state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }

            	    pushFollow(FOLLOW_unary_expr_in_add_expr2443);
            	    me2=unary_expr();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, me2.getTree());
            	    if ( state.backtracking==0 ) {

            	      		found_op = true;
            	      		if(result.isEmpty())
            	      		{
            	      			 add_to_expression(result,"prim",(op!=null?op.getText():null),(me1!=null?me1.result:null));
            	      			 add_to_expression(result,"prim",(op!=null?op.getText():null),(me2!=null?me2.result:null));
            	      		}
            	      		else
            	      			 add_to_expression(result,"prim",(op!=null?op.getText():null),(me2!=null?me2.result:null));
            	      	
            	    }

            	    }
            	    break;

            	default :
            	    break loop84;
                }
            } while (true);

            if ( state.backtracking==0 ) {
               
              		if(found_op)
              			retval.result = build_exp_result(result); 
              		else
              			retval.result = (me1!=null?me1.result:null);
               
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "add_expr"

    public static class unary_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "unary_expr"
    // RuleSet.g:1185:1: unary_expr returns [Object result] options {backtrack=true; } : ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR | vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe | vd= VAR_DOMAIN COLON v= VAR t= timeframe | roe= regex | oe= operator_expr );
    public final RuleSetParser.unary_expr_return unary_expr() throws RecognitionException {
        RuleSetParser.unary_expr_return retval = new RuleSetParser.unary_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token rx=null;
        Token vd=null;
        Token v=null;
        Token rx_1=null;
        Token rx_2=null;
        Token pop=null;
        Token NOT124=null;
        Token SEEN125=null;
        Token char_literal127=null;
        Token SEEN128=null;
        Token char_literal130=null;
        Token COLON131=null;
        Token COLON132=null;
        RuleSetParser.unary_expr_return ue = null;

        RuleSetParser.timeframe_return t = null;

        RuleSetParser.must_be_one_return op = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.regex_return roe = null;

        RuleSetParser.operator_expr_return oe = null;

        RuleSetParser.must_be_return must_be126 = null;

        RuleSetParser.must_be_return must_be129 = null;


        Object rx_tree=null;
        Object vd_tree=null;
        Object v_tree=null;
        Object rx_1_tree=null;
        Object rx_2_tree=null;
        Object pop_tree=null;
        Object NOT124_tree=null;
        Object SEEN125_tree=null;
        Object char_literal127_tree=null;
        Object SEEN128_tree=null;
        Object char_literal130_tree=null;
        Object COLON131_tree=null;
        Object COLON132_tree=null;




        try {
            // RuleSet.g:1189:2: ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR | vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe | vd= VAR_DOMAIN COLON v= VAR t= timeframe | roe= regex | oe= operator_expr )
            int alt86=7;
            alt86 = dfa86.predict(input);
            switch (alt86) {
                case 1 :
                    // RuleSet.g:1189:4: NOT ue= unary_expr
                    {
                    root_0 = (Object)adaptor.nil();

                    NOT124=(Token)match(input,NOT,FOLLOW_NOT_in_unary_expr2487); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    NOT124_tree = (Object)adaptor.create(NOT124);
                    adaptor.addChild(root_0, NOT124_tree);
                    }
                    pushFollow(FOLLOW_unary_expr_in_unary_expr2491);
                    ue=unary_expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ue.getTree());
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("type","pred");
                      	      	tmp.put("op","negation");
                      	      	ArrayList tmpar = new ArrayList();
                      	      	tmpar.add((ue!=null?ue.result:null));
                      	      	tmp.put("args",tmpar);
                      	      	retval.result = tmp;				
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1198:4: SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )?
                    {
                    root_0 = (Object)adaptor.nil();

                    SEEN125=(Token)match(input,SEEN,FOLLOW_SEEN_in_unary_expr2500); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEEN125_tree = (Object)adaptor.create(SEEN125);
                    adaptor.addChild(root_0, SEEN125_tree);
                    }
                    rx=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2504); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_tree = (Object)adaptor.create(rx);
                    adaptor.addChild(root_0, rx_tree);
                    }
                    pushFollow(FOLLOW_must_be_in_unary_expr2506);
                    must_be126=must_be("in");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be126.getTree());
                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2511); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    char_literal127=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2513); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal127_tree = (Object)adaptor.create(char_literal127);
                    adaptor.addChild(root_0, char_literal127_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_unary_expr2517); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    // RuleSet.g:1198:58: (t= timeframe )?
                    int alt85=2;
                    alt85 = dfa85.predict(input);
                    switch (alt85) {
                        case 1 :
                            // RuleSet.g:0:0: t= timeframe
                            {
                            pushFollow(FOLLOW_timeframe_in_unary_expr2521);
                            t=timeframe();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, t.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("within",(t!=null?t.result:null));
                      	      	tmp.put("type","seen_timeframe");
                      	      	tmp.put("var",(v!=null?v.getText():null));
                      	      	tmp.put("regexp",strip_string((rx!=null?rx.getText():null)));
                      	      	tmp.put("domain",(vd!=null?vd.getText():null));
                      	      	if((t!=null?input.toString(t.start,t.stop):null) != null)
                      		      	tmp.put("timeframe",t.time);
                      	      	retval.result = tmp;		
                      	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1209:4: SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR
                    {
                    root_0 = (Object)adaptor.nil();

                    SEEN128=(Token)match(input,SEEN,FOLLOW_SEEN_in_unary_expr2529); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEEN128_tree = (Object)adaptor.create(SEEN128);
                    adaptor.addChild(root_0, SEEN128_tree);
                    }
                    rx_1=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2533); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_1_tree = (Object)adaptor.create(rx_1);
                    adaptor.addChild(root_0, rx_1_tree);
                    }
                    pushFollow(FOLLOW_must_be_one_in_unary_expr2537);
                    op=must_be_one(sar("before","after"));

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, op.getTree());
                    rx_2=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2542); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_2_tree = (Object)adaptor.create(rx_2);
                    adaptor.addChild(root_0, rx_2_tree);
                    }
                    pushFollow(FOLLOW_must_be_in_unary_expr2545);
                    must_be129=must_be("in");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be129.getTree());
                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2550); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    char_literal130=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2552); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal130_tree = (Object)adaptor.create(char_literal130);
                    adaptor.addChild(root_0, char_literal130_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_unary_expr2556); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("type","seen_compare");
                      	      	tmp.put("domain",(vd!=null?vd.getText():null));
                      	      	tmp.put("regexp_1",strip_string((rx_1!=null?rx_1.getText():null)));
                      	      	tmp.put("regexp_2",strip_string((rx_2!=null?rx_2.getText():null)));	      	
                      	      	tmp.put("var",(v!=null?v.getText():null));
                      	      	tmp.put("op",(op!=null?input.toString(op.start,op.stop):null));
                      	      	retval.result = tmp;		
                      	
                    }

                    }
                    break;
                case 4 :
                    // RuleSet.g:1219:4: vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe
                    {
                    root_0 = (Object)adaptor.nil();

                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2565); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    COLON131=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2567); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON131_tree = (Object)adaptor.create(COLON131);
                    adaptor.addChild(root_0, COLON131_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_unary_expr2571); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    pop=(Token)match(input,PREDOP,FOLLOW_PREDOP_in_unary_expr2575); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    pop_tree = (Object)adaptor.create(pop);
                    adaptor.addChild(root_0, pop_tree);
                    }
                    pushFollow(FOLLOW_expr_in_unary_expr2579);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    pushFollow(FOLLOW_timeframe_in_unary_expr2583);
                    t=timeframe();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, t.getTree());
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("within",(t!=null?t.result:null));
                      	      	tmp.put("timeframe",t.time);
                      	      	tmp.put("type","persistent_ineq");
                      	      	tmp.put("domain",(vd!=null?vd.getText():null));
                      	      	tmp.put("expr",(e!=null?e.result:null));
                      	      	tmp.put("var",(v!=null?v.getText():null));
                      	      	tmp.put("ineq",(pop!=null?pop.getText():null));
                      	      	retval.result = tmp;		
                      	
                      	
                    }

                    }
                    break;
                case 5 :
                    // RuleSet.g:1231:4: vd= VAR_DOMAIN COLON v= VAR t= timeframe
                    {
                    root_0 = (Object)adaptor.nil();

                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2593); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    COLON132=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2595); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON132_tree = (Object)adaptor.create(COLON132);
                    adaptor.addChild(root_0, COLON132_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_unary_expr2599); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    pushFollow(FOLLOW_timeframe_in_unary_expr2603);
                    t=timeframe();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, t.getTree());
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("within",(t!=null?t.result:null));
                      	      	tmp.put("timeframe",t.time);
                      	      	tmp.put("type","persistent_ineq");
                      	      	tmp.put("domain",(vd!=null?vd.getText():null));
                      	      	tmp.put("ineq","==");
                      	      	tmp.put("var",(v!=null?v.getText():null));
                      	      	retval.result = tmp;		
                      	
                      	
                    }

                    }
                    break;
                case 6 :
                    // RuleSet.g:1242:4: roe= regex
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_regex_in_unary_expr2612);
                    roe=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, roe.getTree());
                    if ( state.backtracking==0 ) {
                       
                      		retval.result = (roe!=null?roe.result:null); 
                      	
                    }

                    }
                    break;
                case 7 :
                    // RuleSet.g:1245:4: oe= operator_expr
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_operator_expr_in_unary_expr2621);
                    oe=operator_expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, oe.getTree());
                    if ( state.backtracking==0 ) {
                       
                      		retval.result = (oe!=null?oe.result:null); 
                      	
                    }

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "unary_expr"

    public static class operator_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "operator_expr"
    // RuleSet.g:1251:1: operator_expr returns [Object result] : f= factor (o= operator )* ;
    public final RuleSetParser.operator_expr_return operator_expr() throws RecognitionException {
        RuleSetParser.operator_expr_return retval = new RuleSetParser.operator_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.factor_return f = null;

        RuleSetParser.operator_return o = null;




        	ArrayList operators = new ArrayList();

        try {
            // RuleSet.g:1256:2: (f= factor (o= operator )* )
            // RuleSet.g:1256:4: f= factor (o= operator )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_factor_in_operator_expr2650);
            f=factor();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());
            // RuleSet.g:1256:14: (o= operator )*
            loop87:
            do {
                int alt87=2;
                int LA87_0 = input.LA(1);

                if ( (LA87_0==DOT) ) {
                    alt87=1;
                }


                switch (alt87) {
            	case 1 :
            	    // RuleSet.g:1256:15: o= operator
            	    {
            	    pushFollow(FOLLOW_operator_in_operator_expr2656);
            	    o=operator();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, o.getTree());
            	    if ( state.backtracking==0 ) {
            	       operators.add(o); 
            	    }

            	    }
            	    break;

            	default :
            	    break loop87;
                }
            } while (true);

            if ( state.backtracking==0 ) {

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
              			last_one.put("obj",(f!=null?f.result:null));
              		    retval.result = the_result;;		
              		}
              		else
              		{
              			retval.result = (f!=null?f.result:null);
              		}		
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "operator_expr"

    public static class operator_return extends ParserRuleReturnScope {
        public String oper;
        public ArrayList exprs;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "operator"
    // RuleSet.g:1294:1: operator returns [String oper,ArrayList exprs] : DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN ) ;
    public final RuleSetParser.operator_return operator() throws RecognitionException {
        RuleSetParser.operator_return retval = new RuleSetParser.operator_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token o=null;
        Token o1=null;
        Token o2=null;
        Token DOT133=null;
        Token LEFT_PAREN134=null;
        Token char_literal135=null;
        Token RIGHT_PAREN136=null;
        Token LEFT_PAREN137=null;
        Token RIGHT_PAREN138=null;
        Token LEFT_PAREN139=null;
        Token char_literal140=null;
        Token RIGHT_PAREN141=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.expr_return e1 = null;

        RuleSetParser.expr_return rx = null;


        Object o_tree=null;
        Object o1_tree=null;
        Object o2_tree=null;
        Object DOT133_tree=null;
        Object LEFT_PAREN134_tree=null;
        Object char_literal135_tree=null;
        Object RIGHT_PAREN136_tree=null;
        Object LEFT_PAREN137_tree=null;
        Object RIGHT_PAREN138_tree=null;
        Object LEFT_PAREN139_tree=null;
        Object char_literal140_tree=null;
        Object RIGHT_PAREN141_tree=null;

        	
        	ArrayList rexprs = new ArrayList();

        try {
            // RuleSet.g:1299:2: ( DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN ) )
            // RuleSet.g:1299:4: DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN )
            {
            root_0 = (Object)adaptor.nil();

            DOT133=(Token)match(input,DOT,FOLLOW_DOT_in_operator2683); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            DOT133_tree = (Object)adaptor.create(DOT133);
            adaptor.addChild(root_0, DOT133_tree);
            }
            // RuleSet.g:1299:8: (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN )
            int alt90=3;
            switch ( input.LA(1) ) {
            case OTHER_OPERATORS:
                {
                alt90=1;
                }
                break;
            case MATCH:
                {
                alt90=2;
                }
                break;
            case REPLACE:
                {
                alt90=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 90, 0, input);

                throw nvae;
            }

            switch (alt90) {
                case 1 :
                    // RuleSet.g:1299:10: o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN
                    {
                    o=(Token)match(input,OTHER_OPERATORS,FOLLOW_OTHER_OPERATORS_in_operator2689); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o_tree = (Object)adaptor.create(o);
                    adaptor.addChild(root_0, o_tree);
                    }
                    LEFT_PAREN134=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator2691); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN134_tree = (Object)adaptor.create(LEFT_PAREN134);
                    adaptor.addChild(root_0, LEFT_PAREN134_tree);
                    }
                    // RuleSet.g:1299:39: (e= expr ( ',' e1= expr )* )?
                    int alt89=2;
                    int LA89_0 = input.LA(1);

                    if ( (LA89_0==LEFT_CURL||(LA89_0>=VAR && LA89_0<=INT)||(LA89_0>=STRING && LA89_0<=VAR_DOMAIN)||(LA89_0>=REPLACE && LA89_0<=LEFT_PAREN)||LA89_0==NOT||LA89_0==FUNCTION||(LA89_0>=REX && LA89_0<=SEEN)||(LA89_0>=FLOAT && LA89_0<=LEFT_BRACKET)||(LA89_0>=CURRENT && LA89_0<=HISTORY)) ) {
                        alt89=1;
                    }
                    switch (alt89) {
                        case 1 :
                            // RuleSet.g:1299:40: e= expr ( ',' e1= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_operator2696);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                              rexprs.add(e.result); 
                            }
                            // RuleSet.g:1299:72: ( ',' e1= expr )*
                            loop88:
                            do {
                                int alt88=2;
                                int LA88_0 = input.LA(1);

                                if ( (LA88_0==COMMA) ) {
                                    alt88=1;
                                }


                                switch (alt88) {
                            	case 1 :
                            	    // RuleSet.g:1299:73: ',' e1= expr
                            	    {
                            	    char_literal135=(Token)match(input,COMMA,FOLLOW_COMMA_in_operator2701); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    char_literal135_tree = (Object)adaptor.create(char_literal135);
                            	    adaptor.addChild(root_0, char_literal135_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_operator2705);
                            	    e1=expr();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
                            	    if ( state.backtracking==0 ) {
                            	      rexprs.add(e1.result); 
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop88;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN136=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator2714); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN136_tree = (Object)adaptor.create(RIGHT_PAREN136);
                    adaptor.addChild(root_0, RIGHT_PAREN136_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		// Remove .
                            		retval.oper = (o!=null?o.getText():null);
                            		retval.exprs = rexprs;
                            	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1305:9: o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN
                    {
                    o1=(Token)match(input,MATCH,FOLLOW_MATCH_in_operator2738); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o1_tree = (Object)adaptor.create(o1);
                    adaptor.addChild(root_0, o1_tree);
                    }
                    LEFT_PAREN137=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator2740); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN137_tree = (Object)adaptor.create(LEFT_PAREN137);
                    adaptor.addChild(root_0, LEFT_PAREN137_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator2744);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    if ( state.backtracking==0 ) {
                       rexprs.add(e.result); 
                    }
                    RIGHT_PAREN138=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator2749); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN138_tree = (Object)adaptor.create(RIGHT_PAREN138);
                    adaptor.addChild(root_0, RIGHT_PAREN138_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		// Remove .
                            		retval.oper = (o1!=null?o1.getText():null);
                            		retval.exprs = rexprs;
                            	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1311:9: o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN
                    {
                    o2=(Token)match(input,REPLACE,FOLLOW_REPLACE_in_operator2774); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o2_tree = (Object)adaptor.create(o2);
                    adaptor.addChild(root_0, o2_tree);
                    }
                    LEFT_PAREN139=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator2776); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN139_tree = (Object)adaptor.create(LEFT_PAREN139);
                    adaptor.addChild(root_0, LEFT_PAREN139_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator2780);
                    rx=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, rx.getTree());
                    if ( state.backtracking==0 ) {
                      rexprs.add((rx!=null?rx.result:null)); 
                    }
                    char_literal140=(Token)match(input,COMMA,FOLLOW_COMMA_in_operator2784); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal140_tree = (Object)adaptor.create(char_literal140);
                    adaptor.addChild(root_0, char_literal140_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator2788);
                    e1=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
                    RIGHT_PAREN141=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator2791); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN141_tree = (Object)adaptor.create(RIGHT_PAREN141);
                    adaptor.addChild(root_0, RIGHT_PAREN141_tree);
                    }
                    if ( state.backtracking==0 ) {

                      	          rexprs.add(e1.result); 
                      	          
                            		// Remove .
                            		retval.oper = (o2!=null?o2.getText():null);
                            		retval.exprs = rexprs;
                            	
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "operator"

    public static class factor_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "factor"
    // RuleSet.g:1322:1: factor returns [Object result] options {backtrack=true; } : (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= VAR | CURRENT d= VAR_DOMAIN COLON v= VAR | HISTORY e= expr d= VAR_DOMAIN COLON v= VAR | n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex );
    public final RuleSetParser.factor_return factor() throws RecognitionException {
        RuleSetParser.factor_return retval = new RuleSetParser.factor_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token iv=null;
        Token sv=null;
        Token fv=null;
        Token bv=null;
        Token d=null;
        Token vv=null;
        Token v=null;
        Token p=null;
        Token LEFT_BRACKET142=null;
        Token RIGHT_BRACKET143=null;
        Token COLON144=null;
        Token CURRENT145=null;
        Token COLON146=null;
        Token HISTORY147=null;
        Token COLON148=null;
        Token LEFT_PAREN149=null;
        Token COMMA150=null;
        Token RIGHT_PAREN151=null;
        Token LEFT_PAREN152=null;
        Token COMMA153=null;
        Token RIGHT_PAREN154=null;
        Token LEFT_BRACKET155=null;
        Token COMMA156=null;
        Token RIGHT_BRACKET157=null;
        Token LEFT_CURL158=null;
        Token COMMA159=null;
        Token RIGHT_CURL160=null;
        Token LEFT_PAREN161=null;
        Token RIGHT_PAREN162=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.namespace_return n = null;

        RuleSetParser.expr_return e2 = null;

        RuleSetParser.hash_line_return h1 = null;

        RuleSetParser.hash_line_return h2 = null;

        RuleSetParser.regex_return reg = null;


        Object iv_tree=null;
        Object sv_tree=null;
        Object fv_tree=null;
        Object bv_tree=null;
        Object d_tree=null;
        Object vv_tree=null;
        Object v_tree=null;
        Object p_tree=null;
        Object LEFT_BRACKET142_tree=null;
        Object RIGHT_BRACKET143_tree=null;
        Object COLON144_tree=null;
        Object CURRENT145_tree=null;
        Object COLON146_tree=null;
        Object HISTORY147_tree=null;
        Object COLON148_tree=null;
        Object LEFT_PAREN149_tree=null;
        Object COMMA150_tree=null;
        Object RIGHT_PAREN151_tree=null;
        Object LEFT_PAREN152_tree=null;
        Object COMMA153_tree=null;
        Object RIGHT_PAREN154_tree=null;
        Object LEFT_BRACKET155_tree=null;
        Object COMMA156_tree=null;
        Object RIGHT_BRACKET157_tree=null;
        Object LEFT_CURL158_tree=null;
        Object COMMA159_tree=null;
        Object RIGHT_CURL160_tree=null;
        Object LEFT_PAREN161_tree=null;
        Object RIGHT_PAREN162_tree=null;


              ArrayList exprs2 = new ArrayList(); 


        try {
            // RuleSet.g:1327:2: (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= VAR | CURRENT d= VAR_DOMAIN COLON v= VAR | HISTORY e= expr d= VAR_DOMAIN COLON v= VAR | n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex )
            int alt99=15;
            alt99 = dfa99.predict(input);
            switch (alt99) {
                case 1 :
                    // RuleSet.g:1327:4: iv= INT
                    {
                    root_0 = (Object)adaptor.nil();

                    iv=(Token)match(input,INT,FOLLOW_INT_in_factor2831); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    iv_tree = (Object)adaptor.create(iv);
                    adaptor.addChild(root_0, iv_tree);
                    }
                    if ( state.backtracking==0 ) {
                       
                      		HashMap tmp = new HashMap();
                      		tmp.put("type","num");
                      		tmp.put("val",Long.parseLong((iv!=null?iv.getText():null)));
                      		retval.result = tmp;
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1333:9: sv= STRING
                    {
                    root_0 = (Object)adaptor.nil();

                    sv=(Token)match(input,STRING,FOLLOW_STRING_in_factor2846); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    sv_tree = (Object)adaptor.create(sv);
                    adaptor.addChild(root_0, sv_tree);
                    }
                    if ( state.backtracking==0 ) {
                        
                            		HashMap tmp = new HashMap();
                      		tmp.put("type","str");
                      		tmp.put("val",strip_string((sv!=null?sv.getText():null)));
                      		retval.result = tmp;
                      	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1339:9: fv= FLOAT
                    {
                    root_0 = (Object)adaptor.nil();

                    fv=(Token)match(input,FLOAT,FOLLOW_FLOAT_in_factor2866); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    fv_tree = (Object)adaptor.create(fv);
                    adaptor.addChild(root_0, fv_tree);
                    }
                    if ( state.backtracking==0 ) {
                       
                            		HashMap tmp = new HashMap();
                      		tmp.put("type","num");
                      		tmp.put("val",Float.parseFloat((fv!=null?fv.getText():null)));
                      		retval.result = tmp;
                      	
                    }

                    }
                    break;
                case 4 :
                    // RuleSet.g:1345:9: bv= ( TRUE | FALSE )
                    {
                    root_0 = (Object)adaptor.nil();

                    bv=(Token)input.LT(1);
                    if ( (input.LA(1)>=TRUE && input.LA(1)<=FALSE) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(bv));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    if ( state.backtracking==0 ) {
                       
                            		HashMap tmp = new HashMap();
                      		tmp.put("type","bool");
                      		tmp.put("val",(bv!=null?bv.getText():null));
                      		retval.result = tmp;
                      	
                    }

                    }
                    break;
                case 5 :
                    // RuleSet.g:1351:9: bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET
                    {
                    root_0 = (Object)adaptor.nil();

                    bv=(Token)match(input,VAR,FOLLOW_VAR_in_factor2906); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    bv_tree = (Object)adaptor.create(bv);
                    adaptor.addChild(root_0, bv_tree);
                    }
                    LEFT_BRACKET142=(Token)match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_factor2908); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_BRACKET142_tree = (Object)adaptor.create(LEFT_BRACKET142);
                    adaptor.addChild(root_0, LEFT_BRACKET142_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor2912);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    RIGHT_BRACKET143=(Token)match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_factor2914); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_BRACKET143_tree = (Object)adaptor.create(RIGHT_BRACKET143);
                    adaptor.addChild(root_0, RIGHT_BRACKET143_tree);
                    }
                    if ( state.backtracking==0 ) {
                       
                            		HashMap tmp = new HashMap();
                      		HashMap val = new HashMap();

                      		HashMap index = new HashMap();
                      		index.putAll((HashMap)(e!=null?e.result:null));
                      		val.put("var_expr",(bv!=null?bv.getText():null));

                      		val.put("index",index);
                      		tmp.put("type","array_ref");

                      		tmp.put("val",val);
                      		retval.result = tmp;
                            
                    }

                    }
                    break;
                case 6 :
                    // RuleSet.g:1365:9: d= VAR_DOMAIN COLON vv= VAR
                    {
                    root_0 = (Object)adaptor.nil();

                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor2929); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON144=(Token)match(input,COLON,FOLLOW_COLON_in_factor2931); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON144_tree = (Object)adaptor.create(COLON144);
                    adaptor.addChild(root_0, COLON144_tree);
                    }
                    vv=(Token)match(input,VAR,FOLLOW_VAR_in_factor2935); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vv_tree = (Object)adaptor.create(vv);
                    adaptor.addChild(root_0, vv_tree);
                    }
                    if ( state.backtracking==0 ) {

                      	      	HashMap tmp = new HashMap();
                      	      	tmp.put("domain",(d!=null?d.getText():null));
                      	      	tmp.put("name",(vv!=null?vv.getText():null));
                      	      	tmp.put("type","persistent");
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 7 :
                    // RuleSet.g:1372:9: CURRENT d= VAR_DOMAIN COLON v= VAR
                    {
                    root_0 = (Object)adaptor.nil();

                    CURRENT145=(Token)match(input,CURRENT,FOLLOW_CURRENT_in_factor2947); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    CURRENT145_tree = (Object)adaptor.create(CURRENT145);
                    adaptor.addChild(root_0, CURRENT145_tree);
                    }
                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor2951); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON146=(Token)match(input,COLON,FOLLOW_COLON_in_factor2953); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON146_tree = (Object)adaptor.create(COLON146);
                    adaptor.addChild(root_0, COLON146_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_factor2957); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("domain",(d!=null?d.getText():null));
                      	      	tmp.put("name",(v!=null?v.getText():null));
                      	      	tmp.put("type","persistent");
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 8 :
                    // RuleSet.g:1379:9: HISTORY e= expr d= VAR_DOMAIN COLON v= VAR
                    {
                    root_0 = (Object)adaptor.nil();

                    HISTORY147=(Token)match(input,HISTORY,FOLLOW_HISTORY_in_factor2970); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    HISTORY147_tree = (Object)adaptor.create(HISTORY147);
                    adaptor.addChild(root_0, HISTORY147_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor2974);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor2978); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON148=(Token)match(input,COLON,FOLLOW_COLON_in_factor2980); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON148_tree = (Object)adaptor.create(COLON148);
                    adaptor.addChild(root_0, COLON148_tree);
                    }
                    v=(Token)match(input,VAR,FOLLOW_VAR_in_factor2984); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {

                            	      	HashMap tmp = new HashMap();
                      	      	tmp.put("domain",(d!=null?d.getText():null));
                      	      	tmp.put("name",(v!=null?v.getText():null));
                      	      	tmp.put("type","trail_history");
                            	      	HashMap tmp2 = new HashMap();
                      	      	tmp2.putAll((HashMap)(e!=null?e.result:null));
                      	      	tmp.put("offset",tmp2);
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 9 :
                    // RuleSet.g:1389:9: n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_namespace_in_factor2998);
                    n=namespace();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, n.getTree());
                    p=(Token)match(input,VAR,FOLLOW_VAR_in_factor3002); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    p_tree = (Object)adaptor.create(p);
                    adaptor.addChild(root_0, p_tree);
                    }
                    LEFT_PAREN149=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3004); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN149_tree = (Object)adaptor.create(LEFT_PAREN149);
                    adaptor.addChild(root_0, LEFT_PAREN149_tree);
                    }
                    // RuleSet.g:1389:38: (e= expr ( COMMA e= expr )* )?
                    int alt92=2;
                    int LA92_0 = input.LA(1);

                    if ( (LA92_0==LEFT_CURL||(LA92_0>=VAR && LA92_0<=INT)||(LA92_0>=STRING && LA92_0<=VAR_DOMAIN)||(LA92_0>=REPLACE && LA92_0<=LEFT_PAREN)||LA92_0==NOT||LA92_0==FUNCTION||(LA92_0>=REX && LA92_0<=SEEN)||(LA92_0>=FLOAT && LA92_0<=LEFT_BRACKET)||(LA92_0>=CURRENT && LA92_0<=HISTORY)) ) {
                        alt92=1;
                    }
                    switch (alt92) {
                        case 1 :
                            // RuleSet.g:1389:39: e= expr ( COMMA e= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3009);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                               exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1389:73: ( COMMA e= expr )*
                            loop91:
                            do {
                                int alt91=2;
                                int LA91_0 = input.LA(1);

                                if ( (LA91_0==COMMA) ) {
                                    alt91=1;
                                }


                                switch (alt91) {
                            	case 1 :
                            	    // RuleSet.g:1389:75: COMMA e= expr
                            	    {
                            	    COMMA150=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3015); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA150_tree = (Object)adaptor.create(COMMA150);
                            	    adaptor.addChild(root_0, COMMA150_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3019);
                            	    e=expr();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            	    if ( state.backtracking==0 ) {
                            	       exprs2.add((e!=null?e.result:null));
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop91;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN151=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3028); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN151_tree = (Object)adaptor.create(RIGHT_PAREN151);
                    adaptor.addChild(root_0, RIGHT_PAREN151_tree);
                    }
                    if ( state.backtracking==0 ) {

                      	      	HashMap tmp = new HashMap();
                      	      	tmp.put("type","qualified");
                      	      	tmp.put("predicate",(p!=null?p.getText():null));
                      	      	tmp.put("source",(n!=null?input.toString(n.start,n.stop):null).substring(0,(n!=null?input.toString(n.start,n.stop):null).length() - 1));
                      	      	tmp.put("args",exprs2);
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 10 :
                    // RuleSet.g:1397:9: v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    v=(Token)match(input,VAR,FOLLOW_VAR_in_factor3043); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    LEFT_PAREN152=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3045); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN152_tree = (Object)adaptor.create(LEFT_PAREN152);
                    adaptor.addChild(root_0, LEFT_PAREN152_tree);
                    }
                    // RuleSet.g:1397:26: (e= expr ( COMMA e= expr )* )?
                    int alt94=2;
                    int LA94_0 = input.LA(1);

                    if ( (LA94_0==LEFT_CURL||(LA94_0>=VAR && LA94_0<=INT)||(LA94_0>=STRING && LA94_0<=VAR_DOMAIN)||(LA94_0>=REPLACE && LA94_0<=LEFT_PAREN)||LA94_0==NOT||LA94_0==FUNCTION||(LA94_0>=REX && LA94_0<=SEEN)||(LA94_0>=FLOAT && LA94_0<=LEFT_BRACKET)||(LA94_0>=CURRENT && LA94_0<=HISTORY)) ) {
                        alt94=1;
                    }
                    switch (alt94) {
                        case 1 :
                            // RuleSet.g:1397:27: e= expr ( COMMA e= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3050);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                                exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1397:61: ( COMMA e= expr )*
                            loop93:
                            do {
                                int alt93=2;
                                int LA93_0 = input.LA(1);

                                if ( (LA93_0==COMMA) ) {
                                    alt93=1;
                                }


                                switch (alt93) {
                            	case 1 :
                            	    // RuleSet.g:1397:63: COMMA e= expr
                            	    {
                            	    COMMA153=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3055); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA153_tree = (Object)adaptor.create(COMMA153);
                            	    adaptor.addChild(root_0, COMMA153_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3059);
                            	    e=expr();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            	    if ( state.backtracking==0 ) {
                            	        exprs2.add((e!=null?e.result:null)); 
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop93;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN154=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3068); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN154_tree = (Object)adaptor.create(RIGHT_PAREN154);
                    adaptor.addChild(root_0, RIGHT_PAREN154_tree);
                    }
                    if ( state.backtracking==0 ) {

                      	      	HashMap tmp = new HashMap();
                      	      	tmp.put("type","app");
                      	      	HashMap tmp2 = new HashMap();
                      	      	tmp2.put("val",(v!=null?v.getText():null));
                      	      	tmp2.put("type","var");
                      	      	tmp.put("function_expr",tmp2); 
                      	      	tmp.put("args",exprs2); 
                      	      	retval.result = tmp; 
                            
                            
                    }

                    }
                    break;
                case 11 :
                    // RuleSet.g:1408:9: LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_BRACKET155=(Token)match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_factor3080); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_BRACKET155_tree = (Object)adaptor.create(LEFT_BRACKET155);
                    adaptor.addChild(root_0, LEFT_BRACKET155_tree);
                    }
                    // RuleSet.g:1408:22: (e= expr ( COMMA e2= expr )* )?
                    int alt96=2;
                    int LA96_0 = input.LA(1);

                    if ( (LA96_0==LEFT_CURL||(LA96_0>=VAR && LA96_0<=INT)||(LA96_0>=STRING && LA96_0<=VAR_DOMAIN)||(LA96_0>=REPLACE && LA96_0<=LEFT_PAREN)||LA96_0==NOT||LA96_0==FUNCTION||(LA96_0>=REX && LA96_0<=SEEN)||(LA96_0>=FLOAT && LA96_0<=LEFT_BRACKET)||(LA96_0>=CURRENT && LA96_0<=HISTORY)) ) {
                        alt96=1;
                    }
                    switch (alt96) {
                        case 1 :
                            // RuleSet.g:1408:23: e= expr ( COMMA e2= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3085);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                               exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1408:57: ( COMMA e2= expr )*
                            loop95:
                            do {
                                int alt95=2;
                                int LA95_0 = input.LA(1);

                                if ( (LA95_0==COMMA) ) {
                                    alt95=1;
                                }


                                switch (alt95) {
                            	case 1 :
                            	    // RuleSet.g:1408:58: COMMA e2= expr
                            	    {
                            	    COMMA156=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3090); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA156_tree = (Object)adaptor.create(COMMA156);
                            	    adaptor.addChild(root_0, COMMA156_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3094);
                            	    e2=expr();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, e2.getTree());
                            	    if ( state.backtracking==0 ) {
                            	      	exprs2.add((e2!=null?e2.result:null));
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop95;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_BRACKET157=(Token)match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_factor3102); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_BRACKET157_tree = (Object)adaptor.create(RIGHT_BRACKET157);
                    adaptor.addChild(root_0, RIGHT_BRACKET157_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		HashMap tmp = new HashMap();
                            		tmp.put("val",exprs2);	
                            		tmp.put("type","array");
                            		  
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 12 :
                    // RuleSet.g:1415:9: LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_CURL158=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_factor3114); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_CURL158_tree = (Object)adaptor.create(LEFT_CURL158);
                    adaptor.addChild(root_0, LEFT_CURL158_tree);
                    }
                    // RuleSet.g:1415:19: (h1= hash_line ( COMMA h2= hash_line )* )?
                    int alt98=2;
                    int LA98_0 = input.LA(1);

                    if ( (LA98_0==STRING) ) {
                        alt98=1;
                    }
                    switch (alt98) {
                        case 1 :
                            // RuleSet.g:1415:20: h1= hash_line ( COMMA h2= hash_line )*
                            {
                            pushFollow(FOLLOW_hash_line_in_factor3119);
                            h1=hash_line();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, h1.getTree());
                            if ( state.backtracking==0 ) {
                                exprs2.add((h1!=null?h1.result:null));
                            }
                            // RuleSet.g:1415:61: ( COMMA h2= hash_line )*
                            loop97:
                            do {
                                int alt97=2;
                                int LA97_0 = input.LA(1);

                                if ( (LA97_0==COMMA) ) {
                                    alt97=1;
                                }


                                switch (alt97) {
                            	case 1 :
                            	    // RuleSet.g:1415:62: COMMA h2= hash_line
                            	    {
                            	    COMMA159=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3124); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA159_tree = (Object)adaptor.create(COMMA159);
                            	    adaptor.addChild(root_0, COMMA159_tree);
                            	    }
                            	    pushFollow(FOLLOW_hash_line_in_factor3128);
                            	    h2=hash_line();

                            	    state._fsp--;
                            	    if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, h2.getTree());
                            	    if ( state.backtracking==0 ) {
                            	       exprs2.add((h2!=null?h2.result:null)); 
                            	    }

                            	    }
                            	    break;

                            	default :
                            	    break loop97;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_CURL160=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_factor3137); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_CURL160_tree = (Object)adaptor.create(RIGHT_CURL160);
                    adaptor.addChild(root_0, RIGHT_CURL160_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		HashMap tmp = new HashMap();
                            		tmp.put("val",exprs2);	
                            		tmp.put("type","hashraw");
                            		 
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 13 :
                    // RuleSet.g:1422:9: LEFT_PAREN e= expr RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_PAREN161=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3149); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN161_tree = (Object)adaptor.create(LEFT_PAREN161);
                    adaptor.addChild(root_0, LEFT_PAREN161_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor3153);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    RIGHT_PAREN162=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3156); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN162_tree = (Object)adaptor.create(RIGHT_PAREN162);
                    adaptor.addChild(root_0, RIGHT_PAREN162_tree);
                    }
                    if ( state.backtracking==0 ) {
                       retval.result =(e!=null?e.result:null); 
                    }

                    }
                    break;
                case 14 :
                    // RuleSet.g:1423:9: v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH )
                    {
                    root_0 = (Object)adaptor.nil();

                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=REPLACE && input.LA(1)<=OTHER_OPERATORS) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    if ( state.backtracking==0 ) {
                       
                            		HashMap tmp = new HashMap(); 
                      		tmp.put("type","var"); 
                      		tmp.put("val",(v!=null?v.getText():null));
                      		retval.result = tmp;
                            
                    }

                    }
                    break;
                case 15 :
                    // RuleSet.g:1429:9: reg= regex
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_regex_in_factor3199);
                    reg=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, reg.getTree());
                    if ( state.backtracking==0 ) {

                      	      HashMap tmp = new HashMap(); 
                      		tmp.put("type","var"); 
                      		tmp.put("val",(reg!=null?reg.result:null));
                      		retval.result = tmp;
                            	
                    }

                    }
                    break;

            }
            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "factor"

    public static class namespace_return extends ParserRuleReturnScope {
        public String result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "namespace"
    // RuleSet.g:1442:10: fragment namespace returns [String result] : v= VAR ':' ;
    public final RuleSetParser.namespace_return namespace() throws RecognitionException {
        RuleSetParser.namespace_return retval = new RuleSetParser.namespace_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token char_literal163=null;

        Object v_tree=null;
        Object char_literal163_tree=null;

        try {
            // RuleSet.g:1443:2: (v= VAR ':' )
            // RuleSet.g:1443:4: v= VAR ':'
            {
            root_0 = (Object)adaptor.nil();

            v=(Token)match(input,VAR,FOLLOW_VAR_in_namespace3232); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            v_tree = (Object)adaptor.create(v);
            adaptor.addChild(root_0, v_tree);
            }
            char_literal163=(Token)match(input,COLON,FOLLOW_COLON_in_namespace3234); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            char_literal163_tree = (Object)adaptor.create(char_literal163);
            adaptor.addChild(root_0, char_literal163_tree);
            }
            if ( state.backtracking==0 ) {

              		retval.result = (v!=null?v.getText():null);
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "namespace"

    public static class timeframe_return extends ParserRuleReturnScope {
        public Object result;
        public String time;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "timeframe"
    // RuleSet.g:1450:1: timeframe returns [Object result,String time] : WITHIN e= expr p= period ;
    public final RuleSetParser.timeframe_return timeframe() throws RecognitionException {
        RuleSetParser.timeframe_return retval = new RuleSetParser.timeframe_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITHIN164=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.period_return p = null;


        Object WITHIN164_tree=null;

        try {
            // RuleSet.g:1451:2: ( WITHIN e= expr p= period )
            // RuleSet.g:1451:5: WITHIN e= expr p= period
            {
            root_0 = (Object)adaptor.nil();

            WITHIN164=(Token)match(input,WITHIN,FOLLOW_WITHIN_in_timeframe3256); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITHIN164_tree = (Object)adaptor.create(WITHIN164);
            adaptor.addChild(root_0, WITHIN164_tree);
            }
            pushFollow(FOLLOW_expr_in_timeframe3260);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_period_in_timeframe3264);
            p=period();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
            if ( state.backtracking==0 ) {

              		retval.result = (e!=null?e.result:null);
              		retval.time = fix_time((p!=null?input.toString(p.start,p.stop):null));
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "timeframe"

    public static class hash_line_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "hash_line"
    // RuleSet.g:1459:1: hash_line returns [HashMap result] : s= STRING COLON e= expr ;
    public final RuleSetParser.hash_line_return hash_line() throws RecognitionException {
        RuleSetParser.hash_line_return retval = new RuleSetParser.hash_line_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token s=null;
        Token COLON165=null;
        RuleSetParser.expr_return e = null;


        Object s_tree=null;
        Object COLON165_tree=null;

        try {
            // RuleSet.g:1460:2: (s= STRING COLON e= expr )
            // RuleSet.g:1460:4: s= STRING COLON e= expr
            {
            root_0 = (Object)adaptor.nil();

            s=(Token)match(input,STRING,FOLLOW_STRING_in_hash_line3291); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            s_tree = (Object)adaptor.create(s);
            adaptor.addChild(root_0, s_tree);
            }
            COLON165=(Token)match(input,COLON,FOLLOW_COLON_in_hash_line3293); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON165_tree = (Object)adaptor.create(COLON165);
            adaptor.addChild(root_0, COLON165_tree);
            }
            pushFollow(FOLLOW_expr_in_hash_line3297);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              		tmp.put("lhs",strip_string((s!=null?s.getText():null)));
              		tmp.put("rhs",(e!=null?e.result:null));
              //		tmp.put("val",(e!=null?e.result:null));
              		retval.result = tmp;
              	
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "hash_line"

    public static class css_emit_return extends ParserRuleReturnScope {
        public String emit_value;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "css_emit"
    // RuleSet.g:1469:1: css_emit returns [String emit_value] : CSS (h= HTML | h= STRING ) ;
    public final RuleSetParser.css_emit_return css_emit() throws RecognitionException {
        RuleSetParser.css_emit_return retval = new RuleSetParser.css_emit_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token h=null;
        Token CSS166=null;

        Object h_tree=null;
        Object CSS166_tree=null;

        try {
            // RuleSet.g:1470:2: ( CSS (h= HTML | h= STRING ) )
            // RuleSet.g:1470:4: CSS (h= HTML | h= STRING )
            {
            root_0 = (Object)adaptor.nil();

            CSS166=(Token)match(input,CSS,FOLLOW_CSS_in_css_emit3315); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            CSS166_tree = (Object)adaptor.create(CSS166);
            adaptor.addChild(root_0, CSS166_tree);
            }
            // RuleSet.g:1470:8: (h= HTML | h= STRING )
            int alt100=2;
            int LA100_0 = input.LA(1);

            if ( (LA100_0==HTML) ) {
                alt100=1;
            }
            else if ( (LA100_0==STRING) ) {
                alt100=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 100, 0, input);

                throw nvae;
            }
            switch (alt100) {
                case 1 :
                    // RuleSet.g:1470:10: h= HTML
                    {
                    h=(Token)match(input,HTML,FOLLOW_HTML_in_css_emit3321); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    h_tree = (Object)adaptor.create(h);
                    adaptor.addChild(root_0, h_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.emit_value = strip_wrappers("<<",">>",(h!=null?h.getText():null));
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1471:3: h= STRING
                    {
                    h=(Token)match(input,STRING,FOLLOW_STRING_in_css_emit3329); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    h_tree = (Object)adaptor.create(h);
                    adaptor.addChild(root_0, h_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.emit_value = strip_string((h!=null?h.getText():null));
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "css_emit"

    public static class period_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "period"
    // RuleSet.g:1475:1: period : must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")] ;
    public final RuleSetParser.period_return period() throws RecognitionException {
        RuleSetParser.period_return retval = new RuleSetParser.period_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.must_be_one_return must_be_one167 = null;



        try {
            // RuleSet.g:1476:2: ( must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")] )
            // RuleSet.g:1477:3: must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")]
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_period3349);
            must_be_one167=must_be_one(sar( "years", "months", "weeks", "days", "hours", "minutes", "seconds", "year", "month", "week", "day", "hour", "minute", "second"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be_one167.getTree());

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "period"

    public static class cachable_return extends ParserRuleReturnScope {
        public Object what;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "cachable"
    // RuleSet.g:1497:1: cachable returns [Object what] : ca= CACHABLE ( FOR tm= INT per= period )? ;
    public final RuleSetParser.cachable_return cachable() throws RecognitionException {
        RuleSetParser.cachable_return retval = new RuleSetParser.cachable_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ca=null;
        Token tm=null;
        Token FOR168=null;
        RuleSetParser.period_return per = null;


        Object ca_tree=null;
        Object tm_tree=null;
        Object FOR168_tree=null;


        	retval.what = null;

        try {
            // RuleSet.g:1501:2: (ca= CACHABLE ( FOR tm= INT per= period )? )
            // RuleSet.g:1502:3: ca= CACHABLE ( FOR tm= INT per= period )?
            {
            root_0 = (Object)adaptor.nil();

            ca=(Token)match(input,CACHABLE,FOLLOW_CACHABLE_in_cachable3383); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            ca_tree = (Object)adaptor.create(ca);
            adaptor.addChild(root_0, ca_tree);
            }
            // RuleSet.g:1502:15: ( FOR tm= INT per= period )?
            int alt101=2;
            int LA101_0 = input.LA(1);

            if ( (LA101_0==FOR) ) {
                alt101=1;
            }
            switch (alt101) {
                case 1 :
                    // RuleSet.g:1502:16: FOR tm= INT per= period
                    {
                    FOR168=(Token)match(input,FOR,FOLLOW_FOR_in_cachable3386); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    FOR168_tree = (Object)adaptor.create(FOR168);
                    adaptor.addChild(root_0, FOR168_tree);
                    }
                    tm=(Token)match(input,INT,FOLLOW_INT_in_cachable3390); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    tm_tree = (Object)adaptor.create(tm);
                    adaptor.addChild(root_0, tm_tree);
                    }
                    pushFollow(FOLLOW_period_in_cachable3394);
                    per=period();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, per.getTree());

                    }
                    break;

            }

            if ( state.backtracking==0 ) {

               			if((tm!=null?tm.getText():null) != null)
               			{
              	 			retval.what = new HashMap();
              	 			((HashMap)retval.what).put("value",(tm!=null?tm.getText():null));
              	 			((HashMap)retval.what).put("period",fix_time((per!=null?input.toString(per.start,per.stop):null)));	 			
              	 		}
              	 		else if((ca!=null?ca.getText():null) != null)
              	 		{
              	 			retval.what = new Long(1);
              	 		}
              	 		else
              	 		{
              	 			retval.what = new Long(0);
              	 		}
               		
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "cachable"

    public static class emit_block_return extends ParserRuleReturnScope {
        public String emit_value;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "emit_block"
    // RuleSet.g:1521:1: emit_block returns [String emit_value] : EMIT (h= HTML | h= STRING | h= JS ) ;
    public final RuleSetParser.emit_block_return emit_block() throws RecognitionException {
        RuleSetParser.emit_block_return retval = new RuleSetParser.emit_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token h=null;
        Token EMIT169=null;

        Object h_tree=null;
        Object EMIT169_tree=null;

        try {
            // RuleSet.g:1522:2: ( EMIT (h= HTML | h= STRING | h= JS ) )
            // RuleSet.g:1522:4: EMIT (h= HTML | h= STRING | h= JS )
            {
            root_0 = (Object)adaptor.nil();

            EMIT169=(Token)match(input,EMIT,FOLLOW_EMIT_in_emit_block3416); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EMIT169_tree = (Object)adaptor.create(EMIT169);
            adaptor.addChild(root_0, EMIT169_tree);
            }
            // RuleSet.g:1522:9: (h= HTML | h= STRING | h= JS )
            int alt102=3;
            switch ( input.LA(1) ) {
            case HTML:
                {
                alt102=1;
                }
                break;
            case STRING:
                {
                alt102=2;
                }
                break;
            case JS:
                {
                alt102=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 102, 0, input);

                throw nvae;
            }

            switch (alt102) {
                case 1 :
                    // RuleSet.g:1522:11: h= HTML
                    {
                    h=(Token)match(input,HTML,FOLLOW_HTML_in_emit_block3422); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    h_tree = (Object)adaptor.create(h);
                    adaptor.addChild(root_0, h_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.emit_value = strip_wrappers("<<",">>",(h!=null?h.getText():null));
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1523:3: h= STRING
                    {
                    h=(Token)match(input,STRING,FOLLOW_STRING_in_emit_block3430); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    h_tree = (Object)adaptor.create(h);
                    adaptor.addChild(root_0, h_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.emit_value = strip_string((h!=null?h.getText():null));
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1524:3: h= JS
                    {
                    h=(Token)match(input,JS,FOLLOW_JS_in_emit_block3438); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    h_tree = (Object)adaptor.create(h);
                    adaptor.addChild(root_0, h_tree);
                    }
                    if ( state.backtracking==0 ) {
                      retval.emit_value = strip_wrappers("<|","|>",(h!=null?h.getText():null));
                    }

                    }
                    break;

            }


            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "emit_block"

    public static class meta_block_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "meta_block"
    // RuleSet.g:1527:1: meta_block : META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL ;
    public final RuleSetParser.meta_block_return meta_block() throws RecognitionException {
        RuleSetParser.meta_block_return retval = new RuleSetParser.meta_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token html_desc=null;
        Token string_desc=null;
        Token key_value=null;
        Token onoff=null;
        Token rtype=null;
        Token url=null;
        Token nicename=null;
        Token modname=null;
        Token alias=null;
        Token META170=null;
        Token LEFT_CURL171=null;
        Token KEY172=null;
        Token LEFT_CURL173=null;
        Token COMMA175=null;
        Token RIGHT_CURL177=null;
        Token AUTHZ178=null;
        Token REQUIRE179=null;
        Token LOGGING181=null;
        Token USE182=null;
        Token MODULE184=null;
        Token ALIAS185=null;
        Token RIGHT_CURL186=null;
        RuleSetParser.must_be_one_return name = null;

        RuleSetParser.must_be_one_return what = null;

        RuleSetParser.name_value_pair_return name_value_pair174 = null;

        RuleSetParser.name_value_pair_return name_value_pair176 = null;

        RuleSetParser.must_be_return must_be180 = null;

        RuleSetParser.must_be_return must_be183 = null;


        Object html_desc_tree=null;
        Object string_desc_tree=null;
        Object key_value_tree=null;
        Object onoff_tree=null;
        Object rtype_tree=null;
        Object url_tree=null;
        Object nicename_tree=null;
        Object modname_tree=null;
        Object alias_tree=null;
        Object META170_tree=null;
        Object LEFT_CURL171_tree=null;
        Object KEY172_tree=null;
        Object LEFT_CURL173_tree=null;
        Object COMMA175_tree=null;
        Object RIGHT_CURL177_tree=null;
        Object AUTHZ178_tree=null;
        Object REQUIRE179_tree=null;
        Object LOGGING181_tree=null;
        Object USE182_tree=null;
        Object MODULE184_tree=null;
        Object ALIAS185_tree=null;
        Object RIGHT_CURL186_tree=null;


        	 HashMap meta_block_hash = (HashMap)rule_json.get("meta");
        	 ArrayList use_list = new ArrayList();
        	 HashMap keys_map = new HashMap();
        	 HashMap key_values = new HashMap();

        try {
            // RuleSet.g:1544:2: ( META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL )
            // RuleSet.g:1544:4: META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            META170=(Token)match(input,META,FOLLOW_META_in_meta_block3467); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            META170_tree = (Object)adaptor.create(META170);
            adaptor.addChild(root_0, META170_tree);
            }
            LEFT_CURL171=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_meta_block3469); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL171_tree = (Object)adaptor.create(LEFT_CURL171);
            adaptor.addChild(root_0, LEFT_CURL171_tree);
            }
            // RuleSet.g:1545:2: (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )*
            loop109:
            do {
                int alt109=6;
                switch ( input.LA(1) ) {
                case VAR:
                    {
                    alt109=1;
                    }
                    break;
                case KEY:
                    {
                    alt109=2;
                    }
                    break;
                case AUTHZ:
                    {
                    alt109=3;
                    }
                    break;
                case LOGGING:
                    {
                    alt109=4;
                    }
                    break;
                case USE:
                    {
                    alt109=5;
                    }
                    break;

                }

                switch (alt109) {
            	case 1 :
            	    // RuleSet.g:1545:5: name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING )
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_meta_block3478);
            	    name=must_be_one(sar("description","name","author"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name.getTree());
            	    // RuleSet.g:1545:58: (html_desc= HTML | string_desc= STRING )
            	    int alt103=2;
            	    int LA103_0 = input.LA(1);

            	    if ( (LA103_0==HTML) ) {
            	        alt103=1;
            	    }
            	    else if ( (LA103_0==STRING) ) {
            	        alt103=2;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        NoViableAltException nvae =
            	            new NoViableAltException("", 103, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt103) {
            	        case 1 :
            	            // RuleSet.g:1545:59: html_desc= HTML
            	            {
            	            html_desc=(Token)match(input,HTML,FOLLOW_HTML_in_meta_block3484); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            html_desc_tree = (Object)adaptor.create(html_desc);
            	            adaptor.addChild(root_0, html_desc_tree);
            	            }

            	            }
            	            break;
            	        case 2 :
            	            // RuleSet.g:1545:74: string_desc= STRING
            	            {
            	            string_desc=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3488); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            string_desc_tree = (Object)adaptor.create(string_desc);
            	            adaptor.addChild(root_0, string_desc_tree);
            	            }

            	            }
            	            break;

            	    }

            	    if ( state.backtracking==0 ) {
            	       
            	      			if((string_desc!=null?string_desc.getText():null) != null)
            	      				meta_block_hash.put((name!=null?input.toString(name.start,name.stop):null),strip_string((string_desc!=null?string_desc.getText():null))); 
            	      			else
            	      				meta_block_hash.put((name!=null?input.toString(name.start,name.stop):null),strip_wrappers("<<",">>",(html_desc!=null?html_desc.getText():null))); 
            	      			html_desc = null;
            	      			string_desc = null;
            	      	
            	      		
            	    }

            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:1555:5: KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+
            	    {
            	    KEY172=(Token)match(input,KEY,FOLLOW_KEY_in_meta_block3502); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    KEY172_tree = (Object)adaptor.create(KEY172);
            	    adaptor.addChild(root_0, KEY172_tree);
            	    }
            	    pushFollow(FOLLOW_must_be_one_in_meta_block3506);
            	    what=must_be_one(sar("errorstack","googleanalytics","facebook","twitter","amazon","kpds","google"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, what.getTree());
            	    // RuleSet.g:1555:109: (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+
            	    int cnt105=0;
            	    loop105:
            	    do {
            	        int alt105=3;
            	        int LA105_0 = input.LA(1);

            	        if ( (LA105_0==STRING) ) {
            	            alt105=1;
            	        }
            	        else if ( (LA105_0==LEFT_CURL) ) {
            	            alt105=2;
            	        }


            	        switch (alt105) {
            	    	case 1 :
            	    	    // RuleSet.g:1555:110: key_value= STRING
            	    	    {
            	    	    key_value=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3512); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    key_value_tree = (Object)adaptor.create(key_value);
            	    	    adaptor.addChild(root_0, key_value_tree);
            	    	    }

            	    	    }
            	    	    break;
            	    	case 2 :
            	    	    // RuleSet.g:1556:6: LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL
            	    	    {
            	    	    LEFT_CURL173=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_meta_block3520); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    LEFT_CURL173_tree = (Object)adaptor.create(LEFT_CURL173);
            	    	    adaptor.addChild(root_0, LEFT_CURL173_tree);
            	    	    }
            	    	    // RuleSet.g:1556:16: ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* )
            	    	    // RuleSet.g:1556:17: name_value_pair[key_values] ( COMMA name_value_pair[key_values] )*
            	    	    {
            	    	    pushFollow(FOLLOW_name_value_pair_in_meta_block3523);
            	    	    name_value_pair174=name_value_pair(key_values);

            	    	    state._fsp--;
            	    	    if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name_value_pair174.getTree());
            	    	    // RuleSet.g:1556:45: ( COMMA name_value_pair[key_values] )*
            	    	    loop104:
            	    	    do {
            	    	        int alt104=2;
            	    	        int LA104_0 = input.LA(1);

            	    	        if ( (LA104_0==COMMA) ) {
            	    	            alt104=1;
            	    	        }


            	    	        switch (alt104) {
            	    	    	case 1 :
            	    	    	    // RuleSet.g:1556:46: COMMA name_value_pair[key_values]
            	    	    	    {
            	    	    	    COMMA175=(Token)match(input,COMMA,FOLLOW_COMMA_in_meta_block3527); if (state.failed) return retval;
            	    	    	    if ( state.backtracking==0 ) {
            	    	    	    COMMA175_tree = (Object)adaptor.create(COMMA175);
            	    	    	    adaptor.addChild(root_0, COMMA175_tree);
            	    	    	    }
            	    	    	    pushFollow(FOLLOW_name_value_pair_in_meta_block3529);
            	    	    	    name_value_pair176=name_value_pair(key_values);

            	    	    	    state._fsp--;
            	    	    	    if (state.failed) return retval;
            	    	    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name_value_pair176.getTree());

            	    	    	    }
            	    	    	    break;

            	    	    	default :
            	    	    	    break loop104;
            	    	        }
            	    	    } while (true);


            	    	    }

            	    	    RIGHT_CURL177=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_meta_block3535); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    RIGHT_CURL177_tree = (Object)adaptor.create(RIGHT_CURL177);
            	    	    adaptor.addChild(root_0, RIGHT_CURL177_tree);
            	    	    }

            	    	    }
            	    	    break;

            	    	default :
            	    	    if ( cnt105 >= 1 ) break loop105;
            	    	    if (state.backtracking>0) {state.failed=true; return retval;}
            	                EarlyExitException eee =
            	                    new EarlyExitException(105, input);
            	                throw eee;
            	        }
            	        cnt105++;
            	    } while (true);

            	    if ( state.backtracking==0 ) {
            	       
            	      		if(!key_values.isEmpty()) 
            	      			keys_map.put((what!=null?input.toString(what.start,what.stop):null),key_values); 
            	      		else 
            	      			keys_map.put((what!=null?input.toString(what.start,what.stop):null),strip_string((key_value!=null?key_value.getText():null))); 
            	      	
            	    }

            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:1562:4: AUTHZ REQUIRE must_be[\"user\"]
            	    {
            	    AUTHZ178=(Token)match(input,AUTHZ,FOLLOW_AUTHZ_in_meta_block3547); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AUTHZ178_tree = (Object)adaptor.create(AUTHZ178);
            	    adaptor.addChild(root_0, AUTHZ178_tree);
            	    }
            	    REQUIRE179=(Token)match(input,REQUIRE,FOLLOW_REQUIRE_in_meta_block3549); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    REQUIRE179_tree = (Object)adaptor.create(REQUIRE179);
            	    adaptor.addChild(root_0, REQUIRE179_tree);
            	    }
            	    pushFollow(FOLLOW_must_be_in_meta_block3551);
            	    must_be180=must_be("user");

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be180.getTree());
            	    if ( state.backtracking==0 ) {
            	        
            	      		HashMap tmp = new HashMap(); 
            	      		tmp.put("level","user");
            	      		tmp.put("type","required");
            	      		meta_block_hash.put("authz",tmp);
            	      	   
            	    }

            	    }
            	    break;
            	case 4 :
            	    // RuleSet.g:1568:4: LOGGING onoff= ( ON | OFF )
            	    {
            	    LOGGING181=(Token)match(input,LOGGING,FOLLOW_LOGGING_in_meta_block3560); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    LOGGING181_tree = (Object)adaptor.create(LOGGING181);
            	    adaptor.addChild(root_0, LOGGING181_tree);
            	    }
            	    onoff=(Token)input.LT(1);
            	    if ( input.LA(1)==ON||input.LA(1)==OFF ) {
            	        input.consume();
            	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(onoff));
            	        state.errorRecovery=false;state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }

            	    if ( state.backtracking==0 ) {
            	        meta_block_hash.put("logging",(onoff!=null?onoff.getText():null)); 
            	    }

            	    }
            	    break;
            	case 5 :
            	    // RuleSet.g:1569:4: USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) )
            	    {
            	    USE182=(Token)match(input,USE,FOLLOW_USE_in_meta_block3575); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    USE182_tree = (Object)adaptor.create(USE182);
            	    adaptor.addChild(root_0, USE182_tree);
            	    }
            	    // RuleSet.g:1569:8: ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) )
            	    int alt108=2;
            	    int LA108_0 = input.LA(1);

            	    if ( (LA108_0==CSS||LA108_0==JAVASCRIPT) ) {
            	        alt108=1;
            	    }
            	    else if ( (LA108_0==MODULE) ) {
            	        alt108=2;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        NoViableAltException nvae =
            	            new NoViableAltException("", 108, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt108) {
            	        case 1 :
            	            // RuleSet.g:1569:10: (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) )
            	            {
            	            // RuleSet.g:1569:10: (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) )
            	            // RuleSet.g:1569:11: rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR )
            	            {
            	            rtype=(Token)input.LT(1);
            	            if ( input.LA(1)==CSS||input.LA(1)==JAVASCRIPT ) {
            	                input.consume();
            	                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(rtype));
            	                state.errorRecovery=false;state.failed=false;
            	            }
            	            else {
            	                if (state.backtracking>0) {state.failed=true; return retval;}
            	                MismatchedSetException mse = new MismatchedSetException(null,input);
            	                throw mse;
            	            }

            	            pushFollow(FOLLOW_must_be_in_meta_block3588);
            	            must_be183=must_be("resource");

            	            state._fsp--;
            	            if (state.failed) return retval;
            	            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be183.getTree());
            	            // RuleSet.g:1569:54: (url= STRING | nicename= VAR )
            	            int alt106=2;
            	            int LA106_0 = input.LA(1);

            	            if ( (LA106_0==STRING) ) {
            	                alt106=1;
            	            }
            	            else if ( (LA106_0==VAR) ) {
            	                alt106=2;
            	            }
            	            else {
            	                if (state.backtracking>0) {state.failed=true; return retval;}
            	                NoViableAltException nvae =
            	                    new NoViableAltException("", 106, 0, input);

            	                throw nvae;
            	            }
            	            switch (alt106) {
            	                case 1 :
            	                    // RuleSet.g:1569:55: url= STRING
            	                    {
            	                    url=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3594); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    url_tree = (Object)adaptor.create(url);
            	                    adaptor.addChild(root_0, url_tree);
            	                    }

            	                    }
            	                    break;
            	                case 2 :
            	                    // RuleSet.g:1569:68: nicename= VAR
            	                    {
            	                    nicename=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3600); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    nicename_tree = (Object)adaptor.create(nicename);
            	                    adaptor.addChild(root_0, nicename_tree);
            	                    }

            	                    }
            	                    break;

            	            }

            	            if ( state.backtracking==0 ) {

            	              		HashMap tmp = new HashMap();  
            	              		HashMap tmp2 = new HashMap();
            	              		if((url!=null?url.getText():null) != null)
            	              		{
            	              			tmp2.put("location",strip_string((url!=null?url.getText():null)));
            	              			tmp2.put("type","url");
            	              		}
            	              		else
            	              		{ 
            	              			tmp2.put("location",(nicename!=null?nicename.getText():null)); 
            	              			tmp2.put("type","name");			
            	              		} 
            	              		tmp.put("resource",tmp2);
            	              		
            	              		tmp.put("name",(name!=null?input.toString(name.start,name.stop):null));
            	              		tmp.put("resource_type",(rtype!=null?rtype.getText():null));
            	              		use_list.add(tmp);
            	              	 
            	            }

            	            }


            	            }
            	            break;
            	        case 2 :
            	            // RuleSet.g:1588:6: ( MODULE modname= VAR ( ALIAS alias= VAR )? )
            	            {
            	            // RuleSet.g:1588:6: ( MODULE modname= VAR ( ALIAS alias= VAR )? )
            	            // RuleSet.g:1588:7: MODULE modname= VAR ( ALIAS alias= VAR )?
            	            {
            	            MODULE184=(Token)match(input,MODULE,FOLLOW_MODULE_in_meta_block3615); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            MODULE184_tree = (Object)adaptor.create(MODULE184);
            	            adaptor.addChild(root_0, MODULE184_tree);
            	            }
            	            modname=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3620); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            modname_tree = (Object)adaptor.create(modname);
            	            adaptor.addChild(root_0, modname_tree);
            	            }
            	            // RuleSet.g:1588:27: ( ALIAS alias= VAR )?
            	            int alt107=2;
            	            int LA107_0 = input.LA(1);

            	            if ( (LA107_0==ALIAS) ) {
            	                alt107=1;
            	            }
            	            switch (alt107) {
            	                case 1 :
            	                    // RuleSet.g:1588:28: ALIAS alias= VAR
            	                    {
            	                    ALIAS185=(Token)match(input,ALIAS,FOLLOW_ALIAS_in_meta_block3623); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    ALIAS185_tree = (Object)adaptor.create(ALIAS185);
            	                    adaptor.addChild(root_0, ALIAS185_tree);
            	                    }
            	                    alias=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3627); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    alias_tree = (Object)adaptor.create(alias);
            	                    adaptor.addChild(root_0, alias_tree);
            	                    }

            	                    }
            	                    break;

            	            }


            	            }

            	            if ( state.backtracking==0 ) {

            	              		HashMap tmp = new HashMap(); 
            	              		tmp.put("name",(modname!=null?modname.getText():null));
            	              		tmp.put("type","module");
            	              		if((alias!=null?alias.getText():null) != null) {
            	              			tmp.put("alias",(alias!=null?alias.getText():null));
            	              		}
            	              		use_list.add(tmp);
            	              	 
            	            }

            	            }
            	            break;

            	    }


            	    }
            	    break;

            	default :
            	    break loop109;
                }
            } while (true);

            RIGHT_CURL186=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_meta_block3642); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL186_tree = (Object)adaptor.create(RIGHT_CURL186);
            adaptor.addChild(root_0, RIGHT_CURL186_tree);
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
            if ( state.backtracking==0 ) {

              	if(!keys_map.isEmpty())
              	{
              		meta_block_hash.put("keys",keys_map);
              	}
              	if(!use_list.isEmpty())
              	{
              		meta_block_hash.put("use",use_list);
              	}

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "meta_block"

    public static class dispatch_block_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "dispatch_block"
    // RuleSet.g:1602:1: dispatch_block : must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL ;
    public final RuleSetParser.dispatch_block_return dispatch_block() throws RecognitionException {
        RuleSetParser.dispatch_block_return retval = new RuleSetParser.dispatch_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token domain=null;
        Token rsid=null;
        Token LEFT_CURL188=null;
        Token RIGHT_SMALL_ARROW190=null;
        Token RIGHT_CURL191=null;
        RuleSetParser.must_be_return must_be187 = null;

        RuleSetParser.must_be_return must_be189 = null;


        Object domain_tree=null;
        Object rsid_tree=null;
        Object LEFT_CURL188_tree=null;
        Object RIGHT_SMALL_ARROW190_tree=null;
        Object RIGHT_CURL191_tree=null;


        	 ArrayList dispatch_block_array = (ArrayList)rule_json.get("dispatch");

        try {
            // RuleSet.g:1608:2: ( must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL )
            // RuleSet.g:1608:4: must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_dispatch_block3673);
            must_be187=must_be("dispatch");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be187.getTree());
            LEFT_CURL188=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_dispatch_block3677); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL188_tree = (Object)adaptor.create(LEFT_CURL188);
            adaptor.addChild(root_0, LEFT_CURL188_tree);
            }
            // RuleSet.g:1608:35: ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )*
            loop111:
            do {
                int alt111=2;
                int LA111_0 = input.LA(1);

                if ( (LA111_0==VAR) ) {
                    alt111=1;
                }


                switch (alt111) {
            	case 1 :
            	    // RuleSet.g:1608:37: must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )?
            	    {
            	    pushFollow(FOLLOW_must_be_in_dispatch_block3681);
            	    must_be189=must_be("domain");

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be189.getTree());
            	    domain=(Token)match(input,STRING,FOLLOW_STRING_in_dispatch_block3686); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    domain_tree = (Object)adaptor.create(domain);
            	    adaptor.addChild(root_0, domain_tree);
            	    }
            	    // RuleSet.g:1608:69: ( RIGHT_SMALL_ARROW rsid= STRING )?
            	    int alt110=2;
            	    int LA110_0 = input.LA(1);

            	    if ( (LA110_0==RIGHT_SMALL_ARROW) ) {
            	        alt110=1;
            	    }
            	    switch (alt110) {
            	        case 1 :
            	            // RuleSet.g:1608:70: RIGHT_SMALL_ARROW rsid= STRING
            	            {
            	            RIGHT_SMALL_ARROW190=(Token)match(input,RIGHT_SMALL_ARROW,FOLLOW_RIGHT_SMALL_ARROW_in_dispatch_block3689); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            RIGHT_SMALL_ARROW190_tree = (Object)adaptor.create(RIGHT_SMALL_ARROW190);
            	            adaptor.addChild(root_0, RIGHT_SMALL_ARROW190_tree);
            	            }
            	            rsid=(Token)match(input,STRING,FOLLOW_STRING_in_dispatch_block3693); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            rsid_tree = (Object)adaptor.create(rsid);
            	            adaptor.addChild(root_0, rsid_tree);
            	            }

            	            }
            	            break;

            	    }

            	    if ( state.backtracking==0 ) {

            	      		HashMap tmp = new HashMap();
            	      		tmp.put("domain",strip_string((domain!=null?domain.getText():null)));
            	      		if((rsid!=null?rsid.getText():null) != null)
            	      		{
            	      			tmp.put("ruleset_id",strip_string((rsid!=null?rsid.getText():null)));
            	      		}
            	      		dispatch_block_array.add(tmp);
            	      		
            	    }

            	    }
            	    break;

            	default :
            	    break loop111;
                }
            } while (true);

            RIGHT_CURL191=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_dispatch_block3704); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL191_tree = (Object)adaptor.create(RIGHT_CURL191);
            adaptor.addChild(root_0, RIGHT_CURL191_tree);
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
            if ( state.backtracking==0 ) {


            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "dispatch_block"

    public static class name_value_pair_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "name_value_pair"
    // RuleSet.g:1622:1: name_value_pair[HashMap key_values] : k= STRING COLON (v= INT | v= FLOAT | v= STRING ) ;
    public final RuleSetParser.name_value_pair_return name_value_pair(HashMap key_values) throws RecognitionException {
        RuleSetParser.name_value_pair_return retval = new RuleSetParser.name_value_pair_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token k=null;
        Token v=null;
        Token COLON192=null;

        Object k_tree=null;
        Object v_tree=null;
        Object COLON192_tree=null;


        	Object value = null;

        try {
            // RuleSet.g:1626:2: (k= STRING COLON (v= INT | v= FLOAT | v= STRING ) )
            // RuleSet.g:1626:4: k= STRING COLON (v= INT | v= FLOAT | v= STRING )
            {
            root_0 = (Object)adaptor.nil();

            k=(Token)match(input,STRING,FOLLOW_STRING_in_name_value_pair3727); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            k_tree = (Object)adaptor.create(k);
            adaptor.addChild(root_0, k_tree);
            }
            COLON192=(Token)match(input,COLON,FOLLOW_COLON_in_name_value_pair3729); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON192_tree = (Object)adaptor.create(COLON192);
            adaptor.addChild(root_0, COLON192_tree);
            }
            // RuleSet.g:1626:19: (v= INT | v= FLOAT | v= STRING )
            int alt112=3;
            switch ( input.LA(1) ) {
            case INT:
                {
                alt112=1;
                }
                break;
            case FLOAT:
                {
                alt112=2;
                }
                break;
            case STRING:
                {
                alt112=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 112, 0, input);

                throw nvae;
            }

            switch (alt112) {
                case 1 :
                    // RuleSet.g:1627:3: v= INT
                    {
                    v=(Token)match(input,INT,FOLLOW_INT_in_name_value_pair3737); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {
                      value =(v!=null?v.getText():null);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1628:5: v= FLOAT
                    {
                    v=(Token)match(input,FLOAT,FOLLOW_FLOAT_in_name_value_pair3748); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {
                      value = (v!=null?v.getText():null);
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1629:5: v= STRING
                    {
                    v=(Token)match(input,STRING,FOLLOW_STRING_in_name_value_pair3759); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    v_tree = (Object)adaptor.create(v);
                    adaptor.addChild(root_0, v_tree);
                    }
                    if ( state.backtracking==0 ) {
                      value = strip_string((v!=null?v.getText():null));
                    }

                    }
                    break;

            }

            if ( state.backtracking==0 ) {
              key_values.put(strip_string((k!=null?k.getText():null)),value);
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "name_value_pair"

    public static class regex_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "regex"
    // RuleSet.g:1639:1: regex returns [HashMap result] : rx= REX ;
    public final RuleSetParser.regex_return regex() throws RecognitionException {
        RuleSetParser.regex_return retval = new RuleSetParser.regex_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token rx=null;

        Object rx_tree=null;

           


        try {
            // RuleSet.g:1643:6: (rx= REX )
            // RuleSet.g:1644:8: rx= REX
            {
            root_0 = (Object)adaptor.nil();

            rx=(Token)match(input,REX,FOLLOW_REX_in_regex3805); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            rx_tree = (Object)adaptor.create(rx);
            adaptor.addChild(root_0, rx_tree);
            }
            if ( state.backtracking==0 ) {

                          HashMap tmp = new HashMap();
                          tmp.put("type","regexp");
                          tmp.put("val",(rx!=null?rx.getText():null).substring(2,(rx!=null?rx.getText():null).length()));
                          retval.result = tmp;
                      
            }

            }

            retval.stop = input.LT(-1);

            if ( state.backtracking==0 ) {

            retval.tree = (Object)adaptor.rulePostProcessing(root_0);
            adaptor.setTokenBoundaries(retval.tree, retval.start, retval.stop);
            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
    	retval.tree = (Object)adaptor.errorNode(input, retval.start, input.LT(-1), re);

        }
        finally {
        }
        return retval;
    }
    // $ANTLR end "regex"

    // $ANTLR start synpred10_RuleSet
    public final void synpred10_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:256:20: ( SEMI )
        // RuleSet.g:256:20: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred10_RuleSet326); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred10_RuleSet

    // $ANTLR start synpred11_RuleSet
    public final void synpred11_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.emit_block_return eb = null;


        // RuleSet.g:256:28: (eb= emit_block )
        // RuleSet.g:256:28: eb= emit_block
        {
        pushFollow(FOLLOW_emit_block_in_synpred11_RuleSet331);
        eb=emit_block();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred11_RuleSet

    // $ANTLR start synpred12_RuleSet
    public final void synpred12_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:256:41: ( SEMI )
        // RuleSet.g:256:41: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred12_RuleSet334); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred12_RuleSet

    // $ANTLR start synpred13_RuleSet
    public final void synpred13_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:256:71: ( SEMI )
        // RuleSet.g:256:71: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred13_RuleSet341); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred13_RuleSet

    // $ANTLR start synpred16_RuleSet
    public final void synpred16_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:256:93: ( SEMI )
        // RuleSet.g:256:93: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred16_RuleSet351); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred16_RuleSet

    // $ANTLR start synpred25_RuleSet
    public final void synpred25_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.persistent_expr_return pe = null;


        // RuleSet.g:338:6: (pe= persistent_expr )
        // RuleSet.g:338:6: pe= persistent_expr
        {
        pushFollow(FOLLOW_persistent_expr_in_synpred25_RuleSet504);
        pe=persistent_expr();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred25_RuleSet

    // $ANTLR start synpred27_RuleSet
    public final void synpred27_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.log_statement_return l = null;


        // RuleSet.g:340:4: (l= log_statement )
        // RuleSet.g:340:4: l= log_statement
        {
        pushFollow(FOLLOW_log_statement_in_synpred27_RuleSet521);
        l=log_statement();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred27_RuleSet

    // $ANTLR start synpred43_RuleSet
    public final void synpred43_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:563:62: ( SEMI )
        // RuleSet.g:563:62: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred43_RuleSet1126); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred43_RuleSet

    // $ANTLR start synpred75_RuleSet
    public final void synpred75_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.must_be_one_return tb = null;

        RuleSetParser.event_or_return eor2 = null;


        // RuleSet.g:739:17: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )
        // RuleSet.g:739:17: tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or
        {
        pushFollow(FOLLOW_must_be_one_in_synpred75_RuleSet1673);
        tb=must_be_one(sar("then","before"));

        state._fsp--;
        if (state.failed) return ;
        pushFollow(FOLLOW_event_or_in_synpred75_RuleSet1678);
        eor2=event_or();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred75_RuleSet

    // $ANTLR start synpred114_RuleSet
    public final void synpred114_RuleSet_fragment() throws RecognitionException {   
        Token op=null;
        RuleSetParser.unary_expr_return me2 = null;


        // RuleSet.g:1166:21: (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )
        // RuleSet.g:1166:21: op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr
        {
        op=(Token)input.LT(1);
        if ( (input.LA(1)>=ADD_OP && input.LA(1)<=REX) ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        pushFollow(FOLLOW_unary_expr_in_synpred114_RuleSet2443);
        me2=unary_expr();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred114_RuleSet

    // $ANTLR start synpred116_RuleSet
    public final void synpred116_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1198:58: (t= timeframe )
        // RuleSet.g:1198:58: t= timeframe
        {
        pushFollow(FOLLOW_timeframe_in_synpred116_RuleSet2521);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred116_RuleSet

    // $ANTLR start synpred117_RuleSet
    public final void synpred117_RuleSet_fragment() throws RecognitionException {   
        Token rx=null;
        Token vd=null;
        Token v=null;
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1198:4: ( SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )? )
        // RuleSet.g:1198:4: SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )?
        {
        match(input,SEEN,FOLLOW_SEEN_in_synpred117_RuleSet2500); if (state.failed) return ;
        rx=(Token)match(input,STRING,FOLLOW_STRING_in_synpred117_RuleSet2504); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_in_synpred117_RuleSet2506);
        must_be("in");

        state._fsp--;
        if (state.failed) return ;
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred117_RuleSet2511); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred117_RuleSet2513); if (state.failed) return ;
        v=(Token)match(input,VAR,FOLLOW_VAR_in_synpred117_RuleSet2517); if (state.failed) return ;
        // RuleSet.g:1198:58: (t= timeframe )?
        int alt134=2;
        int LA134_0 = input.LA(1);

        if ( (LA134_0==WITHIN) ) {
            alt134=1;
        }
        switch (alt134) {
            case 1 :
                // RuleSet.g:0:0: t= timeframe
                {
                pushFollow(FOLLOW_timeframe_in_synpred117_RuleSet2521);
                t=timeframe();

                state._fsp--;
                if (state.failed) return ;

                }
                break;

        }


        }
    }
    // $ANTLR end synpred117_RuleSet

    // $ANTLR start synpred118_RuleSet
    public final void synpred118_RuleSet_fragment() throws RecognitionException {   
        Token rx_1=null;
        Token rx_2=null;
        Token vd=null;
        Token v=null;
        RuleSetParser.must_be_one_return op = null;


        // RuleSet.g:1209:4: ( SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR )
        // RuleSet.g:1209:4: SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR
        {
        match(input,SEEN,FOLLOW_SEEN_in_synpred118_RuleSet2529); if (state.failed) return ;
        rx_1=(Token)match(input,STRING,FOLLOW_STRING_in_synpred118_RuleSet2533); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_one_in_synpred118_RuleSet2537);
        op=must_be_one(sar("before","after"));

        state._fsp--;
        if (state.failed) return ;
        rx_2=(Token)match(input,STRING,FOLLOW_STRING_in_synpred118_RuleSet2542); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_in_synpred118_RuleSet2545);
        must_be("in");

        state._fsp--;
        if (state.failed) return ;
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred118_RuleSet2550); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred118_RuleSet2552); if (state.failed) return ;
        v=(Token)match(input,VAR,FOLLOW_VAR_in_synpred118_RuleSet2556); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred118_RuleSet

    // $ANTLR start synpred119_RuleSet
    public final void synpred119_RuleSet_fragment() throws RecognitionException {   
        Token vd=null;
        Token v=null;
        Token pop=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1219:4: (vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe )
        // RuleSet.g:1219:4: vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe
        {
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred119_RuleSet2565); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred119_RuleSet2567); if (state.failed) return ;
        v=(Token)match(input,VAR,FOLLOW_VAR_in_synpred119_RuleSet2571); if (state.failed) return ;
        pop=(Token)match(input,PREDOP,FOLLOW_PREDOP_in_synpred119_RuleSet2575); if (state.failed) return ;
        pushFollow(FOLLOW_expr_in_synpred119_RuleSet2579);
        e=expr();

        state._fsp--;
        if (state.failed) return ;
        pushFollow(FOLLOW_timeframe_in_synpred119_RuleSet2583);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred119_RuleSet

    // $ANTLR start synpred120_RuleSet
    public final void synpred120_RuleSet_fragment() throws RecognitionException {   
        Token vd=null;
        Token v=null;
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1231:4: (vd= VAR_DOMAIN COLON v= VAR t= timeframe )
        // RuleSet.g:1231:4: vd= VAR_DOMAIN COLON v= VAR t= timeframe
        {
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred120_RuleSet2593); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred120_RuleSet2595); if (state.failed) return ;
        v=(Token)match(input,VAR,FOLLOW_VAR_in_synpred120_RuleSet2599); if (state.failed) return ;
        pushFollow(FOLLOW_timeframe_in_synpred120_RuleSet2603);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred120_RuleSet

    // $ANTLR start synpred121_RuleSet
    public final void synpred121_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.regex_return roe = null;


        // RuleSet.g:1242:4: (roe= regex )
        // RuleSet.g:1242:4: roe= regex
        {
        pushFollow(FOLLOW_regex_in_synpred121_RuleSet2612);
        roe=regex();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred121_RuleSet

    // $ANTLR start synpred132_RuleSet
    public final void synpred132_RuleSet_fragment() throws RecognitionException {   
        Token bv=null;
        RuleSetParser.expr_return e = null;


        // RuleSet.g:1351:9: (bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET )
        // RuleSet.g:1351:9: bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET
        {
        bv=(Token)match(input,VAR,FOLLOW_VAR_in_synpred132_RuleSet2906); if (state.failed) return ;
        match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_synpred132_RuleSet2908); if (state.failed) return ;
        pushFollow(FOLLOW_expr_in_synpred132_RuleSet2912);
        e=expr();

        state._fsp--;
        if (state.failed) return ;
        match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_synpred132_RuleSet2914); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred132_RuleSet

    // $ANTLR start synpred138_RuleSet
    public final void synpred138_RuleSet_fragment() throws RecognitionException {   
        Token p=null;
        RuleSetParser.namespace_return n = null;

        RuleSetParser.expr_return e = null;


        // RuleSet.g:1389:9: (n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN )
        // RuleSet.g:1389:9: n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
        {
        pushFollow(FOLLOW_namespace_in_synpred138_RuleSet2998);
        n=namespace();

        state._fsp--;
        if (state.failed) return ;
        p=(Token)match(input,VAR,FOLLOW_VAR_in_synpred138_RuleSet3002); if (state.failed) return ;
        match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_synpred138_RuleSet3004); if (state.failed) return ;
        // RuleSet.g:1389:38: (e= expr ( COMMA e= expr )* )?
        int alt140=2;
        int LA140_0 = input.LA(1);

        if ( (LA140_0==LEFT_CURL||(LA140_0>=VAR && LA140_0<=INT)||(LA140_0>=STRING && LA140_0<=VAR_DOMAIN)||(LA140_0>=REPLACE && LA140_0<=LEFT_PAREN)||LA140_0==NOT||LA140_0==FUNCTION||(LA140_0>=REX && LA140_0<=SEEN)||(LA140_0>=FLOAT && LA140_0<=LEFT_BRACKET)||(LA140_0>=CURRENT && LA140_0<=HISTORY)) ) {
            alt140=1;
        }
        switch (alt140) {
            case 1 :
                // RuleSet.g:1389:39: e= expr ( COMMA e= expr )*
                {
                pushFollow(FOLLOW_expr_in_synpred138_RuleSet3009);
                e=expr();

                state._fsp--;
                if (state.failed) return ;
                // RuleSet.g:1389:73: ( COMMA e= expr )*
                loop139:
                do {
                    int alt139=2;
                    int LA139_0 = input.LA(1);

                    if ( (LA139_0==COMMA) ) {
                        alt139=1;
                    }


                    switch (alt139) {
                	case 1 :
                	    // RuleSet.g:1389:75: COMMA e= expr
                	    {
                	    match(input,COMMA,FOLLOW_COMMA_in_synpred138_RuleSet3015); if (state.failed) return ;
                	    pushFollow(FOLLOW_expr_in_synpred138_RuleSet3019);
                	    e=expr();

                	    state._fsp--;
                	    if (state.failed) return ;

                	    }
                	    break;

                	default :
                	    break loop139;
                    }
                } while (true);


                }
                break;

        }

        match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_synpred138_RuleSet3028); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred138_RuleSet

    // $ANTLR start synpred141_RuleSet
    public final void synpred141_RuleSet_fragment() throws RecognitionException {   
        Token v=null;
        RuleSetParser.expr_return e = null;


        // RuleSet.g:1397:9: (v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN )
        // RuleSet.g:1397:9: v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
        {
        v=(Token)match(input,VAR,FOLLOW_VAR_in_synpred141_RuleSet3043); if (state.failed) return ;
        match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_synpred141_RuleSet3045); if (state.failed) return ;
        // RuleSet.g:1397:26: (e= expr ( COMMA e= expr )* )?
        int alt143=2;
        int LA143_0 = input.LA(1);

        if ( (LA143_0==LEFT_CURL||(LA143_0>=VAR && LA143_0<=INT)||(LA143_0>=STRING && LA143_0<=VAR_DOMAIN)||(LA143_0>=REPLACE && LA143_0<=LEFT_PAREN)||LA143_0==NOT||LA143_0==FUNCTION||(LA143_0>=REX && LA143_0<=SEEN)||(LA143_0>=FLOAT && LA143_0<=LEFT_BRACKET)||(LA143_0>=CURRENT && LA143_0<=HISTORY)) ) {
            alt143=1;
        }
        switch (alt143) {
            case 1 :
                // RuleSet.g:1397:27: e= expr ( COMMA e= expr )*
                {
                pushFollow(FOLLOW_expr_in_synpred141_RuleSet3050);
                e=expr();

                state._fsp--;
                if (state.failed) return ;
                // RuleSet.g:1397:61: ( COMMA e= expr )*
                loop142:
                do {
                    int alt142=2;
                    int LA142_0 = input.LA(1);

                    if ( (LA142_0==COMMA) ) {
                        alt142=1;
                    }


                    switch (alt142) {
                	case 1 :
                	    // RuleSet.g:1397:63: COMMA e= expr
                	    {
                	    match(input,COMMA,FOLLOW_COMMA_in_synpred141_RuleSet3055); if (state.failed) return ;
                	    pushFollow(FOLLOW_expr_in_synpred141_RuleSet3059);
                	    e=expr();

                	    state._fsp--;
                	    if (state.failed) return ;

                	    }
                	    break;

                	default :
                	    break loop142;
                    }
                } while (true);


                }
                break;

        }

        match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_synpred141_RuleSet3068); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred141_RuleSet

    // $ANTLR start synpred152_RuleSet
    public final void synpred152_RuleSet_fragment() throws RecognitionException {   
        Token v=null;

        // RuleSet.g:1423:9: (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )
        // RuleSet.g:1423:9: v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH )
        {
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=REPLACE && input.LA(1)<=OTHER_OPERATORS) ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }


        }
    }
    // $ANTLR end synpred152_RuleSet

    // Delegated rules

    public final boolean synpred138_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred138_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred119_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred119_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred141_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred141_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred132_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred132_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred12_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred12_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred116_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred116_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred16_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred16_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred117_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred117_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred11_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred11_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred27_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred27_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred118_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred118_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred10_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred10_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred43_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred43_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred152_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred152_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred121_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred121_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred25_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred25_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred114_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred114_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred13_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred13_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred120_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred120_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred75_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred75_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }


    protected DFA20 dfa20 = new DFA20(this);
    protected DFA55 dfa55 = new DFA55(this);
    protected DFA84 dfa84 = new DFA84(this);
    protected DFA86 dfa86 = new DFA86(this);
    protected DFA85 dfa85 = new DFA85(this);
    protected DFA99 dfa99 = new DFA99(this);
    static final String DFA20_eotS =
        "\12\uffff";
    static final String DFA20_eofS =
        "\1\uffff\1\6\3\uffff\1\3\4\uffff";
    static final String DFA20_minS =
        "\1\7\1\5\2\uffff\1\21\1\6\1\uffff\1\7\1\uffff\1\0";
    static final String DFA20_maxS =
        "\1\24\1\101\2\uffff\1\21\1\76\1\uffff\1\7\1\uffff\1\0";
    static final String DFA20_acceptS =
        "\2\uffff\1\1\1\3\2\uffff\1\4\1\uffff\1\2\1\uffff";
    static final String DFA20_specialS =
        "\11\uffff\1\0}>";
    static final String[] DFA20_transitionS = {
            "\1\1\10\uffff\1\2\2\uffff\2\2",
            "\1\3\1\6\1\5\1\3\2\6\4\uffff\1\3\1\4\11\uffff\4\3\12\uffff"+
            "\1\3\10\uffff\1\3\6\uffff\2\3\1\uffff\4\3\1\uffff\2\3",
            "",
            "",
            "\1\7",
            "\1\3\1\10\1\uffff\2\3\6\uffff\1\3\7\uffff\1\3\3\uffff\1\3\25"+
            "\uffff\6\3\1\uffff\1\3\3\uffff\1\3",
            "",
            "\1\11",
            "",
            "\1\uffff"
    };

    static final short[] DFA20_eot = DFA.unpackEncodedString(DFA20_eotS);
    static final short[] DFA20_eof = DFA.unpackEncodedString(DFA20_eofS);
    static final char[] DFA20_min = DFA.unpackEncodedStringToUnsignedChars(DFA20_minS);
    static final char[] DFA20_max = DFA.unpackEncodedStringToUnsignedChars(DFA20_maxS);
    static final short[] DFA20_accept = DFA.unpackEncodedString(DFA20_acceptS);
    static final short[] DFA20_special = DFA.unpackEncodedString(DFA20_specialS);
    static final short[][] DFA20_transition;

    static {
        int numStates = DFA20_transitionS.length;
        DFA20_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA20_transition[i] = DFA.unpackEncodedString(DFA20_transitionS[i]);
        }
    }

    class DFA20 extends DFA {

        public DFA20(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 20;
            this.eot = DFA20_eot;
            this.eof = DFA20_eof;
            this.min = DFA20_min;
            this.max = DFA20_max;
            this.accept = DFA20_accept;
            this.special = DFA20_special;
            this.transition = DFA20_transition;
        }
        public String getDescription() {
            return "338:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] )";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA20_9 = input.LA(1);

                         
                        int index20_9 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred25_RuleSet()) ) {s = 2;}

                        else if ( (synpred27_RuleSet()) ) {s = 3;}

                         
                        input.seek(index20_9);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 20, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA55_eotS =
        "\17\uffff";
    static final String DFA55_eofS =
        "\17\uffff";
    static final String DFA55_minS =
        "\1\5\5\uffff\1\0\10\uffff";
    static final String DFA55_maxS =
        "\1\105\5\uffff\1\0\10\uffff";
    static final String DFA55_acceptS =
        "\1\uffff\1\2\14\uffff\1\1";
    static final String DFA55_specialS =
        "\6\uffff\1\0\10\uffff}>";
    static final String[] DFA55_transitionS = {
            "\2\1\1\6\1\uffff\3\1\13\uffff\2\1\1\uffff\3\1\1\uffff\2\1\4"+
            "\uffff\2\1\37\uffff\1\1",
            "",
            "",
            "",
            "",
            "",
            "\1\uffff",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
    };

    static final short[] DFA55_eot = DFA.unpackEncodedString(DFA55_eotS);
    static final short[] DFA55_eof = DFA.unpackEncodedString(DFA55_eofS);
    static final char[] DFA55_min = DFA.unpackEncodedStringToUnsignedChars(DFA55_minS);
    static final char[] DFA55_max = DFA.unpackEncodedStringToUnsignedChars(DFA55_maxS);
    static final short[] DFA55_accept = DFA.unpackEncodedString(DFA55_acceptS);
    static final short[] DFA55_special = DFA.unpackEncodedString(DFA55_specialS);
    static final short[][] DFA55_transition;

    static {
        int numStates = DFA55_transitionS.length;
        DFA55_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA55_transition[i] = DFA.unpackEncodedString(DFA55_transitionS[i]);
        }
    }

    class DFA55 extends DFA {

        public DFA55(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 55;
            this.eot = DFA55_eot;
            this.eof = DFA55_eof;
            this.min = DFA55_min;
            this.max = DFA55_max;
            this.accept = DFA55_accept;
            this.special = DFA55_special;
            this.transition = DFA55_transition;
        }
        public String getDescription() {
            return "()* loopback of 739:16: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA55_6 = input.LA(1);

                         
                        int index55_6 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred75_RuleSet()) ) {s = 14;}

                        else if ( (true) ) {s = 1;}

                         
                        input.seek(index55_6);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 55, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA84_eotS =
        "\44\uffff";
    static final String DFA84_eofS =
        "\1\1\43\uffff";
    static final String DFA84_minS =
        "\1\5\26\uffff\1\0\14\uffff";
    static final String DFA84_maxS =
        "\1\105\26\uffff\1\0\14\uffff";
    static final String DFA84_acceptS =
        "\1\uffff\1\2\41\uffff\1\1";
    static final String DFA84_specialS =
        "\27\uffff\1\0\14\uffff}>";
    static final String[] DFA84_transitionS = {
            "\7\1\3\uffff\2\1\6\uffff\12\1\2\uffff\1\1\4\uffff\1\1\10\uffff"+
            "\5\1\2\43\1\27\1\1\1\uffff\11\1\1\uffff\1\1",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\uffff",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
    };

    static final short[] DFA84_eot = DFA.unpackEncodedString(DFA84_eotS);
    static final short[] DFA84_eof = DFA.unpackEncodedString(DFA84_eofS);
    static final char[] DFA84_min = DFA.unpackEncodedStringToUnsignedChars(DFA84_minS);
    static final char[] DFA84_max = DFA.unpackEncodedStringToUnsignedChars(DFA84_maxS);
    static final short[] DFA84_accept = DFA.unpackEncodedString(DFA84_acceptS);
    static final short[] DFA84_special = DFA.unpackEncodedString(DFA84_specialS);
    static final short[][] DFA84_transition;

    static {
        int numStates = DFA84_transitionS.length;
        DFA84_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA84_transition[i] = DFA.unpackEncodedString(DFA84_transitionS[i]);
        }
    }

    class DFA84 extends DFA {

        public DFA84(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 84;
            this.eot = DFA84_eot;
            this.eof = DFA84_eof;
            this.min = DFA84_min;
            this.max = DFA84_max;
            this.accept = DFA84_accept;
            this.special = DFA84_special;
            this.transition = DFA84_transition;
        }
        public String getDescription() {
            return "()* loopback of 1166:20: (op= ( ADD_OP | MULT_OP | REX ) me2= unary_expr )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA84_23 = input.LA(1);

                         
                        int index84_23 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred114_RuleSet()) ) {s = 35;}

                        else if ( (true) ) {s = 1;}

                         
                        input.seek(index84_23);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 84, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA86_eotS =
        "\25\uffff";
    static final String DFA86_eofS =
        "\25\uffff";
    static final String DFA86_minS =
        "\1\5\1\uffff\3\0\20\uffff";
    static final String DFA86_maxS =
        "\1\101\1\uffff\3\0\20\uffff";
    static final String DFA86_acceptS =
        "\1\uffff\1\1\3\uffff\1\7\12\uffff\1\2\1\3\1\4\1\5\1\6";
    static final String DFA86_specialS =
        "\2\uffff\1\0\1\1\1\2\20\uffff}>";
    static final String[] DFA86_transitionS = {
            "\1\5\1\uffff\2\5\6\uffff\1\5\1\3\11\uffff\4\5\12\uffff\1\1\17"+
            "\uffff\1\4\1\2\1\uffff\4\5\1\uffff\2\5",
            "",
            "\1\uffff",
            "\1\uffff",
            "\1\uffff",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
    };

    static final short[] DFA86_eot = DFA.unpackEncodedString(DFA86_eotS);
    static final short[] DFA86_eof = DFA.unpackEncodedString(DFA86_eofS);
    static final char[] DFA86_min = DFA.unpackEncodedStringToUnsignedChars(DFA86_minS);
    static final char[] DFA86_max = DFA.unpackEncodedStringToUnsignedChars(DFA86_maxS);
    static final short[] DFA86_accept = DFA.unpackEncodedString(DFA86_acceptS);
    static final short[] DFA86_special = DFA.unpackEncodedString(DFA86_specialS);
    static final short[][] DFA86_transition;

    static {
        int numStates = DFA86_transitionS.length;
        DFA86_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA86_transition[i] = DFA.unpackEncodedString(DFA86_transitionS[i]);
        }
    }

    class DFA86 extends DFA {

        public DFA86(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 86;
            this.eot = DFA86_eot;
            this.eof = DFA86_eof;
            this.min = DFA86_min;
            this.max = DFA86_max;
            this.accept = DFA86_accept;
            this.special = DFA86_special;
            this.transition = DFA86_transition;
        }
        public String getDescription() {
            return "1185:1: unary_expr returns [Object result] options {backtrack=true; } : ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= VAR | vd= VAR_DOMAIN COLON v= VAR pop= PREDOP e= expr t= timeframe | vd= VAR_DOMAIN COLON v= VAR t= timeframe | roe= regex | oe= operator_expr );";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA86_2 = input.LA(1);

                         
                        int index86_2 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred117_RuleSet()) ) {s = 16;}

                        else if ( (synpred118_RuleSet()) ) {s = 17;}

                         
                        input.seek(index86_2);
                        if ( s>=0 ) return s;
                        break;
                    case 1 : 
                        int LA86_3 = input.LA(1);

                         
                        int index86_3 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred119_RuleSet()) ) {s = 18;}

                        else if ( (synpred120_RuleSet()) ) {s = 19;}

                        else if ( (true) ) {s = 5;}

                         
                        input.seek(index86_3);
                        if ( s>=0 ) return s;
                        break;
                    case 2 : 
                        int LA86_4 = input.LA(1);

                         
                        int index86_4 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred121_RuleSet()) ) {s = 20;}

                        else if ( (true) ) {s = 5;}

                         
                        input.seek(index86_4);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 86, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA85_eotS =
        "\45\uffff";
    static final String DFA85_eofS =
        "\1\2\44\uffff";
    static final String DFA85_minS =
        "\1\5\1\0\43\uffff";
    static final String DFA85_maxS =
        "\1\105\1\0\43\uffff";
    static final String DFA85_acceptS =
        "\2\uffff\1\2\41\uffff\1\1";
    static final String DFA85_specialS =
        "\1\uffff\1\0\43\uffff}>";
    static final String[] DFA85_transitionS = {
            "\7\2\3\uffff\2\2\6\uffff\12\2\2\uffff\1\2\4\uffff\1\2\10\uffff"+
            "\11\2\1\uffff\7\2\1\1\1\2\1\uffff\1\2",
            "\1\uffff",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
    };

    static final short[] DFA85_eot = DFA.unpackEncodedString(DFA85_eotS);
    static final short[] DFA85_eof = DFA.unpackEncodedString(DFA85_eofS);
    static final char[] DFA85_min = DFA.unpackEncodedStringToUnsignedChars(DFA85_minS);
    static final char[] DFA85_max = DFA.unpackEncodedStringToUnsignedChars(DFA85_maxS);
    static final short[] DFA85_accept = DFA.unpackEncodedString(DFA85_acceptS);
    static final short[] DFA85_special = DFA.unpackEncodedString(DFA85_specialS);
    static final short[][] DFA85_transition;

    static {
        int numStates = DFA85_transitionS.length;
        DFA85_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA85_transition[i] = DFA.unpackEncodedString(DFA85_transitionS[i]);
        }
    }

    class DFA85 extends DFA {

        public DFA85(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 85;
            this.eot = DFA85_eot;
            this.eof = DFA85_eof;
            this.min = DFA85_min;
            this.max = DFA85_max;
            this.accept = DFA85_accept;
            this.special = DFA85_special;
            this.transition = DFA85_transition;
        }
        public String getDescription() {
            return "1198:58: (t= timeframe )?";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA85_1 = input.LA(1);

                         
                        int index85_1 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred116_RuleSet()) ) {s = 36;}

                        else if ( (true) ) {s = 2;}

                         
                        input.seek(index85_1);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 85, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA99_eotS =
        "\21\uffff";
    static final String DFA99_eofS =
        "\21\uffff";
    static final String DFA99_minS =
        "\1\5\4\uffff\1\0\13\uffff";
    static final String DFA99_maxS =
        "\1\101\4\uffff\1\0\13\uffff";
    static final String DFA99_acceptS =
        "\1\uffff\1\1\1\2\1\3\1\4\1\uffff\1\6\1\7\1\10\1\13\1\14\1\15\1\16"+
        "\1\17\1\5\1\11\1\12";
    static final String DFA99_specialS =
        "\5\uffff\1\0\13\uffff}>";
    static final String[] DFA99_transitionS = {
            "\1\12\1\uffff\1\5\1\1\6\uffff\1\2\1\6\11\uffff\3\14\1\13\32"+
            "\uffff\1\15\2\uffff\1\3\2\4\1\11\1\uffff\1\7\1\10",
            "",
            "",
            "",
            "",
            "\1\uffff",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            ""
    };

    static final short[] DFA99_eot = DFA.unpackEncodedString(DFA99_eotS);
    static final short[] DFA99_eof = DFA.unpackEncodedString(DFA99_eofS);
    static final char[] DFA99_min = DFA.unpackEncodedStringToUnsignedChars(DFA99_minS);
    static final char[] DFA99_max = DFA.unpackEncodedStringToUnsignedChars(DFA99_maxS);
    static final short[] DFA99_accept = DFA.unpackEncodedString(DFA99_acceptS);
    static final short[] DFA99_special = DFA.unpackEncodedString(DFA99_specialS);
    static final short[][] DFA99_transition;

    static {
        int numStates = DFA99_transitionS.length;
        DFA99_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA99_transition[i] = DFA.unpackEncodedString(DFA99_transitionS[i]);
        }
    }

    class DFA99 extends DFA {

        public DFA99(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 99;
            this.eot = DFA99_eot;
            this.eof = DFA99_eof;
            this.min = DFA99_min;
            this.max = DFA99_max;
            this.accept = DFA99_accept;
            this.special = DFA99_special;
            this.transition = DFA99_transition;
        }
        public String getDescription() {
            return "1322:1: factor returns [Object result] options {backtrack=true; } : (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= VAR LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= VAR | CURRENT d= VAR_DOMAIN COLON v= VAR | HISTORY e= expr d= VAR_DOMAIN COLON v= VAR | n= namespace p= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= VAR LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex );";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA99_5 = input.LA(1);

                         
                        int index99_5 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred132_RuleSet()) ) {s = 14;}

                        else if ( (synpred138_RuleSet()) ) {s = 15;}

                        else if ( (synpred141_RuleSet()) ) {s = 16;}

                        else if ( (synpred152_RuleSet()) ) {s = 12;}

                         
                        input.seek(index99_5);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 99, _s, input);
            error(nvae);
            throw nvae;
        }
    }
 

    public static final BitSet FOLLOW_RULE_SET_in_ruleset100 = new BitSet(new long[]{0x0000000000000180L});
    public static final BitSet FOLLOW_rulesetname_in_ruleset102 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_ruleset109 = new BitSet(new long[]{0x00002000000000C0L,0x0000000000000040L});
    public static final BitSet FOLLOW_meta_block_in_ruleset116 = new BitSet(new long[]{0x00002000000000C0L,0x0000000000000040L});
    public static final BitSet FOLLOW_dispatch_block_in_ruleset120 = new BitSet(new long[]{0x00002000000000C0L,0x0000000000000040L});
    public static final BitSet FOLLOW_global_block_in_ruleset124 = new BitSet(new long[]{0x00002000000000C0L,0x0000000000000040L});
    public static final BitSet FOLLOW_rule_in_ruleset128 = new BitSet(new long[]{0x00002000000000C0L,0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_ruleset134 = new BitSet(new long[]{0x0000000000000000L});
    public static final BitSet FOLLOW_EOF_in_ruleset138 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_must_be161 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_must_be_one186 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_rulesetname0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_rule_name0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_rule248 = new BitSet(new long[]{0x0000000000000180L});
    public static final BitSet FOLLOW_rule_name_in_rule255 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_rule266 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_rule278 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_rule283 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_rule293 = new BitSet(new long[]{0x0000004400000000L});
    public static final BitSet FOLLOW_using_in_rule300 = new BitSet(new long[]{0x000000301D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_when_in_rule304 = new BitSet(new long[]{0x000000301D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_foreach_in_rule310 = new BitSet(new long[]{0x000000301D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_pre_block_in_rule323 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_SEMI_in_rule326 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_emit_block_in_rule331 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_SEMI_in_rule334 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_action_in_rule338 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_SEMI_in_rule341 = new BitSet(new long[]{0x000000001D800EE0L,0x0000000000000020L});
    public static final BitSet FOLLOW_callbacks_in_rule348 = new BitSet(new long[]{0x00000000000002C0L});
    public static final BitSet FOLLOW_SEMI_in_rule351 = new BitSet(new long[]{0x00000000000002C0L});
    public static final BitSet FOLLOW_post_block_in_rule356 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_rule359 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_rule364 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_post_block395 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_post_block398 = new BitSet(new long[]{0x0000000000190080L});
    public static final BitSet FOLLOW_post_statement_in_post_block405 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_post_block410 = new BitSet(new long[]{0x0000000000190080L});
    public static final BitSet FOLLOW_post_statement_in_post_block414 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_post_block422 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_post_block425 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_post_alternate_in_post_block431 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_post_alternate458 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_post_alternate461 = new BitSet(new long[]{0x00000000001902C0L});
    public static final BitSet FOLLOW_post_statement_in_post_alternate466 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_post_alternate471 = new BitSet(new long[]{0x0000000000190080L});
    public static final BitSet FOLLOW_post_statement_in_post_alternate475 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_post_alternate483 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_post_alternate486 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_expr_in_post_statement504 = new BitSet(new long[]{0x0000000000000402L});
    public static final BitSet FOLLOW_raise_statement_in_post_statement514 = new BitSet(new long[]{0x0000000000000402L});
    public static final BitSet FOLLOW_log_statement_in_post_statement521 = new BitSet(new long[]{0x0000000000000402L});
    public static final BitSet FOLLOW_must_be_in_post_statement531 = new BitSet(new long[]{0x0000000000000402L});
    public static final BitSet FOLLOW_IF_in_post_statement537 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_post_statement541 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_raise_statement566 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_raise_statement569 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_raise_statement572 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_raise_statement578 = new BitSet(new long[]{0x0000000000600002L});
    public static final BitSet FOLLOW_for_clause_in_raise_statement582 = new BitSet(new long[]{0x0000000000200002L});
    public static final BitSet FOLLOW_modifier_clause_in_raise_statement587 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_log_statement607 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_log_statement613 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CALLBACKS_in_callbacks631 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_callbacks633 = new BitSet(new long[]{0x0000000000003040L});
    public static final BitSet FOLLOW_success_in_callbacks637 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_failure_in_callbacks642 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_callbacks645 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SUCCESS_in_success667 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_success669 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_success673 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_success679 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_success683 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_success690 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_success694 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FAILURE_in_failure722 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_failure724 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_failure728 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_failure734 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_failure738 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_failure746 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_failure750 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_click768 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_click773 = new BitSet(new long[]{0x0000000000004000L});
    public static final BitSet FOLLOW_EQUAL_in_click775 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_click779 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_click_link_in_click783 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_click_link803 = new BitSet(new long[]{0x0000000000190080L});
    public static final BitSet FOLLOW_persistent_expr_in_click_link808 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_clear_set_in_persistent_expr830 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_iterate_in_persistent_expr840 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_trail_forget_in_persistent_expr853 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_trail_mark_in_persistent_expr866 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_persistent_clear_set891 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_persistent_clear_set897 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_persistent_clear_set899 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_persistent_clear_set903 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_persistent_iterate924 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_persistent_iterate926 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_persistent_iterate930 = new BitSet(new long[]{0x0000000000040000L});
    public static final BitSet FOLLOW_COUNTER_OP_in_persistent_iterate934 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_persistent_iterate938 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_counter_start_in_persistent_iterate942 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FORGET_in_trail_forget959 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_trail_forget964 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_trail_forget966 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_trail_forget972 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_trail_forget974 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_trail_forget978 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MARK_in_trail_mark997 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_trail_mark1001 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_trail_mark1003 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_trail_mark1007 = new BitSet(new long[]{0x0000000000200002L});
    public static final BitSet FOLLOW_trail_with_in_trail_mark1011 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITH_in_trail_with1030 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_trail_with1034 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_counter_start1052 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_counter_start1057 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOR_in_for_clause1078 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_for_clause1083 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_conditional_action_in_action1117 = new BitSet(new long[]{0x0000000000000202L});
    public static final BitSet FOLLOW_unconditional_action_in_action1122 = new BitSet(new long[]{0x0000000000000202L});
    public static final BitSet FOLLOW_SEMI_in_action1126 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_IF_in_conditional_action1141 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_conditional_action1145 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_conditional_action1147 = new BitSet(new long[]{0x000000001D8004A0L,0x0000000000000020L});
    public static final BitSet FOLLOW_unconditional_action_in_conditional_action1150 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_primrule_in_unconditional_action1175 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_action_block_in_unconditional_action1185 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_action_block1209 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_action_block1222 = new BitSet(new long[]{0x000000001C000080L,0x0000000000000020L});
    public static final BitSet FOLLOW_primrule_in_action_block1227 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_action_block1237 = new BitSet(new long[]{0x000000001C000080L,0x0000000000000020L});
    public static final BitSet FOLLOW_primrule_in_action_block1241 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_action_block1248 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_action_block1251 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_primrule1278 = new BitSet(new long[]{0x0000000002000000L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_primrule1280 = new BitSet(new long[]{0x000000001C000080L,0x0000000000000020L});
    public static final BitSet FOLLOW_namespace_in_primrule1291 = new BitSet(new long[]{0x000000001C000080L});
    public static final BitSet FOLLOW_set_in_primrule1297 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_primrule1307 = new BitSet(new long[]{0x7B020100FC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_primrule1312 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_primrule1317 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_primrule1321 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_primrule1329 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_primrule1333 = new BitSet(new long[]{0x0000000000200002L});
    public static final BitSet FOLLOW_modifier_clause_in_primrule1337 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_emit_block_in_primrule1347 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITH_in_modifier_clause1379 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_modifier_in_modifier_clause1383 = new BitSet(new long[]{0x0000000100000002L});
    public static final BitSet FOLLOW_AND_AND_in_modifier_clause1388 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_modifier_in_modifier_clause1392 = new BitSet(new long[]{0x0000000100000002L});
    public static final BitSet FOLLOW_VAR_in_modifier1417 = new BitSet(new long[]{0x0000000000004000L});
    public static final BitSet FOLLOW_EQUAL_in_modifier1419 = new BitSet(new long[]{0x7B0201023C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_modifier1423 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_modifier1429 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_USING_in_using1453 = new BitSet(new long[]{0x0100000000008000L});
    public static final BitSet FOLLOW_STRING_in_using1458 = new BitSet(new long[]{0x0000000800000002L});
    public static final BitSet FOLLOW_regex_in_using1462 = new BitSet(new long[]{0x0000000800000002L});
    public static final BitSet FOLLOW_setting_in_using1467 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SETTING_in_setting1488 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_setting1490 = new BitSet(new long[]{0x000000009C000080L});
    public static final BitSet FOLLOW_set_in_setting1495 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_setting1507 = new BitSet(new long[]{0x000000001C000080L});
    public static final BitSet FOLLOW_set_in_setting1511 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_setting1527 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_PRE_in_pre_block1552 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_pre_block1554 = new BitSet(new long[]{0x00000000000002C0L});
    public static final BitSet FOLLOW_decl_in_pre_block1558 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_pre_block1562 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_decl_in_pre_block1564 = new BitSet(new long[]{0x0000000000000240L});
    public static final BitSet FOLLOW_SEMI_in_pre_block1572 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_pre_block1575 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOREACH_in_foreach1596 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_foreach1600 = new BitSet(new long[]{0x0000000800000000L});
    public static final BitSet FOLLOW_setting_in_foreach1604 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WHEN_in_when1637 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_seq_in_when1641 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_event_or_in_event_seq1668 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_must_be_one_in_event_seq1673 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_or_in_event_seq1678 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_event_and_in_event_or1719 = new BitSet(new long[]{0x0000008000000002L});
    public static final BitSet FOLLOW_OR_OR_in_event_or1724 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_and_in_event_or1728 = new BitSet(new long[]{0x0000008000000002L});
    public static final BitSet FOLLOW_event_btwn_in_event_and1757 = new BitSet(new long[]{0x0000000100000002L});
    public static final BitSet FOLLOW_AND_AND_in_event_and1762 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_btwn_in_event_and1766 = new BitSet(new long[]{0x0000000100000002L});
    public static final BitSet FOLLOW_event_prim_in_event_btwn1792 = new BitSet(new long[]{0x0000030000000002L});
    public static final BitSet FOLLOW_NOT_in_event_btwn1798 = new BitSet(new long[]{0x0000020000000000L});
    public static final BitSet FOLLOW_BETWEEN_in_event_btwn1803 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_event_btwn1805 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_seq_in_event_btwn1809 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_COMMA_in_event_btwn1811 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_seq_in_event_btwn1815 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_event_btwn1817 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WEB_in_event_prim1845 = new BitSet(new long[]{0x0000080000000000L});
    public static final BitSet FOLLOW_PAGEVIEW_in_event_prim1848 = new BitSet(new long[]{0x0100000000008000L});
    public static final BitSet FOLLOW_STRING_in_event_prim1853 = new BitSet(new long[]{0x0000000800000002L});
    public static final BitSet FOLLOW_regex_in_event_prim1857 = new BitSet(new long[]{0x0000000800000002L});
    public static final BitSet FOLLOW_setting_in_event_prim1862 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WEB_in_event_prim1871 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_event_prim1876 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_event_prim1881 = new BitSet(new long[]{0x0000100800000002L});
    public static final BitSet FOLLOW_on_expr_in_event_prim1885 = new BitSet(new long[]{0x0000000800000002L});
    public static final BitSet FOLLOW_setting_in_event_prim1891 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_event_prim1901 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_event_prim1905 = new BitSet(new long[]{0x0000000800000082L});
    public static final BitSet FOLLOW_event_filter_in_event_prim1910 = new BitSet(new long[]{0x0000000800000082L});
    public static final BitSet FOLLOW_setting_in_event_prim1917 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_event_prim1927 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_seq_in_event_prim1931 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_event_prim1933 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_event_filter1952 = new BitSet(new long[]{0x0100000000008000L});
    public static final BitSet FOLLOW_STRING_in_event_filter1957 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_event_filter1963 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_ON_in_on_expr1982 = new BitSet(new long[]{0x0100000000008000L});
    public static final BitSet FOLLOW_STRING_in_on_expr1990 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_on_expr2001 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_GLOBAL_in_global_block2039 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_global_block2041 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_emit_block_in_global_block2048 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_must_be_one_in_global_block2058 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_global_block2063 = new BitSet(new long[]{0x0000800000020000L});
    public static final BitSet FOLLOW_COLON_in_global_block2066 = new BitSet(new long[]{0x0000400000000000L});
    public static final BitSet FOLLOW_DTYPE_in_global_block2070 = new BitSet(new long[]{0x0000800000000000L});
    public static final BitSet FOLLOW_LEFT_SMALL_ARROW_in_global_block2074 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_global_block2078 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000038L});
    public static final BitSet FOLLOW_cachable_in_global_block2083 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_css_emit_in_global_block2098 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_decl_in_global_block2106 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_SEMI_in_global_block2112 = new BitSet(new long[]{0x00000000000002C0L,0x0000000000000028L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_global_block2117 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_decl2144 = new BitSet(new long[]{0x0000000000004000L});
    public static final BitSet FOLLOW_EQUAL_in_decl2146 = new BitSet(new long[]{0x7B0301023C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_HTML_in_decl2151 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_decl2155 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expr_in_decl2159 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_function_def_in_expr2189 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_conditional_expression_in_expr2198 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FUNCTION_in_function_def2223 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_function_def2225 = new BitSet(new long[]{0x00000000C0000080L});
    public static final BitSet FOLLOW_VAR_in_function_def2229 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_function_def2233 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_function_def2237 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_function_def2242 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_function_def2244 = new BitSet(new long[]{0x7B0201003C0183A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_decl_in_function_def2248 = new BitSet(new long[]{0x7B0201003C0183A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_SEMI_in_function_def2253 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_decl_in_function_def2257 = new BitSet(new long[]{0x7B0201003C0183A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_SEMI_in_function_def2262 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_function_def2267 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_function_def2269 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_disjunction_in_conditional_expression2295 = new BitSet(new long[]{0x0000000002000002L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_conditional_expression2298 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_conditional_expression2302 = new BitSet(new long[]{0x0004000000000000L});
    public static final BitSet FOLLOW_PIPE_in_conditional_expression2304 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_conditional_expression2308 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_equality_expr_in_disjunction2340 = new BitSet(new long[]{0x0018000000000002L});
    public static final BitSet FOLLOW_set_in_disjunction2345 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_equality_expr_in_disjunction2353 = new BitSet(new long[]{0x0018000000000002L});
    public static final BitSet FOLLOW_add_expr_in_equality_expr2384 = new BitSet(new long[]{0x0020000000000002L});
    public static final BitSet FOLLOW_PREDOP_in_equality_expr2389 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_add_expr_in_equality_expr2393 = new BitSet(new long[]{0x0020000000000002L});
    public static final BitSet FOLLOW_unary_expr_in_add_expr2427 = new BitSet(new long[]{0x01C0000000000002L});
    public static final BitSet FOLLOW_set_in_add_expr2433 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_unary_expr_in_add_expr2443 = new BitSet(new long[]{0x01C0000000000002L});
    public static final BitSet FOLLOW_NOT_in_unary_expr2487 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_unary_expr_in_unary_expr2491 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_unary_expr2500 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2504 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_unary_expr2506 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2511 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2513 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_unary_expr2517 = new BitSet(new long[]{0x0000000000000002L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2521 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_unary_expr2529 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2533 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_unary_expr2537 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2542 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_unary_expr2545 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2550 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2552 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_unary_expr2556 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2565 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2567 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_unary_expr2571 = new BitSet(new long[]{0x0020000000000000L});
    public static final BitSet FOLLOW_PREDOP_in_unary_expr2575 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_unary_expr2579 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2583 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2593 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2595 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_unary_expr2599 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2603 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_unary_expr2612 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_operator_expr_in_unary_expr2621 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_factor_in_operator_expr2650 = new BitSet(new long[]{0x0400000000000002L});
    public static final BitSet FOLLOW_operator_in_operator_expr2656 = new BitSet(new long[]{0x0400000000000002L});
    public static final BitSet FOLLOW_DOT_in_operator2683 = new BitSet(new long[]{0x000000001C000000L});
    public static final BitSet FOLLOW_OTHER_OPERATORS_in_operator2689 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator2691 = new BitSet(new long[]{0x7B020100BC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_operator2696 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_operator2701 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_operator2705 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator2714 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MATCH_in_operator2738 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator2740 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_operator2744 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator2749 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_REPLACE_in_operator2774 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator2776 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_operator2780 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_COMMA_in_operator2784 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_operator2788 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator2791 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INT_in_factor2831 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_factor2846 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FLOAT_in_factor2866 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor2886 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_factor2906 = new BitSet(new long[]{0x4000000000000000L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_factor2908 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor2912 = new BitSet(new long[]{0x8000000000000000L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_factor2914 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor2929 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_factor2931 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_factor2935 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CURRENT_in_factor2947 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor2951 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_factor2953 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_factor2957 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_HISTORY_in_factor2970 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor2974 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor2978 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_factor2980 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_factor2984 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_namespace_in_factor2998 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_factor3002 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3004 = new BitSet(new long[]{0x7B020100BC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3009 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_factor3015 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3019 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3028 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_factor3043 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3045 = new BitSet(new long[]{0x7B020100BC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3050 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_factor3055 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3059 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3068 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_factor3080 = new BitSet(new long[]{0xFB0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3085 = new BitSet(new long[]{0x8000000040000000L});
    public static final BitSet FOLLOW_COMMA_in_factor3090 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3094 = new BitSet(new long[]{0x8000000040000000L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_factor3102 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_CURL_in_factor3114 = new BitSet(new long[]{0x0000000000008040L});
    public static final BitSet FOLLOW_hash_line_in_factor3119 = new BitSet(new long[]{0x0000000040000040L});
    public static final BitSet FOLLOW_COMMA_in_factor3124 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_hash_line_in_factor3128 = new BitSet(new long[]{0x0000000040000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_factor3137 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3149 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_factor3153 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3156 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor3175 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_factor3199 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_namespace3232 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_namespace3234 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITHIN_in_timeframe3256 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_timeframe3260 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_period_in_timeframe3264 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_hash_line3291 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_hash_line3293 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_hash_line3297 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CSS_in_css_emit3315 = new BitSet(new long[]{0x0001000000008000L});
    public static final BitSet FOLLOW_HTML_in_css_emit3321 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_css_emit3329 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_period3349 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CACHABLE_in_cachable3383 = new BitSet(new long[]{0x0000000000400002L});
    public static final BitSet FOLLOW_FOR_in_cachable3386 = new BitSet(new long[]{0x0000000000000100L});
    public static final BitSet FOLLOW_INT_in_cachable3390 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_period_in_cachable3394 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_EMIT_in_emit_block3416 = new BitSet(new long[]{0x0001000200008000L});
    public static final BitSet FOLLOW_HTML_in_emit_block3422 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_emit_block3430 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_emit_block3438 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_META_in_meta_block3467 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_meta_block3469 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_must_be_one_in_meta_block3478 = new BitSet(new long[]{0x0001000000008000L});
    public static final BitSet FOLLOW_HTML_in_meta_block3484 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_STRING_in_meta_block3488 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_KEY_in_meta_block3502 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_meta_block3506 = new BitSet(new long[]{0x0000000000008020L});
    public static final BitSet FOLLOW_STRING_in_meta_block3512 = new BitSet(new long[]{0x00000000000080E0L,0x0000000000001580L});
    public static final BitSet FOLLOW_LEFT_CURL_in_meta_block3520 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_name_value_pair_in_meta_block3523 = new BitSet(new long[]{0x0000000040000040L});
    public static final BitSet FOLLOW_COMMA_in_meta_block3527 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_name_value_pair_in_meta_block3529 = new BitSet(new long[]{0x0000000040000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_meta_block3535 = new BitSet(new long[]{0x00000000000080E0L,0x0000000000001580L});
    public static final BitSet FOLLOW_AUTHZ_in_meta_block3547 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000200L});
    public static final BitSet FOLLOW_REQUIRE_in_meta_block3549 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_meta_block3551 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_LOGGING_in_meta_block3560 = new BitSet(new long[]{0x0000100000000000L,0x0000000000000800L});
    public static final BitSet FOLLOW_set_in_meta_block3564 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_USE_in_meta_block3575 = new BitSet(new long[]{0x0000000000000000L,0x0000000000006008L});
    public static final BitSet FOLLOW_set_in_meta_block3582 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_meta_block3588 = new BitSet(new long[]{0x0000000000008080L});
    public static final BitSet FOLLOW_STRING_in_meta_block3594 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_VAR_in_meta_block3600 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_MODULE_in_meta_block3615 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_meta_block3620 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000009580L});
    public static final BitSet FOLLOW_ALIAS_in_meta_block3623 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_meta_block3627 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000001580L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_meta_block3642 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_dispatch_block3673 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_dispatch_block3677 = new BitSet(new long[]{0x00000000000000C0L});
    public static final BitSet FOLLOW_must_be_in_dispatch_block3681 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_dispatch_block3686 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000010000L});
    public static final BitSet FOLLOW_RIGHT_SMALL_ARROW_in_dispatch_block3689 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_dispatch_block3693 = new BitSet(new long[]{0x00000000000000C0L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_dispatch_block3704 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_name_value_pair3727 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_name_value_pair3729 = new BitSet(new long[]{0x0800000000008100L});
    public static final BitSet FOLLOW_INT_in_name_value_pair3737 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FLOAT_in_name_value_pair3748 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_name_value_pair3759 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_REX_in_regex3805 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred10_RuleSet326 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_emit_block_in_synpred11_RuleSet331 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred12_RuleSet334 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred13_RuleSet341 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred16_RuleSet351 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_expr_in_synpred25_RuleSet504 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_log_statement_in_synpred27_RuleSet521 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred43_RuleSet1126 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_synpred75_RuleSet1673 = new BitSet(new long[]{0x00000C0020000080L});
    public static final BitSet FOLLOW_event_or_in_synpred75_RuleSet1678 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred114_RuleSet2433 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_unary_expr_in_synpred114_RuleSet2443 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_timeframe_in_synpred116_RuleSet2521 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_synpred117_RuleSet2500 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_synpred117_RuleSet2504 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_synpred117_RuleSet2506 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred117_RuleSet2511 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_synpred117_RuleSet2513 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_synpred117_RuleSet2517 = new BitSet(new long[]{0x0000000000000002L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_synpred117_RuleSet2521 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_synpred118_RuleSet2529 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_synpred118_RuleSet2533 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_synpred118_RuleSet2537 = new BitSet(new long[]{0x0000000000008000L});
    public static final BitSet FOLLOW_STRING_in_synpred118_RuleSet2542 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_synpred118_RuleSet2545 = new BitSet(new long[]{0x0000000000010000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred118_RuleSet2550 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_synpred118_RuleSet2552 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_synpred118_RuleSet2556 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred119_RuleSet2565 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_synpred119_RuleSet2567 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_synpred119_RuleSet2571 = new BitSet(new long[]{0x0020000000000000L});
    public static final BitSet FOLLOW_PREDOP_in_synpred119_RuleSet2575 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred119_RuleSet2579 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_synpred119_RuleSet2583 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred120_RuleSet2593 = new BitSet(new long[]{0x0000000000020000L});
    public static final BitSet FOLLOW_COLON_in_synpred120_RuleSet2595 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_synpred120_RuleSet2599 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000004L});
    public static final BitSet FOLLOW_timeframe_in_synpred120_RuleSet2603 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_synpred121_RuleSet2612 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_synpred132_RuleSet2906 = new BitSet(new long[]{0x4000000000000000L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_synpred132_RuleSet2908 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred132_RuleSet2912 = new BitSet(new long[]{0x8000000000000000L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_synpred132_RuleSet2914 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_namespace_in_synpred138_RuleSet2998 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_synpred138_RuleSet3002 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_synpred138_RuleSet3004 = new BitSet(new long[]{0x7B020100BC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred138_RuleSet3009 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_synpred138_RuleSet3015 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred138_RuleSet3019 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_synpred138_RuleSet3028 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_synpred141_RuleSet3043 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_synpred141_RuleSet3045 = new BitSet(new long[]{0x7B020100BC0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred141_RuleSet3050 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_COMMA_in_synpred141_RuleSet3055 = new BitSet(new long[]{0x7B0201003C0181A0L,0x0000000000000003L});
    public static final BitSet FOLLOW_expr_in_synpred141_RuleSet3059 = new BitSet(new long[]{0x00000000C0000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_synpred141_RuleSet3068 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred152_RuleSet3175 = new BitSet(new long[]{0x0000000000000002L});

}