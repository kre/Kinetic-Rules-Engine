// $ANTLR 3.2 Sep 23, 2009 12:02:23 RuleSet.g 2010-09-08 16:59:34

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
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_SET", "LEFT_CURL", "RIGHT_CURL", "VAR", "INT", "OTHER_OPERATORS", "LIKE", "REPLACE", "MATCH", "SEMI", "IF", "CALLBACKS", "SUCCESS", "FAILURE", "EQUAL", "STRING", "VAR_DOMAIN", "COLON", "COUNTER_OP", "FORGET", "MARK", "WITH", "FOR", "EVERY", "CHOOSE", "ARROW_RIGHT", "LEFT_PAREN", "COMMA", "RIGHT_PAREN", "AND_AND", "JS", "USING", "SETTING", "PRE", "FOREACH", "WHEN", "OR_OR", "NOT", "BETWEEN", "WEB", "PAGEVIEW", "ON", "GLOBAL", "DTYPE", "LEFT_SMALL_ARROW", "HTML", "FUNCTION", "PIPE", "OR", "AND", "PREDOP", "MULT_OP", "ADD_OP", "REX", "SEEN", "DOT", "FLOAT", "TRUE", "FALSE", "LEFT_BRACKET", "RIGHT_BRACKET", "CURRENT", "HISTORY", "WITHIN", "CSS", "CACHABLE", "EMIT", "META", "KEY", "AUTHZ", "REQUIRE", "LOGGING", "OFF", "USE", "JAVASCRIPT", "MODULE", "ALIAS", "RIGHT_SMALL_ARROW", "ESC_SEQ", "COMMENT", "WS", "POUND", "EXPONENT", "HEX_DIGIT", "UNICODE_ESC", "OCTAL_ESC"
    };
    public static final int FUNCTION=50;
    public static final int ARROW_RIGHT=29;
    public static final int EXPONENT=86;
    public static final int LEFT_BRACKET=63;
    public static final int OCTAL_ESC=89;
    public static final int EMIT=70;
    public static final int FOR=26;
    public static final int FLOAT=60;
    public static final int PRE=37;
    public static final int HTML=49;
    public static final int NOT=41;
    public static final int AND=53;
    public static final int CALLBACKS=15;
    public static final int EOF=-1;
    public static final int REQUIRE=74;
    public static final int META=71;
    public static final int IF=14;
    public static final int LEFT_CURL=5;
    public static final int HISTORY=66;
    public static final int SUCCESS=16;
    public static final int RULE_SET=4;
    public static final int RIGHT_PAREN=32;
    public static final int ESC_SEQ=82;
    public static final int REX=57;
    public static final int SETTING=36;
    public static final int CSS=68;
    public static final int USING=35;
    public static final int COMMA=31;
    public static final int OFF=76;
    public static final int REPLACE=11;
    public static final int AND_AND=33;
    public static final int EQUAL=18;
    public static final int FAILURE=17;
    public static final int RIGHT_SMALL_ARROW=81;
    public static final int RIGHT_BRACKET=64;
    public static final int PIPE=51;
    public static final int LEFT_SMALL_ARROW=48;
    public static final int RIGHT_CURL=6;
    public static final int VAR=7;
    public static final int PREDOP=54;
    public static final int COMMENT=83;
    public static final int DOT=59;
    public static final int LIKE=10;
    public static final int VAR_DOMAIN=20;
    public static final int WITH=25;
    public static final int AUTHZ=73;
    public static final int MULT_OP=55;
    public static final int OTHER_OPERATORS=9;
    public static final int OR_OR=40;
    public static final int CHOOSE=28;
    public static final int MARK=24;
    public static final int POUND=85;
    public static final int KEY=72;
    public static final int WEB=43;
    public static final int UNICODE_ESC=88;
    public static final int ADD_OP=56;
    public static final int JS=34;
    public static final int EVERY=27;
    public static final int ON=45;
    public static final int HEX_DIGIT=87;
    public static final int CACHABLE=69;
    public static final int MATCH=12;
    public static final int INT=8;
    public static final int MODULE=79;
    public static final int LOGGING=75;
    public static final int TRUE=61;
    public static final int SEMI=13;
    public static final int DTYPE=47;
    public static final int CURRENT=65;
    public static final int SEEN=58;
    public static final int COLON=21;
    public static final int COUNTER_OP=22;
    public static final int WS=84;
    public static final int JAVASCRIPT=78;
    public static final int WHEN=39;
    public static final int OR=52;
    public static final int ALIAS=80;
    public static final int PAGEVIEW=44;
    public static final int WITHIN=67;
    public static final int LEFT_PAREN=30;
    public static final int FORGET=23;
    public static final int FOREACH=38;
    public static final int USE=77;
    public static final int GLOBAL=46;
    public static final int FALSE=62;
    public static final int BETWEEN=42;
    public static final int STRING=19;

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


    public static class ruleset_return extends ParserRuleReturnScope {
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "ruleset"
    // RuleSet.g:250:1: ruleset options {backtrack=false; } : RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF ;
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
            // RuleSet.g:261:3: ( RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF )
            // RuleSet.g:262:3: RULE_SET rulesetname LEFT_CURL ( meta_block | dispatch_block | global_block | rule )* RIGHT_CURL EOF
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
            // RuleSet.g:264:4: ( meta_block | dispatch_block | global_block | rule )*
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
                    else if ( ((LA1_3>=VAR && LA1_3<=MATCH)) ) {
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
            	    // RuleSet.g:264:6: meta_block
            	    {
            	    pushFollow(FOLLOW_meta_block_in_ruleset116);
            	    meta_block4=meta_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, meta_block4.getTree());

            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:264:19: dispatch_block
            	    {
            	    pushFollow(FOLLOW_dispatch_block_in_ruleset120);
            	    dispatch_block5=dispatch_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, dispatch_block5.getTree());

            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:264:36: global_block
            	    {
            	    pushFollow(FOLLOW_global_block_in_ruleset124);
            	    global_block6=global_block();

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, global_block6.getTree());

            	    }
            	    break;
            	case 4 :
            	    // RuleSet.g:264:51: rule
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
    // RuleSet.g:269:1: must_be[String what] : v= VAR ;
    public final RuleSetParser.must_be_return must_be(String what) throws RecognitionException {
        RuleSetParser.must_be_return retval = new RuleSetParser.must_be_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;

        Object v_tree=null;

        try {
            // RuleSet.g:270:3: (v= VAR )
            // RuleSet.g:271:3: v= VAR
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
    // RuleSet.g:274:1: must_be_one[String[] what] : v= VAR ;
    public final RuleSetParser.must_be_one_return must_be_one(String[] what) throws RecognitionException {
        RuleSetParser.must_be_one_return retval = new RuleSetParser.must_be_one_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;

        Object v_tree=null;

        try {
            // RuleSet.g:275:3: (v= VAR )
            // RuleSet.g:276:3: v= VAR
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
    // RuleSet.g:279:2: rulesetname : ( VAR | INT );
    public final RuleSetParser.rulesetname_return rulesetname() throws RecognitionException {
        RuleSetParser.rulesetname_return retval = new RuleSetParser.rulesetname_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token set10=null;

        Object set10_tree=null;

        try {
            // RuleSet.g:280:2: ( VAR | INT )
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
    // RuleSet.g:289:2: rule_name : ( VAR | INT | OTHER_OPERATORS | LIKE | REPLACE | MATCH );
    public final RuleSetParser.rule_name_return rule_name() throws RecognitionException {
        RuleSetParser.rule_name_return retval = new RuleSetParser.rule_name_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token set11=null;

        Object set11_tree=null;

        try {
            // RuleSet.g:290:2: ( VAR | INT | OTHER_OPERATORS | LIKE | REPLACE | MATCH )
            // RuleSet.g:
            {
            root_0 = (Object)adaptor.nil();

            set11=(Token)input.LT(1);
            if ( (input.LA(1)>=VAR && input.LA(1)<=MATCH) ) {
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
    // RuleSet.g:294:1: rule : must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL ;
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
            // RuleSet.g:301:3: ( must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:301:6: must_be[\"rule\"] name= rule_name must_be[\"is\"] ait= must_be_one[sar(\"active\",\"inactive\",\"test\")] LEFT_CURL select= VAR (ptu= using | ptw= when ) (f= foreach )* (pb= pre_block )? ( SEMI )? (eb= emit_block )? ( SEMI )? ( action[actions_result] ( SEMI )? )* (cb= callbacks )? ( SEMI )? (postb= post_block )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_rule257);
            must_be12=must_be("rule");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be12.getTree());
            pushFollow(FOLLOW_rule_name_in_rule264);
            name=rule_name();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, name.getTree());
            pushFollow(FOLLOW_must_be_in_rule275);
            must_be13=must_be("is");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be13.getTree());
            pushFollow(FOLLOW_must_be_one_in_rule287);
            ait=must_be_one(sar("active","inactive","test"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ait.getTree());
            LEFT_CURL14=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_rule292); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL14_tree = (Object)adaptor.create(LEFT_CURL14);
            adaptor.addChild(root_0, LEFT_CURL14_tree);
            }
            select=(Token)match(input,VAR,FOLLOW_VAR_in_rule302); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            select_tree = (Object)adaptor.create(select);
            adaptor.addChild(root_0, select_tree);
            }
            if ( state.backtracking==0 ) {
               cn((select!=null?select.getText():null), sar("select"),input); 
            }
            // RuleSet.g:307:60: (ptu= using | ptw= when )
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
                    // RuleSet.g:307:61: ptu= using
                    {
                    pushFollow(FOLLOW_using_in_rule309);
                    ptu=using();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ptu.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:307:71: ptw= when
                    {
                    pushFollow(FOLLOW_when_in_rule313);
                    ptw=when();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ptw.getTree());

                    }
                    break;

            }

            // RuleSet.g:307:81: (f= foreach )*
            loop3:
            do {
                int alt3=2;
                int LA3_0 = input.LA(1);

                if ( (LA3_0==FOREACH) ) {
                    alt3=1;
                }


                switch (alt3) {
            	case 1 :
            	    // RuleSet.g:307:82: f= foreach
            	    {
            	    pushFollow(FOLLOW_foreach_in_rule319);
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

            // RuleSet.g:308:8: (pb= pre_block )?
            int alt4=2;
            int LA4_0 = input.LA(1);

            if ( (LA4_0==PRE) ) {
                alt4=1;
            }
            switch (alt4) {
                case 1 :
                    // RuleSet.g:0:0: pb= pre_block
                    {
                    pushFollow(FOLLOW_pre_block_in_rule332);
                    pb=pre_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pb.getTree());

                    }
                    break;

            }

            // RuleSet.g:308:20: ( SEMI )?
            int alt5=2;
            int LA5_0 = input.LA(1);

            if ( (LA5_0==SEMI) ) {
                int LA5_1 = input.LA(2);

                if ( (synpred14_RuleSet()) ) {
                    alt5=1;
                }
            }
            switch (alt5) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI15=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule335); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI15_tree = (Object)adaptor.create(SEMI15);
                    adaptor.addChild(root_0, SEMI15_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:308:28: (eb= emit_block )?
            int alt6=2;
            int LA6_0 = input.LA(1);

            if ( (LA6_0==EMIT) ) {
                switch ( input.LA(2) ) {
                    case HTML:
                        {
                        int LA6_3 = input.LA(3);

                        if ( (synpred15_RuleSet()) ) {
                            alt6=1;
                        }
                        }
                        break;
                    case STRING:
                        {
                        int LA6_4 = input.LA(3);

                        if ( (synpred15_RuleSet()) ) {
                            alt6=1;
                        }
                        }
                        break;
                    case JS:
                        {
                        int LA6_5 = input.LA(3);

                        if ( (synpred15_RuleSet()) ) {
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
                    pushFollow(FOLLOW_emit_block_in_rule340);
                    eb=emit_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, eb.getTree());

                    }
                    break;

            }

            // RuleSet.g:308:41: ( SEMI )?
            int alt7=2;
            int LA7_0 = input.LA(1);

            if ( (LA7_0==SEMI) ) {
                int LA7_1 = input.LA(2);

                if ( (synpred16_RuleSet()) ) {
                    alt7=1;
                }
            }
            switch (alt7) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI16=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule343); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI16_tree = (Object)adaptor.create(SEMI16);
                    adaptor.addChild(root_0, SEMI16_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:308:47: ( action[actions_result] ( SEMI )? )*
            loop9:
            do {
                int alt9=2;
                int LA9_0 = input.LA(1);

                if ( (LA9_0==VAR) ) {
                    int LA9_2 = input.LA(2);

                    if ( (LA9_2==COLON||(LA9_2>=ARROW_RIGHT && LA9_2<=LEFT_PAREN)) ) {
                        alt9=1;
                    }


                }
                else if ( (LA9_0==LEFT_CURL||(LA9_0>=OTHER_OPERATORS && LA9_0<=MATCH)||LA9_0==IF||LA9_0==VAR_DOMAIN||(LA9_0>=EVERY && LA9_0<=CHOOSE)||LA9_0==EMIT) ) {
                    alt9=1;
                }


                switch (alt9) {
            	case 1 :
            	    // RuleSet.g:308:48: action[actions_result] ( SEMI )?
            	    {
            	    pushFollow(FOLLOW_action_in_rule347);
            	    action17=action(actions_result);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, action17.getTree());
            	    // RuleSet.g:308:71: ( SEMI )?
            	    int alt8=2;
            	    int LA8_0 = input.LA(1);

            	    if ( (LA8_0==SEMI) ) {
            	        int LA8_1 = input.LA(2);

            	        if ( (synpred17_RuleSet()) ) {
            	            alt8=1;
            	        }
            	    }
            	    switch (alt8) {
            	        case 1 :
            	            // RuleSet.g:0:0: SEMI
            	            {
            	            SEMI18=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule350); if (state.failed) return retval;
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

            // RuleSet.g:308:81: (cb= callbacks )?
            int alt10=2;
            int LA10_0 = input.LA(1);

            if ( (LA10_0==CALLBACKS) ) {
                alt10=1;
            }
            switch (alt10) {
                case 1 :
                    // RuleSet.g:0:0: cb= callbacks
                    {
                    pushFollow(FOLLOW_callbacks_in_rule357);
                    cb=callbacks();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, cb.getTree());

                    }
                    break;

            }

            // RuleSet.g:308:93: ( SEMI )?
            int alt11=2;
            int LA11_0 = input.LA(1);

            if ( (LA11_0==SEMI) ) {
                int LA11_1 = input.LA(2);

                if ( (synpred20_RuleSet()) ) {
                    alt11=1;
                }
            }
            switch (alt11) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI19=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule360); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI19_tree = (Object)adaptor.create(SEMI19);
                    adaptor.addChild(root_0, SEMI19_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:308:104: (postb= post_block )?
            int alt12=2;
            int LA12_0 = input.LA(1);

            if ( (LA12_0==VAR) ) {
                alt12=1;
            }
            switch (alt12) {
                case 1 :
                    // RuleSet.g:0:0: postb= post_block
                    {
                    pushFollow(FOLLOW_post_block_in_rule365);
                    postb=post_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, postb.getTree());

                    }
                    break;

            }

            // RuleSet.g:308:117: ( SEMI )?
            int alt13=2;
            int LA13_0 = input.LA(1);

            if ( (LA13_0==SEMI) ) {
                alt13=1;
            }
            switch (alt13) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI20=(Token)match(input,SEMI,FOLLOW_SEMI_in_rule368); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI20_tree = (Object)adaptor.create(SEMI20);
                    adaptor.addChild(root_0, SEMI20_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL21=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_rule373); if (state.failed) return retval;
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
              //			if((postb!=null?input.toString(postb.start,postb.stop):null) != null)
              				current_rule.put("post",(postb!=null?postb.result:null));
              			
              			if((pb!=null?input.toString(pb.start,pb.stop):null) != null)
              				current_rule.put("pre",(pb!=null?pb.result:null));
              			else
              			    current_rule.put("pre",new ArrayList());
              			
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
    // RuleSet.g:361:1: post_block returns [HashMap result] : typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )? ;
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
            // RuleSet.g:365:2: (typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )? )
            // RuleSet.g:366:2: typ= must_be_one[sar(\"fired\",\"always\",\"notfired\")] LEFT_CURL p1= post_statement ( SEMI p2= post_statement )* ( SEMI )? RIGHT_CURL (alt= post_alternate )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_post_block404);
            typ=must_be_one(sar("fired","always","notfired"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, typ.getTree());
            LEFT_CURL22=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_post_block407); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL22_tree = (Object)adaptor.create(LEFT_CURL22);
            adaptor.addChild(root_0, LEFT_CURL22_tree);
            }
            pushFollow(FOLLOW_post_statement_in_post_block414);
            p1=post_statement();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p1.getTree());
            if ( state.backtracking==0 ) {
               temp_list.add((p1!=null?p1.result:null));
            }
            // RuleSet.g:367:51: ( SEMI p2= post_statement )*
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
            	    // RuleSet.g:367:52: SEMI p2= post_statement
            	    {
            	    SEMI23=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_block419); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI23_tree = (Object)adaptor.create(SEMI23);
            	    adaptor.addChild(root_0, SEMI23_tree);
            	    }
            	    pushFollow(FOLLOW_post_statement_in_post_block423);
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

            // RuleSet.g:367:109: ( SEMI )?
            int alt15=2;
            int LA15_0 = input.LA(1);

            if ( (LA15_0==SEMI) ) {
                alt15=1;
            }
            switch (alt15) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI24=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_block431); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI24_tree = (Object)adaptor.create(SEMI24);
                    adaptor.addChild(root_0, SEMI24_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL25=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_post_block434); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL25_tree = (Object)adaptor.create(RIGHT_CURL25);
            adaptor.addChild(root_0, RIGHT_CURL25_tree);
            }
            // RuleSet.g:368:6: (alt= post_alternate )?
            int alt16=2;
            int LA16_0 = input.LA(1);

            if ( (LA16_0==VAR) ) {
                alt16=1;
            }
            switch (alt16) {
                case 1 :
                    // RuleSet.g:0:0: alt= post_alternate
                    {
                    pushFollow(FOLLOW_post_alternate_in_post_block440);
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
              //		if((alt!=null?input.toString(alt.start,alt.stop):null) != null)
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
    // RuleSet.g:382:1: post_alternate returns [ArrayList result] : must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL ;
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
            // RuleSet.g:386:2: ( must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:387:3: must_be[\"else\"] LEFT_CURL (p= post_statement ( SEMI p1= post_statement )* )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_post_alternate467);
            must_be26=must_be("else");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be26.getTree());
            LEFT_CURL27=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_post_alternate470); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL27_tree = (Object)adaptor.create(LEFT_CURL27);
            adaptor.addChild(root_0, LEFT_CURL27_tree);
            }
            // RuleSet.g:387:29: (p= post_statement ( SEMI p1= post_statement )* )?
            int alt18=2;
            int LA18_0 = input.LA(1);

            if ( (LA18_0==VAR||LA18_0==VAR_DOMAIN||(LA18_0>=FORGET && LA18_0<=MARK)) ) {
                alt18=1;
            }
            switch (alt18) {
                case 1 :
                    // RuleSet.g:387:30: p= post_statement ( SEMI p1= post_statement )*
                    {
                    pushFollow(FOLLOW_post_statement_in_post_alternate475);
                    p=post_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
                    if ( state.backtracking==0 ) {
                      temp_array.add((p!=null?p.result:null));
                    }
                    // RuleSet.g:387:76: ( SEMI p1= post_statement )*
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
                    	    // RuleSet.g:387:77: SEMI p1= post_statement
                    	    {
                    	    SEMI28=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_alternate480); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    SEMI28_tree = (Object)adaptor.create(SEMI28);
                    	    adaptor.addChild(root_0, SEMI28_tree);
                    	    }
                    	    pushFollow(FOLLOW_post_statement_in_post_alternate484);
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

            // RuleSet.g:387:134: ( SEMI )?
            int alt19=2;
            int LA19_0 = input.LA(1);

            if ( (LA19_0==SEMI) ) {
                alt19=1;
            }
            switch (alt19) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI29=(Token)match(input,SEMI,FOLLOW_SEMI_in_post_alternate492); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI29_tree = (Object)adaptor.create(SEMI29);
                    adaptor.addChild(root_0, SEMI29_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL30=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_post_alternate495); if (state.failed) return retval;
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
    // RuleSet.g:391:1: post_statement returns [HashMap result] : ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? ) ;
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
            // RuleSet.g:392:2: ( ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? ) )
            // RuleSet.g:392:4: ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:392:4: ( (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )? )
            // RuleSet.g:392:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] ) ( IF ie= expr )?
            {
            // RuleSet.g:392:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] )
            int alt20=4;
            alt20 = dfa20.predict(input);
            switch (alt20) {
                case 1 :
                    // RuleSet.g:392:6: pe= persistent_expr
                    {
                    pushFollow(FOLLOW_persistent_expr_in_post_statement513);
                    pe=persistent_expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, pe.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:393:6: rs= raise_statement
                    {
                    pushFollow(FOLLOW_raise_statement_in_post_statement523);
                    rs=raise_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, rs.getTree());

                    }
                    break;
                case 3 :
                    // RuleSet.g:394:4: l= log_statement
                    {
                    pushFollow(FOLLOW_log_statement_in_post_statement530);
                    l=log_statement();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, l.getTree());

                    }
                    break;
                case 4 :
                    // RuleSet.g:395:4: las= must_be[\"last\"]
                    {
                    pushFollow(FOLLOW_must_be_in_post_statement540);
                    las=must_be("last");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, las.getTree());

                    }
                    break;

            }

            // RuleSet.g:396:2: ( IF ie= expr )?
            int alt21=2;
            int LA21_0 = input.LA(1);

            if ( (LA21_0==IF) ) {
                alt21=1;
            }
            switch (alt21) {
                case 1 :
                    // RuleSet.g:396:3: IF ie= expr
                    {
                    IF31=(Token)match(input,IF,FOLLOW_IF_in_post_statement546); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    IF31_tree = (Object)adaptor.create(IF31);
                    adaptor.addChild(root_0, IF31_tree);
                    }
                    pushFollow(FOLLOW_expr_in_post_statement550);
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
              		    if(retval.result == null)
              			    retval.result = new HashMap();
              			retval.result.put("test",(ie!=null?ie.result:null));
              		}
              		else
              		{
              		    if(retval.result == null)
              			    retval.result = new HashMap();
              			retval.result.put("test",null);

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
    // RuleSet.g:431:1: raise_statement returns [HashMap result] : must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )? ;
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
            // RuleSet.g:432:2: ( must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )? )
            // RuleSet.g:433:2: must_be[\"raise\"] must_be[\"explicit\"] must_be[\"event\"] evt= VAR (f= for_clause )? (m= modifier_clause )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_raise_statement575);
            must_be32=must_be("raise");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be32.getTree());
            pushFollow(FOLLOW_must_be_in_raise_statement578);
            must_be33=must_be("explicit");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be33.getTree());
            pushFollow(FOLLOW_must_be_in_raise_statement581);
            must_be34=must_be("event");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be34.getTree());
            evt=(Token)match(input,VAR,FOLLOW_VAR_in_raise_statement587); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            evt_tree = (Object)adaptor.create(evt);
            adaptor.addChild(root_0, evt_tree);
            }
            // RuleSet.g:433:66: (f= for_clause )?
            int alt22=2;
            int LA22_0 = input.LA(1);

            if ( (LA22_0==FOR) ) {
                alt22=1;
            }
            switch (alt22) {
                case 1 :
                    // RuleSet.g:0:0: f= for_clause
                    {
                    pushFollow(FOLLOW_for_clause_in_raise_statement591);
                    f=for_clause();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());

                    }
                    break;

            }

            // RuleSet.g:433:80: (m= modifier_clause )?
            int alt23=2;
            int LA23_0 = input.LA(1);

            if ( (LA23_0==WITH) ) {
                alt23=1;
            }
            switch (alt23) {
                case 1 :
                    // RuleSet.g:0:0: m= modifier_clause
                    {
                    pushFollow(FOLLOW_modifier_clause_in_raise_statement596);
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
              //		if((f!=null?input.toString(f.start,f.stop):null) != null)
              			tmp.put("rid",(f!=null?f.result:null));
              			
              //		if((m!=null?input.toString(m.start,m.stop):null) != null)
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
    // RuleSet.g:448:1: log_statement returns [HashMap result] : must_be[\"log\"] e= expr ;
    public final RuleSetParser.log_statement_return log_statement() throws RecognitionException {
        RuleSetParser.log_statement_return retval = new RuleSetParser.log_statement_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.must_be_return must_be35 = null;



        try {
            // RuleSet.g:449:2: ( must_be[\"log\"] e= expr )
            // RuleSet.g:450:2: must_be[\"log\"] e= expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_log_statement616);
            must_be35=must_be("log");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be35.getTree());
            pushFollow(FOLLOW_expr_in_log_statement622);
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
    // RuleSet.g:458:1: callbacks returns [HashMap result] : CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL ;
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
            // RuleSet.g:459:2: ( CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL )
            // RuleSet.g:460:2: CALLBACKS LEFT_CURL (s= success )? (f= failure )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            CALLBACKS36=(Token)match(input,CALLBACKS,FOLLOW_CALLBACKS_in_callbacks640); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            CALLBACKS36_tree = (Object)adaptor.create(CALLBACKS36);
            adaptor.addChild(root_0, CALLBACKS36_tree);
            }
            LEFT_CURL37=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_callbacks642); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL37_tree = (Object)adaptor.create(LEFT_CURL37);
            adaptor.addChild(root_0, LEFT_CURL37_tree);
            }
            // RuleSet.g:460:23: (s= success )?
            int alt24=2;
            int LA24_0 = input.LA(1);

            if ( (LA24_0==SUCCESS) ) {
                alt24=1;
            }
            switch (alt24) {
                case 1 :
                    // RuleSet.g:0:0: s= success
                    {
                    pushFollow(FOLLOW_success_in_callbacks646);
                    s=success();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, s.getTree());

                    }
                    break;

            }

            // RuleSet.g:460:34: (f= failure )?
            int alt25=2;
            int LA25_0 = input.LA(1);

            if ( (LA25_0==FAILURE) ) {
                alt25=1;
            }
            switch (alt25) {
                case 1 :
                    // RuleSet.g:0:0: f= failure
                    {
                    pushFollow(FOLLOW_failure_in_callbacks651);
                    f=failure();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());

                    }
                    break;

            }

            RIGHT_CURL38=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_callbacks654); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL38_tree = (Object)adaptor.create(RIGHT_CURL38);
            adaptor.addChild(root_0, RIGHT_CURL38_tree);
            }
            if ( state.backtracking==0 ) {

              		HashMap tmp = new HashMap();
              //		if((s!=null?input.toString(s.start,s.stop):null) != null)
              		{
              			tmp.put("success",(s!=null?s.result:null));
              			
              		}
              //		if((f!=null?input.toString(f.start,f.stop):null) != null)
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
    // RuleSet.g:474:1: success returns [ArrayList result] : SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL ;
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
            // RuleSet.g:478:2: ( SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL )
            // RuleSet.g:478:4: SUCCESS LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            SUCCESS39=(Token)match(input,SUCCESS,FOLLOW_SUCCESS_in_success676); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            SUCCESS39_tree = (Object)adaptor.create(SUCCESS39);
            adaptor.addChild(root_0, SUCCESS39_tree);
            }
            LEFT_CURL40=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_success678); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL40_tree = (Object)adaptor.create(LEFT_CURL40);
            adaptor.addChild(root_0, LEFT_CURL40_tree);
            }
            pushFollow(FOLLOW_click_in_success682);
            c=click();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, c.getTree());
            if ( state.backtracking==0 ) {
              tmp_list.add((c!=null?c.result:null));
            }
            // RuleSet.g:478:58: ( SEMI c1= click )*
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
            	    // RuleSet.g:478:59: SEMI c1= click
            	    {
            	    SEMI41=(Token)match(input,SEMI,FOLLOW_SEMI_in_success688); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI41_tree = (Object)adaptor.create(SEMI41);
            	    adaptor.addChild(root_0, SEMI41_tree);
            	    }
            	    pushFollow(FOLLOW_click_in_success692);
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

            // RuleSet.g:478:104: ( SEMI )?
            int alt27=2;
            int LA27_0 = input.LA(1);

            if ( (LA27_0==SEMI) ) {
                alt27=1;
            }
            switch (alt27) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI42=(Token)match(input,SEMI,FOLLOW_SEMI_in_success699); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI42_tree = (Object)adaptor.create(SEMI42);
                    adaptor.addChild(root_0, SEMI42_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL43=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_success703); if (state.failed) return retval;
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
    // RuleSet.g:484:1: failure returns [ArrayList result] : FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL ;
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
            // RuleSet.g:488:2: ( FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL )
            // RuleSet.g:489:2: FAILURE LEFT_CURL c= click ( SEMI c1= click )* ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            FAILURE44=(Token)match(input,FAILURE,FOLLOW_FAILURE_in_failure731); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FAILURE44_tree = (Object)adaptor.create(FAILURE44);
            adaptor.addChild(root_0, FAILURE44_tree);
            }
            LEFT_CURL45=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_failure733); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL45_tree = (Object)adaptor.create(LEFT_CURL45);
            adaptor.addChild(root_0, LEFT_CURL45_tree);
            }
            pushFollow(FOLLOW_click_in_failure737);
            c=click();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, c.getTree());
            if ( state.backtracking==0 ) {
              tmp_list.add((c!=null?c.result:null));
            }
            // RuleSet.g:489:56: ( SEMI c1= click )*
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
            	    // RuleSet.g:489:57: SEMI c1= click
            	    {
            	    SEMI46=(Token)match(input,SEMI,FOLLOW_SEMI_in_failure743); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI46_tree = (Object)adaptor.create(SEMI46);
            	    adaptor.addChild(root_0, SEMI46_tree);
            	    }
            	    pushFollow(FOLLOW_click_in_failure747);
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

            // RuleSet.g:489:103: ( SEMI )?
            int alt29=2;
            int LA29_0 = input.LA(1);

            if ( (LA29_0==SEMI) ) {
                alt29=1;
            }
            switch (alt29) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI47=(Token)match(input,SEMI,FOLLOW_SEMI_in_failure755); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI47_tree = (Object)adaptor.create(SEMI47);
                    adaptor.addChild(root_0, SEMI47_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL48=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_failure759); if (state.failed) return retval;
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
    // RuleSet.g:494:1: click returns [HashMap result] : corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )? ;
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
            // RuleSet.g:494:31: (corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )? )
            // RuleSet.g:495:2: corc= must_be_one[sar(\"click\",\"change\")] attr= VAR EQUAL val= STRING (cl= click_link )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_click777);
            corc=must_be_one(sar("click","change"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, corc.getTree());
            attr=(Token)match(input,VAR,FOLLOW_VAR_in_click782); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            attr_tree = (Object)adaptor.create(attr);
            adaptor.addChild(root_0, attr_tree);
            }
            EQUAL49=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_click784); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL49_tree = (Object)adaptor.create(EQUAL49);
            adaptor.addChild(root_0, EQUAL49_tree);
            }
            val=(Token)match(input,STRING,FOLLOW_STRING_in_click788); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            val_tree = (Object)adaptor.create(val);
            adaptor.addChild(root_0, val_tree);
            }
            // RuleSet.g:495:70: (cl= click_link )?
            int alt30=2;
            int LA30_0 = input.LA(1);

            if ( (LA30_0==VAR) ) {
                alt30=1;
            }
            switch (alt30) {
                case 1 :
                    // RuleSet.g:0:0: cl= click_link
                    {
                    pushFollow(FOLLOW_click_link_in_click792);
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
    // RuleSet.g:505:1: click_link returns [HashMap result] : must_be[\"triggers\"] p= persistent_expr ;
    public final RuleSetParser.click_link_return click_link() throws RecognitionException {
        RuleSetParser.click_link_return retval = new RuleSetParser.click_link_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.persistent_expr_return p = null;

        RuleSetParser.must_be_return must_be50 = null;



        try {
            // RuleSet.g:506:2: ( must_be[\"triggers\"] p= persistent_expr )
            // RuleSet.g:507:2: must_be[\"triggers\"] p= persistent_expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_click_link812);
            must_be50=must_be("triggers");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be50.getTree());
            pushFollow(FOLLOW_persistent_expr_in_click_link817);
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
    // RuleSet.g:513:1: persistent_expr returns [HashMap result] : (pc= persistent_clear_set | pi= persistent_iterate | tf= trail_forget | tm= trail_mark );
    public final RuleSetParser.persistent_expr_return persistent_expr() throws RecognitionException {
        RuleSetParser.persistent_expr_return retval = new RuleSetParser.persistent_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.persistent_clear_set_return pc = null;

        RuleSetParser.persistent_iterate_return pi = null;

        RuleSetParser.trail_forget_return tf = null;

        RuleSetParser.trail_mark_return tm = null;



        try {
            // RuleSet.g:514:2: (pc= persistent_clear_set | pi= persistent_iterate | tf= trail_forget | tm= trail_mark )
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
                    // RuleSet.g:515:2: pc= persistent_clear_set
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_persistent_clear_set_in_persistent_expr839);
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
                    // RuleSet.g:518:4: pi= persistent_iterate
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_persistent_iterate_in_persistent_expr849);
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
                    // RuleSet.g:521:7: tf= trail_forget
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_trail_forget_in_persistent_expr862);
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
                    // RuleSet.g:524:7: tm= trail_mark
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_trail_mark_in_persistent_expr875);
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
    // RuleSet.g:530:1: persistent_clear_set returns [HashMap result] : cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR ;
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
            // RuleSet.g:531:2: (cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR )
            // RuleSet.g:532:2: cs= must_be_one[sar(\"clear\",\"set\")] dm= VAR_DOMAIN COLON name= VAR
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_persistent_clear_set900);
            cs=must_be_one(sar("clear","set"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, cs.getTree());
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_persistent_clear_set906); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON51=(Token)match(input,COLON,FOLLOW_COLON_in_persistent_clear_set908); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON51_tree = (Object)adaptor.create(COLON51);
            adaptor.addChild(root_0, COLON51_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_persistent_clear_set912); if (state.failed) return retval;
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
    // RuleSet.g:543:1: persistent_iterate returns [HashMap result] : dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start ;
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
            // RuleSet.g:544:2: (dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start )
            // RuleSet.g:545:2: dm= VAR_DOMAIN COLON name= VAR op= COUNTER_OP v= expr from= counter_start
            {
            root_0 = (Object)adaptor.nil();

            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_persistent_iterate933); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON52=(Token)match(input,COLON,FOLLOW_COLON_in_persistent_iterate935); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON52_tree = (Object)adaptor.create(COLON52);
            adaptor.addChild(root_0, COLON52_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_persistent_iterate939); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            op=(Token)match(input,COUNTER_OP,FOLLOW_COUNTER_OP_in_persistent_iterate943); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            op_tree = (Object)adaptor.create(op);
            adaptor.addChild(root_0, op_tree);
            }
            pushFollow(FOLLOW_expr_in_persistent_iterate947);
            v=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, v.getTree());
            pushFollow(FOLLOW_counter_start_in_persistent_iterate951);
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
    // RuleSet.g:557:1: trail_forget returns [HashMap result] : FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR ;
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
            // RuleSet.g:558:2: ( FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR )
            // RuleSet.g:559:2: FORGET what= STRING must_be[\"in\"] dm= VAR_DOMAIN COLON name= VAR
            {
            root_0 = (Object)adaptor.nil();

            FORGET53=(Token)match(input,FORGET,FOLLOW_FORGET_in_trail_forget968); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FORGET53_tree = (Object)adaptor.create(FORGET53);
            adaptor.addChild(root_0, FORGET53_tree);
            }
            what=(Token)match(input,STRING,FOLLOW_STRING_in_trail_forget973); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            what_tree = (Object)adaptor.create(what);
            adaptor.addChild(root_0, what_tree);
            }
            pushFollow(FOLLOW_must_be_in_trail_forget975);
            must_be54=must_be("in");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be54.getTree());
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_trail_forget981); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON55=(Token)match(input,COLON,FOLLOW_COLON_in_trail_forget983); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON55_tree = (Object)adaptor.create(COLON55);
            adaptor.addChild(root_0, COLON55_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_trail_forget987); if (state.failed) return retval;
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
    // RuleSet.g:571:1: trail_mark returns [HashMap result] : MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )? ;
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
            // RuleSet.g:572:2: ( MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )? )
            // RuleSet.g:573:2: MARK dm= VAR_DOMAIN COLON name= VAR (t= trail_with )?
            {
            root_0 = (Object)adaptor.nil();

            MARK56=(Token)match(input,MARK,FOLLOW_MARK_in_trail_mark1006); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            MARK56_tree = (Object)adaptor.create(MARK56);
            adaptor.addChild(root_0, MARK56_tree);
            }
            dm=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_trail_mark1010); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            dm_tree = (Object)adaptor.create(dm);
            adaptor.addChild(root_0, dm_tree);
            }
            COLON57=(Token)match(input,COLON,FOLLOW_COLON_in_trail_mark1012); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON57_tree = (Object)adaptor.create(COLON57);
            adaptor.addChild(root_0, COLON57_tree);
            }
            name=(Token)match(input,VAR,FOLLOW_VAR_in_trail_mark1016); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            // RuleSet.g:573:37: (t= trail_with )?
            int alt32=2;
            int LA32_0 = input.LA(1);

            if ( (LA32_0==WITH) ) {
                alt32=1;
            }
            switch (alt32) {
                case 1 :
                    // RuleSet.g:0:0: t= trail_with
                    {
                    pushFollow(FOLLOW_trail_with_in_trail_mark1020);
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
              //		if((t!=null?input.toString(t.start,t.stop):null) != null)
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
    // RuleSet.g:585:1: trail_with returns [Object result] : WITH e= expr ;
    public final RuleSetParser.trail_with_return trail_with() throws RecognitionException {
        RuleSetParser.trail_with_return retval = new RuleSetParser.trail_with_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITH58=null;
        RuleSetParser.expr_return e = null;


        Object WITH58_tree=null;

        try {
            // RuleSet.g:586:2: ( WITH e= expr )
            // RuleSet.g:587:2: WITH e= expr
            {
            root_0 = (Object)adaptor.nil();

            WITH58=(Token)match(input,WITH,FOLLOW_WITH_in_trail_with1039); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITH58_tree = (Object)adaptor.create(WITH58);
            adaptor.addChild(root_0, WITH58_tree);
            }
            pushFollow(FOLLOW_expr_in_trail_with1043);
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
    // RuleSet.g:592:1: counter_start returns [Object result] : must_be[\"from\"] e= expr ;
    public final RuleSetParser.counter_start_return counter_start() throws RecognitionException {
        RuleSetParser.counter_start_return retval = new RuleSetParser.counter_start_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.must_be_return must_be59 = null;



        try {
            // RuleSet.g:593:2: ( must_be[\"from\"] e= expr )
            // RuleSet.g:594:2: must_be[\"from\"] e= expr
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_counter_start1061);
            must_be59=must_be("from");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be59.getTree());
            pushFollow(FOLLOW_expr_in_counter_start1066);
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
    // RuleSet.g:600:1: for_clause returns [String result] : FOR v= VAR ;
    public final RuleSetParser.for_clause_return for_clause() throws RecognitionException {
        RuleSetParser.for_clause_return retval = new RuleSetParser.for_clause_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token FOR60=null;

        Object v_tree=null;
        Object FOR60_tree=null;

        try {
            // RuleSet.g:601:2: ( FOR v= VAR )
            // RuleSet.g:602:2: FOR v= VAR
            {
            root_0 = (Object)adaptor.nil();

            FOR60=(Token)match(input,FOR,FOLLOW_FOR_in_for_clause1087); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FOR60_tree = (Object)adaptor.create(FOR60);
            adaptor.addChild(root_0, FOR60_tree);
            }
            v=(Token)match(input,VAR,FOLLOW_VAR_in_for_clause1092); if (state.failed) return retval;
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
    // RuleSet.g:616:1: action[HashMap result] : ( conditional_action[result] | unconditional_action[result] ) ( SEMI )? ;
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
            // RuleSet.g:625:2: ( ( conditional_action[result] | unconditional_action[result] ) ( SEMI )? )
            // RuleSet.g:626:2: ( conditional_action[result] | unconditional_action[result] ) ( SEMI )?
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:626:2: ( conditional_action[result] | unconditional_action[result] )
            int alt33=2;
            int LA33_0 = input.LA(1);

            if ( (LA33_0==IF) ) {
                alt33=1;
            }
            else if ( (LA33_0==LEFT_CURL||LA33_0==VAR||(LA33_0>=OTHER_OPERATORS && LA33_0<=MATCH)||LA33_0==VAR_DOMAIN||(LA33_0>=EVERY && LA33_0<=CHOOSE)||LA33_0==EMIT) ) {
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
                    // RuleSet.g:626:3: conditional_action[result]
                    {
                    pushFollow(FOLLOW_conditional_action_in_action1126);
                    conditional_action61=conditional_action(result);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, conditional_action61.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:626:32: unconditional_action[result]
                    {
                    pushFollow(FOLLOW_unconditional_action_in_action1131);
                    unconditional_action62=unconditional_action(result);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, unconditional_action62.getTree());

                    }
                    break;

            }

            // RuleSet.g:626:62: ( SEMI )?
            int alt34=2;
            int LA34_0 = input.LA(1);

            if ( (LA34_0==SEMI) ) {
                int LA34_1 = input.LA(2);

                if ( (synpred47_RuleSet()) ) {
                    alt34=1;
                }
            }
            switch (alt34) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI63=(Token)match(input,SEMI,FOLLOW_SEMI_in_action1135); if (state.failed) return retval;
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
    // RuleSet.g:629:1: conditional_action[HashMap result] : IF e= expr must_be[\"then\"] unconditional_action[result] ;
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
            // RuleSet.g:630:2: ( IF e= expr must_be[\"then\"] unconditional_action[result] )
            // RuleSet.g:630:4: IF e= expr must_be[\"then\"] unconditional_action[result]
            {
            root_0 = (Object)adaptor.nil();

            IF64=(Token)match(input,IF,FOLLOW_IF_in_conditional_action1150); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            IF64_tree = (Object)adaptor.create(IF64);
            adaptor.addChild(root_0, IF64_tree);
            }
            pushFollow(FOLLOW_expr_in_conditional_action1154);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_must_be_in_conditional_action1156);
            must_be65=must_be("then");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be65.getTree());
            pushFollow(FOLLOW_unconditional_action_in_conditional_action1159);
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
    // RuleSet.g:645:1: unconditional_action[HashMap result] : (p= primrule | action_block[result] );
    public final RuleSetParser.unconditional_action_return unconditional_action(HashMap result) throws RecognitionException {
        RuleSetParser.unconditional_action_return retval = new RuleSetParser.unconditional_action_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.primrule_return p = null;

        RuleSetParser.action_block_return action_block67 = null;



         
        	ArrayList temp_list = new ArrayList(); 

        try {
            // RuleSet.g:649:2: (p= primrule | action_block[result] )
            int alt35=2;
            int LA35_0 = input.LA(1);

            if ( (LA35_0==VAR||(LA35_0>=OTHER_OPERATORS && LA35_0<=MATCH)||LA35_0==VAR_DOMAIN||LA35_0==EMIT) ) {
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
                    // RuleSet.g:649:4: p= primrule
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_primrule_in_unconditional_action1184);
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
                    // RuleSet.g:650:6: action_block[result]
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_action_block_in_unconditional_action1194);
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
    // RuleSet.g:652:1: action_block[HashMap result] : (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}' ;
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
            // RuleSet.g:656:2: ( (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}' )
            // RuleSet.g:656:4: (at= ( EVERY | CHOOSE ) )? '{' (p= primrule ( ';' p= primrule )* ) ( ';' )? '}'
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:656:6: (at= ( EVERY | CHOOSE ) )?
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
            char_literal68=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_action_block1231); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            char_literal68_tree = (Object)adaptor.create(char_literal68);
            adaptor.addChild(root_0, char_literal68_tree);
            }
            // RuleSet.g:657:7: (p= primrule ( ';' p= primrule )* )
            // RuleSet.g:657:8: p= primrule ( ';' p= primrule )*
            {
            pushFollow(FOLLOW_primrule_in_action_block1236);
            p=primrule();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, p.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add((p!=null?p.result:null));
            }
            // RuleSet.g:658:4: ( ';' p= primrule )*
            loop37:
            do {
                int alt37=2;
                int LA37_0 = input.LA(1);

                if ( (LA37_0==SEMI) ) {
                    int LA37_1 = input.LA(2);

                    if ( (LA37_1==VAR||(LA37_1>=OTHER_OPERATORS && LA37_1<=MATCH)||LA37_1==VAR_DOMAIN||LA37_1==EMIT) ) {
                        alt37=1;
                    }


                }


                switch (alt37) {
            	case 1 :
            	    // RuleSet.g:658:5: ';' p= primrule
            	    {
            	    char_literal69=(Token)match(input,SEMI,FOLLOW_SEMI_in_action_block1246); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    char_literal69_tree = (Object)adaptor.create(char_literal69);
            	    adaptor.addChild(root_0, char_literal69_tree);
            	    }
            	    pushFollow(FOLLOW_primrule_in_action_block1250);
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

            // RuleSet.g:658:51: ( ';' )?
            int alt38=2;
            int LA38_0 = input.LA(1);

            if ( (LA38_0==SEMI) ) {
                alt38=1;
            }
            switch (alt38) {
                case 1 :
                    // RuleSet.g:0:0: ';'
                    {
                    char_literal70=(Token)match(input,SEMI,FOLLOW_SEMI_in_action_block1257); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal70_tree = (Object)adaptor.create(char_literal70);
                    adaptor.addChild(root_0, char_literal70_tree);
                    }

                    }
                    break;

            }

            char_literal71=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_action_block1260); if (state.failed) return retval;
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
    // RuleSet.g:663:1: primrule returns [HashMap result] : (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (set= setting )? (m= modifier_clause )? | (label= VAR ARROW_RIGHT )? e= emit_block ) ;
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
        Token ARROW_RIGHT77=null;
        RuleSetParser.namespace_return src = null;

        RuleSetParser.expr_return ex = null;

        RuleSetParser.expr_return ex1 = null;

        RuleSetParser.setting_return set = null;

        RuleSetParser.modifier_clause_return m = null;

        RuleSetParser.emit_block_return e = null;


        Object label_tree=null;
        Object name_tree=null;
        Object ARROW_RIGHT72_tree=null;
        Object LEFT_PAREN73_tree=null;
        Object COMMA74_tree=null;
        Object COMMA75_tree=null;
        Object RIGHT_PAREN76_tree=null;
        Object ARROW_RIGHT77_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:667:2: ( (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (set= setting )? (m= modifier_clause )? | (label= VAR ARROW_RIGHT )? e= emit_block ) )
            // RuleSet.g:667:5: (label= VAR ARROW_RIGHT )? ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (set= setting )? (m= modifier_clause )? | (label= VAR ARROW_RIGHT )? e= emit_block )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:667:5: (label= VAR ARROW_RIGHT )?
            int alt39=2;
            int LA39_0 = input.LA(1);

            if ( (LA39_0==VAR) ) {
                int LA39_1 = input.LA(2);

                if ( (LA39_1==ARROW_RIGHT) ) {
                    int LA39_3 = input.LA(3);

                    if ( (synpred54_RuleSet()) ) {
                        alt39=1;
                    }
                }
            }
            switch (alt39) {
                case 1 :
                    // RuleSet.g:667:6: label= VAR ARROW_RIGHT
                    {
                    label=(Token)match(input,VAR,FOLLOW_VAR_in_primrule1287); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    label_tree = (Object)adaptor.create(label);
                    adaptor.addChild(root_0, label_tree);
                    }
                    ARROW_RIGHT72=(Token)match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_primrule1289); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    ARROW_RIGHT72_tree = (Object)adaptor.create(ARROW_RIGHT72);
                    adaptor.addChild(root_0, ARROW_RIGHT72_tree);
                    }

                    }
                    break;

            }

            // RuleSet.g:667:30: ( (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (set= setting )? (m= modifier_clause )? | (label= VAR ARROW_RIGHT )? e= emit_block )
            int alt47=2;
            switch ( input.LA(1) ) {
            case VAR:
                {
                int LA47_1 = input.LA(2);

                if ( (LA47_1==COLON||LA47_1==LEFT_PAREN) ) {
                    alt47=1;
                }
                else if ( (LA47_1==ARROW_RIGHT) ) {
                    alt47=2;
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return retval;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 47, 1, input);

                    throw nvae;
                }
                }
                break;
            case OTHER_OPERATORS:
            case LIKE:
            case REPLACE:
            case MATCH:
            case VAR_DOMAIN:
                {
                alt47=1;
                }
                break;
            case EMIT:
                {
                alt47=2;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 47, 0, input);

                throw nvae;
            }

            switch (alt47) {
                case 1 :
                    // RuleSet.g:668:4: (src= namespace )? name= ( VAR | REPLACE | MATCH | OTHER_OPERATORS ) LEFT_PAREN (ex= expr ( COMMA ex1= expr )* )? ( COMMA )? RIGHT_PAREN (set= setting )? (m= modifier_clause )?
                    {
                    // RuleSet.g:668:7: (src= namespace )?
                    int alt40=2;
                    int LA40_0 = input.LA(1);

                    if ( (LA40_0==VAR||LA40_0==OTHER_OPERATORS||(LA40_0>=REPLACE && LA40_0<=MATCH)) ) {
                        int LA40_1 = input.LA(2);

                        if ( (LA40_1==COLON) ) {
                            alt40=1;
                        }
                    }
                    else if ( (LA40_0==LIKE||LA40_0==VAR_DOMAIN) ) {
                        alt40=1;
                    }
                    switch (alt40) {
                        case 1 :
                            // RuleSet.g:0:0: src= namespace
                            {
                            pushFollow(FOLLOW_namespace_in_primrule1300);
                            src=namespace();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, src.getTree());

                            }
                            break;

                    }

                    name=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||input.LA(1)==OTHER_OPERATORS||(input.LA(1)>=REPLACE && input.LA(1)<=MATCH) ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(name));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    LEFT_PAREN73=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_primrule1316); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN73_tree = (Object)adaptor.create(LEFT_PAREN73);
                    adaptor.addChild(root_0, LEFT_PAREN73_tree);
                    }
                    // RuleSet.g:668:72: (ex= expr ( COMMA ex1= expr )* )?
                    int alt42=2;
                    int LA42_0 = input.LA(1);

                    if ( (LA42_0==LEFT_CURL||(LA42_0>=VAR && LA42_0<=MATCH)||(LA42_0>=STRING && LA42_0<=VAR_DOMAIN)||LA42_0==LEFT_PAREN||LA42_0==NOT||LA42_0==FUNCTION||(LA42_0>=REX && LA42_0<=SEEN)||(LA42_0>=FLOAT && LA42_0<=LEFT_BRACKET)||(LA42_0>=CURRENT && LA42_0<=HISTORY)) ) {
                        alt42=1;
                    }
                    switch (alt42) {
                        case 1 :
                            // RuleSet.g:668:73: ex= expr ( COMMA ex1= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_primrule1321);
                            ex=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, ex.getTree());
                            if ( state.backtracking==0 ) {
                              temp_list.add((ex!=null?ex.result:null));
                            }
                            // RuleSet.g:668:110: ( COMMA ex1= expr )*
                            loop41:
                            do {
                                int alt41=2;
                                int LA41_0 = input.LA(1);

                                if ( (LA41_0==COMMA) ) {
                                    int LA41_1 = input.LA(2);

                                    if ( (LA41_1==LEFT_CURL||(LA41_1>=VAR && LA41_1<=MATCH)||(LA41_1>=STRING && LA41_1<=VAR_DOMAIN)||LA41_1==LEFT_PAREN||LA41_1==NOT||LA41_1==FUNCTION||(LA41_1>=REX && LA41_1<=SEEN)||(LA41_1>=FLOAT && LA41_1<=LEFT_BRACKET)||(LA41_1>=CURRENT && LA41_1<=HISTORY)) ) {
                                        alt41=1;
                                    }


                                }


                                switch (alt41) {
                            	case 1 :
                            	    // RuleSet.g:668:111: COMMA ex1= expr
                            	    {
                            	    COMMA74=(Token)match(input,COMMA,FOLLOW_COMMA_in_primrule1326); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA74_tree = (Object)adaptor.create(COMMA74);
                            	    adaptor.addChild(root_0, COMMA74_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_primrule1330);
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

                    // RuleSet.g:668:160: ( COMMA )?
                    int alt43=2;
                    int LA43_0 = input.LA(1);

                    if ( (LA43_0==COMMA) ) {
                        alt43=1;
                    }
                    switch (alt43) {
                        case 1 :
                            // RuleSet.g:0:0: COMMA
                            {
                            COMMA75=(Token)match(input,COMMA,FOLLOW_COMMA_in_primrule1338); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            COMMA75_tree = (Object)adaptor.create(COMMA75);
                            adaptor.addChild(root_0, COMMA75_tree);
                            }

                            }
                            break;

                    }

                    RIGHT_PAREN76=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_primrule1342); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN76_tree = (Object)adaptor.create(RIGHT_PAREN76);
                    adaptor.addChild(root_0, RIGHT_PAREN76_tree);
                    }
                    // RuleSet.g:668:184: (set= setting )?
                    int alt44=2;
                    int LA44_0 = input.LA(1);

                    if ( (LA44_0==SETTING) ) {
                        alt44=1;
                    }
                    switch (alt44) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_primrule1347);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    // RuleSet.g:668:195: (m= modifier_clause )?
                    int alt45=2;
                    int LA45_0 = input.LA(1);

                    if ( (LA45_0==WITH) ) {
                        alt45=1;
                    }
                    switch (alt45) {
                        case 1 :
                            // RuleSet.g:0:0: m= modifier_clause
                            {
                            pushFollow(FOLLOW_modifier_clause_in_primrule1352);
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
                      		  
                      		 	
                      //		 	if((label!=null?label.getText():null) != null)
                      //			 	tmp.put("label",(label!=null?label.getText():null));


                      //            if((set!=null?input.toString(set.start,set.stop):null) != null)
                      				tmp.put("vars",(set!=null?set.result:null));
                      			 	
                      		 	tmp.put("modifiers",(m!=null?m.result:null));
                      		 	HashMap tmp2 = new HashMap();
                      			tmp2.put("action",tmp);

                      //			if((label!=null?label.getText():null) != null)
                      				tmp2.put("label",(label!=null?label.getText():null));
                      			retval.result = tmp2;
                      		 	
                      		 
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:692:4: (label= VAR ARROW_RIGHT )? e= emit_block
                    {
                    // RuleSet.g:692:4: (label= VAR ARROW_RIGHT )?
                    int alt46=2;
                    int LA46_0 = input.LA(1);

                    if ( (LA46_0==VAR) ) {
                        alt46=1;
                    }
                    switch (alt46) {
                        case 1 :
                            // RuleSet.g:692:5: label= VAR ARROW_RIGHT
                            {
                            label=(Token)match(input,VAR,FOLLOW_VAR_in_primrule1363); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            label_tree = (Object)adaptor.create(label);
                            adaptor.addChild(root_0, label_tree);
                            }
                            ARROW_RIGHT77=(Token)match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_primrule1365); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            ARROW_RIGHT77_tree = (Object)adaptor.create(ARROW_RIGHT77);
                            adaptor.addChild(root_0, ARROW_RIGHT77_tree);
                            }

                            }
                            break;

                    }

                    pushFollow(FOLLOW_emit_block_in_primrule1371);
                    e=emit_block();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    if ( state.backtracking==0 ) {

                      			HashMap tmp = new HashMap();
                      			tmp.put("emit",(e!=null?e.emit_value:null));

                      //		 	if((label!=null?label.getText():null) != null)
                      			 	tmp.put("label",(label!=null?label.getText():null));


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
    // RuleSet.g:706:1: modifier_clause returns [ArrayList result] : WITH m= modifier ( AND_AND m1= modifier )* ;
    public final RuleSetParser.modifier_clause_return modifier_clause() throws RecognitionException {
        RuleSetParser.modifier_clause_return retval = new RuleSetParser.modifier_clause_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITH78=null;
        Token AND_AND79=null;
        RuleSetParser.modifier_return m = null;

        RuleSetParser.modifier_return m1 = null;


        Object WITH78_tree=null;
        Object AND_AND79_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:710:2: ( WITH m= modifier ( AND_AND m1= modifier )* )
            // RuleSet.g:711:2: WITH m= modifier ( AND_AND m1= modifier )*
            {
            root_0 = (Object)adaptor.nil();

            WITH78=(Token)match(input,WITH,FOLLOW_WITH_in_modifier_clause1403); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITH78_tree = (Object)adaptor.create(WITH78);
            adaptor.addChild(root_0, WITH78_tree);
            }
            pushFollow(FOLLOW_modifier_in_modifier_clause1407);
            m=modifier();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, m.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add((m!=null?m.result:null));
            }
            // RuleSet.g:711:46: ( AND_AND m1= modifier )*
            loop48:
            do {
                int alt48=2;
                int LA48_0 = input.LA(1);

                if ( (LA48_0==AND_AND) ) {
                    alt48=1;
                }


                switch (alt48) {
            	case 1 :
            	    // RuleSet.g:711:47: AND_AND m1= modifier
            	    {
            	    AND_AND79=(Token)match(input,AND_AND,FOLLOW_AND_AND_in_modifier_clause1412); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AND_AND79_tree = (Object)adaptor.create(AND_AND79);
            	    adaptor.addChild(root_0, AND_AND79_tree);
            	    }
            	    pushFollow(FOLLOW_modifier_in_modifier_clause1416);
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
            	    break loop48;
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
    // RuleSet.g:717:1: modifier returns [HashMap result] : name= VAR EQUAL (e= expr | j= JS ) ;
    public final RuleSetParser.modifier_return modifier() throws RecognitionException {
        RuleSetParser.modifier_return retval = new RuleSetParser.modifier_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token name=null;
        Token j=null;
        Token EQUAL80=null;
        RuleSetParser.expr_return e = null;


        Object name_tree=null;
        Object j_tree=null;
        Object EQUAL80_tree=null;

        try {
            // RuleSet.g:718:2: (name= VAR EQUAL (e= expr | j= JS ) )
            // RuleSet.g:718:4: name= VAR EQUAL (e= expr | j= JS )
            {
            root_0 = (Object)adaptor.nil();

            name=(Token)match(input,VAR,FOLLOW_VAR_in_modifier1441); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            name_tree = (Object)adaptor.create(name);
            adaptor.addChild(root_0, name_tree);
            }
            EQUAL80=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_modifier1443); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL80_tree = (Object)adaptor.create(EQUAL80);
            adaptor.addChild(root_0, EQUAL80_tree);
            }
            // RuleSet.g:718:18: (e= expr | j= JS )
            int alt49=2;
            int LA49_0 = input.LA(1);

            if ( (LA49_0==LEFT_CURL||(LA49_0>=VAR && LA49_0<=MATCH)||(LA49_0>=STRING && LA49_0<=VAR_DOMAIN)||LA49_0==LEFT_PAREN||LA49_0==NOT||LA49_0==FUNCTION||(LA49_0>=REX && LA49_0<=SEEN)||(LA49_0>=FLOAT && LA49_0<=LEFT_BRACKET)||(LA49_0>=CURRENT && LA49_0<=HISTORY)) ) {
                alt49=1;
            }
            else if ( (LA49_0==JS) ) {
                alt49=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 49, 0, input);

                throw nvae;
            }
            switch (alt49) {
                case 1 :
                    // RuleSet.g:718:19: e= expr
                    {
                    pushFollow(FOLLOW_expr_in_modifier1447);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());

                    }
                    break;
                case 2 :
                    // RuleSet.g:718:28: j= JS
                    {
                    j=(Token)match(input,JS,FOLLOW_JS_in_modifier1453); if (state.failed) return retval;
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
    // RuleSet.g:744:1: using returns [HashMap result] : USING (p= STRING | r= regex ) (s= setting )? ;
    public final RuleSetParser.using_return using() throws RecognitionException {
        RuleSetParser.using_return retval = new RuleSetParser.using_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token p=null;
        Token USING81=null;
        RuleSetParser.regex_return r = null;

        RuleSetParser.setting_return s = null;


        Object p_tree=null;
        Object USING81_tree=null;

        try {
            // RuleSet.g:745:2: ( USING (p= STRING | r= regex ) (s= setting )? )
            // RuleSet.g:745:4: USING (p= STRING | r= regex ) (s= setting )?
            {
            root_0 = (Object)adaptor.nil();

            USING81=(Token)match(input,USING,FOLLOW_USING_in_using1477); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            USING81_tree = (Object)adaptor.create(USING81);
            adaptor.addChild(root_0, USING81_tree);
            }
            // RuleSet.g:745:10: (p= STRING | r= regex )
            int alt50=2;
            int LA50_0 = input.LA(1);

            if ( (LA50_0==STRING) ) {
                alt50=1;
            }
            else if ( (LA50_0==REX) ) {
                alt50=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 50, 0, input);

                throw nvae;
            }
            switch (alt50) {
                case 1 :
                    // RuleSet.g:745:11: p= STRING
                    {
                    p=(Token)match(input,STRING,FOLLOW_STRING_in_using1482); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    p_tree = (Object)adaptor.create(p);
                    adaptor.addChild(root_0, p_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:745:20: r= regex
                    {
                    pushFollow(FOLLOW_regex_in_using1486);
                    r=regex();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, r.getTree());

                    }
                    break;

            }

            // RuleSet.g:745:30: (s= setting )?
            int alt51=2;
            int LA51_0 = input.LA(1);

            if ( (LA51_0==SETTING) ) {
                alt51=1;
            }
            switch (alt51) {
                case 1 :
                    // RuleSet.g:0:0: s= setting
                    {
                    pushFollow(FOLLOW_setting_in_using1491);
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
              			
              //			if((s!=null?input.toString(s.start,s.stop):null) != null)
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
    // RuleSet.g:765:1: setting returns [ArrayList result] : SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH ) ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN ;
    public final RuleSetParser.setting_return setting() throws RecognitionException {
        RuleSetParser.setting_return retval = new RuleSetParser.setting_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token v2=null;
        Token SETTING82=null;
        Token LEFT_PAREN83=null;
        Token COMMA84=null;
        Token RIGHT_PAREN85=null;

        Object v_tree=null;
        Object v2_tree=null;
        Object SETTING82_tree=null;
        Object LEFT_PAREN83_tree=null;
        Object COMMA84_tree=null;
        Object RIGHT_PAREN85_tree=null;


        	ArrayList sresult = new ArrayList();

        try {
            // RuleSet.g:769:2: ( SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH ) ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN )
            // RuleSet.g:769:4: SETTING LEFT_PAREN (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH ) ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )* )? RIGHT_PAREN
            {
            root_0 = (Object)adaptor.nil();

            SETTING82=(Token)match(input,SETTING,FOLLOW_SETTING_in_setting1512); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            SETTING82_tree = (Object)adaptor.create(SETTING82);
            adaptor.addChild(root_0, SETTING82_tree);
            }
            LEFT_PAREN83=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_setting1514); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_PAREN83_tree = (Object)adaptor.create(LEFT_PAREN83);
            adaptor.addChild(root_0, LEFT_PAREN83_tree);
            }
            // RuleSet.g:769:23: (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH ) ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )* )?
            int alt53=2;
            int LA53_0 = input.LA(1);

            if ( (LA53_0==VAR||(LA53_0>=OTHER_OPERATORS && LA53_0<=MATCH)) ) {
                alt53=1;
            }
            switch (alt53) {
                case 1 :
                    // RuleSet.g:769:24: v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH ) ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )*
                    {
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH) ) {
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
                    // RuleSet.g:769:90: ( COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH ) )*
                    loop52:
                    do {
                        int alt52=2;
                        int LA52_0 = input.LA(1);

                        if ( (LA52_0==COMMA) ) {
                            alt52=1;
                        }


                        switch (alt52) {
                    	case 1 :
                    	    // RuleSet.g:769:91: COMMA v2= ( VAR | LIKE | OTHER_OPERATORS | REPLACE | MATCH )
                    	    {
                    	    COMMA84=(Token)match(input,COMMA,FOLLOW_COMMA_in_setting1533); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    COMMA84_tree = (Object)adaptor.create(COMMA84);
                    	    adaptor.addChild(root_0, COMMA84_tree);
                    	    }
                    	    v2=(Token)input.LT(1);
                    	    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH) ) {
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
                    	    break loop52;
                        }
                    } while (true);


                    }
                    break;

            }

            RIGHT_PAREN85=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_setting1555); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_PAREN85_tree = (Object)adaptor.create(RIGHT_PAREN85);
            adaptor.addChild(root_0, RIGHT_PAREN85_tree);
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
    // RuleSet.g:775:1: pre_block returns [ArrayList result] : PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL ;
    public final RuleSetParser.pre_block_return pre_block() throws RecognitionException {
        RuleSetParser.pre_block_return retval = new RuleSetParser.pre_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token PRE86=null;
        Token LEFT_CURL87=null;
        Token SEMI89=null;
        Token SEMI91=null;
        Token RIGHT_CURL92=null;
        RuleSetParser.decl_return decl88 = null;

        RuleSetParser.decl_return decl90 = null;


        Object PRE86_tree=null;
        Object LEFT_CURL87_tree=null;
        Object SEMI89_tree=null;
        Object SEMI91_tree=null;
        Object RIGHT_CURL92_tree=null;


        	ArrayList tmp = new ArrayList();

        try {
            // RuleSet.g:778:3: ( PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL )
            // RuleSet.g:779:3: PRE LEFT_CURL ( decl[tmp] ( SEMI decl[tmp] )* )? ( SEMI )? RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            PRE86=(Token)match(input,PRE,FOLLOW_PRE_in_pre_block1580); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            PRE86_tree = (Object)adaptor.create(PRE86);
            adaptor.addChild(root_0, PRE86_tree);
            }
            LEFT_CURL87=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_pre_block1582); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL87_tree = (Object)adaptor.create(LEFT_CURL87);
            adaptor.addChild(root_0, LEFT_CURL87_tree);
            }
            // RuleSet.g:779:17: ( decl[tmp] ( SEMI decl[tmp] )* )?
            int alt55=2;
            int LA55_0 = input.LA(1);

            if ( (LA55_0==VAR||(LA55_0>=OTHER_OPERATORS && LA55_0<=MATCH)||LA55_0==VAR_DOMAIN) ) {
                alt55=1;
            }
            switch (alt55) {
                case 1 :
                    // RuleSet.g:779:19: decl[tmp] ( SEMI decl[tmp] )*
                    {
                    pushFollow(FOLLOW_decl_in_pre_block1586);
                    decl88=decl(tmp);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl88.getTree());
                    // RuleSet.g:779:29: ( SEMI decl[tmp] )*
                    loop54:
                    do {
                        int alt54=2;
                        int LA54_0 = input.LA(1);

                        if ( (LA54_0==SEMI) ) {
                            int LA54_1 = input.LA(2);

                            if ( (LA54_1==VAR||(LA54_1>=OTHER_OPERATORS && LA54_1<=MATCH)||LA54_1==VAR_DOMAIN) ) {
                                alt54=1;
                            }


                        }


                        switch (alt54) {
                    	case 1 :
                    	    // RuleSet.g:779:30: SEMI decl[tmp]
                    	    {
                    	    SEMI89=(Token)match(input,SEMI,FOLLOW_SEMI_in_pre_block1590); if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) {
                    	    SEMI89_tree = (Object)adaptor.create(SEMI89);
                    	    adaptor.addChild(root_0, SEMI89_tree);
                    	    }
                    	    pushFollow(FOLLOW_decl_in_pre_block1592);
                    	    decl90=decl(tmp);

                    	    state._fsp--;
                    	    if (state.failed) return retval;
                    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl90.getTree());

                    	    }
                    	    break;

                    	default :
                    	    break loop54;
                        }
                    } while (true);


                    }
                    break;

            }

            // RuleSet.g:779:50: ( SEMI )?
            int alt56=2;
            int LA56_0 = input.LA(1);

            if ( (LA56_0==SEMI) ) {
                alt56=1;
            }
            switch (alt56) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI91=(Token)match(input,SEMI,FOLLOW_SEMI_in_pre_block1600); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI91_tree = (Object)adaptor.create(SEMI91);
                    adaptor.addChild(root_0, SEMI91_tree);
                    }

                    }
                    break;

            }

            RIGHT_CURL92=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_pre_block1603); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL92_tree = (Object)adaptor.create(RIGHT_CURL92);
            adaptor.addChild(root_0, RIGHT_CURL92_tree);
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
    // RuleSet.g:784:1: foreach returns [HashMap result] : FOREACH e= expr s= setting ;
    public final RuleSetParser.foreach_return foreach() throws RecognitionException {
        RuleSetParser.foreach_return retval = new RuleSetParser.foreach_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token FOREACH93=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.setting_return s = null;


        Object FOREACH93_tree=null;

        try {
            // RuleSet.g:785:2: ( FOREACH e= expr s= setting )
            // RuleSet.g:786:2: FOREACH e= expr s= setting
            {
            root_0 = (Object)adaptor.nil();

            FOREACH93=(Token)match(input,FOREACH,FOLLOW_FOREACH_in_foreach1624); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FOREACH93_tree = (Object)adaptor.create(FOREACH93);
            adaptor.addChild(root_0, FOREACH93_tree);
            }
            pushFollow(FOLLOW_expr_in_foreach1628);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_setting_in_foreach1632);
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
    // RuleSet.g:793:1: when returns [HashMap result] : WHEN es= event_seq ;
    public final RuleSetParser.when_return when() throws RecognitionException {
        RuleSetParser.when_return retval = new RuleSetParser.when_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WHEN94=null;
        RuleSetParser.event_seq_return es = null;


        Object WHEN94_tree=null;



        try {
            // RuleSet.g:796:2: ( WHEN es= event_seq )
            // RuleSet.g:797:2: WHEN es= event_seq
            {
            root_0 = (Object)adaptor.nil();

            WHEN94=(Token)match(input,WHEN,FOLLOW_WHEN_in_when1665); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WHEN94_tree = (Object)adaptor.create(WHEN94);
            adaptor.addChild(root_0, WHEN94_tree);
            }
            pushFollow(FOLLOW_event_seq_in_when1669);
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
    // RuleSet.g:806:1: event_seq returns [HashMap result] : eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )* ;
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
            // RuleSet.g:811:2: (eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )* )
            // RuleSet.g:812:3: eor= event_or (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_or_in_event_seq1696);
            eor=event_or();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, eor.getTree());
            // RuleSet.g:812:16: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*
            loop57:
            do {
                int alt57=2;
                alt57 = dfa57.predict(input);
                switch (alt57) {
            	case 1 :
            	    // RuleSet.g:812:17: tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_event_seq1701);
            	    tb=must_be_one(sar("then","before"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, tb.getTree());
            	    pushFollow(FOLLOW_event_or_in_event_seq1706);
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
            	    break loop57;
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
    // RuleSet.g:857:1: event_or returns [HashMap result] : ea= event_and ( OR_OR ea1= event_and )* ;
    public final RuleSetParser.event_or_return event_or() throws RecognitionException {
        RuleSetParser.event_or_return retval = new RuleSetParser.event_or_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token OR_OR95=null;
        RuleSetParser.event_and_return ea = null;

        RuleSetParser.event_and_return ea1 = null;


        Object OR_OR95_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:861:2: (ea= event_and ( OR_OR ea1= event_and )* )
            // RuleSet.g:862:3: ea= event_and ( OR_OR ea1= event_and )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_and_in_event_or1747);
            ea=event_and();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ea.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add(ea);
            }
            // RuleSet.g:862:37: ( OR_OR ea1= event_and )*
            loop58:
            do {
                int alt58=2;
                int LA58_0 = input.LA(1);

                if ( (LA58_0==OR_OR) ) {
                    alt58=1;
                }


                switch (alt58) {
            	case 1 :
            	    // RuleSet.g:862:38: OR_OR ea1= event_and
            	    {
            	    OR_OR95=(Token)match(input,OR_OR,FOLLOW_OR_OR_in_event_or1752); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    OR_OR95_tree = (Object)adaptor.create(OR_OR95);
            	    adaptor.addChild(root_0, OR_OR95_tree);
            	    }
            	    pushFollow(FOLLOW_event_and_in_event_or1756);
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
            	    break loop58;
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
    // RuleSet.g:902:1: event_and returns [HashMap result] : e= event_btwn ( AND_AND e1= event_btwn )* ;
    public final RuleSetParser.event_and_return event_and() throws RecognitionException {
        RuleSetParser.event_and_return retval = new RuleSetParser.event_and_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token AND_AND96=null;
        RuleSetParser.event_btwn_return e = null;

        RuleSetParser.event_btwn_return e1 = null;


        Object AND_AND96_tree=null;


        	ArrayList temp_list = new ArrayList();

        try {
            // RuleSet.g:906:2: (e= event_btwn ( AND_AND e1= event_btwn )* )
            // RuleSet.g:907:3: e= event_btwn ( AND_AND e1= event_btwn )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_btwn_in_event_and1785);
            e=event_btwn();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            if ( state.backtracking==0 ) {
              temp_list.add(e);
            }
            // RuleSet.g:907:36: ( AND_AND e1= event_btwn )*
            loop59:
            do {
                int alt59=2;
                int LA59_0 = input.LA(1);

                if ( (LA59_0==AND_AND) ) {
                    alt59=1;
                }


                switch (alt59) {
            	case 1 :
            	    // RuleSet.g:907:37: AND_AND e1= event_btwn
            	    {
            	    AND_AND96=(Token)match(input,AND_AND,FOLLOW_AND_AND_in_event_and1790); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AND_AND96_tree = (Object)adaptor.create(AND_AND96);
            	    adaptor.addChild(root_0, AND_AND96_tree);
            	    }
            	    pushFollow(FOLLOW_event_btwn_in_event_and1794);
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
            	    break loop59;
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
    // RuleSet.g:948:1: event_btwn returns [HashMap result] : ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )? ;
    public final RuleSetParser.event_btwn_return event_btwn() throws RecognitionException {
        RuleSetParser.event_btwn_return retval = new RuleSetParser.event_btwn_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token not=null;
        Token BETWEEN97=null;
        Token LEFT_PAREN98=null;
        Token COMMA99=null;
        Token RIGHT_PAREN100=null;
        RuleSetParser.event_prim_return ep = null;

        RuleSetParser.event_seq_return es1 = null;

        RuleSetParser.event_seq_return es2 = null;


        Object not_tree=null;
        Object BETWEEN97_tree=null;
        Object LEFT_PAREN98_tree=null;
        Object COMMA99_tree=null;
        Object RIGHT_PAREN100_tree=null;

        try {
            // RuleSet.g:949:2: (ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )? )
            // RuleSet.g:950:3: ep= event_prim ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_event_prim_in_event_btwn1820);
            ep=event_prim();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, ep.getTree());
            // RuleSet.g:950:17: ( (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN )?
            int alt61=2;
            int LA61_0 = input.LA(1);

            if ( ((LA61_0>=NOT && LA61_0<=BETWEEN)) ) {
                alt61=1;
            }
            switch (alt61) {
                case 1 :
                    // RuleSet.g:950:18: (not= NOT )? BETWEEN LEFT_PAREN es1= event_seq COMMA es2= event_seq RIGHT_PAREN
                    {
                    // RuleSet.g:950:18: (not= NOT )?
                    int alt60=2;
                    int LA60_0 = input.LA(1);

                    if ( (LA60_0==NOT) ) {
                        alt60=1;
                    }
                    switch (alt60) {
                        case 1 :
                            // RuleSet.g:950:19: not= NOT
                            {
                            not=(Token)match(input,NOT,FOLLOW_NOT_in_event_btwn1826); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            not_tree = (Object)adaptor.create(not);
                            adaptor.addChild(root_0, not_tree);
                            }

                            }
                            break;

                    }

                    BETWEEN97=(Token)match(input,BETWEEN,FOLLOW_BETWEEN_in_event_btwn1831); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    BETWEEN97_tree = (Object)adaptor.create(BETWEEN97);
                    adaptor.addChild(root_0, BETWEEN97_tree);
                    }
                    LEFT_PAREN98=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_event_btwn1833); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN98_tree = (Object)adaptor.create(LEFT_PAREN98);
                    adaptor.addChild(root_0, LEFT_PAREN98_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_btwn1837);
                    es1=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, es1.getTree());
                    COMMA99=(Token)match(input,COMMA,FOLLOW_COMMA_in_event_btwn1839); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COMMA99_tree = (Object)adaptor.create(COMMA99);
                    adaptor.addChild(root_0, COMMA99_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_btwn1843);
                    es2=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, es2.getTree());
                    RIGHT_PAREN100=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_event_btwn1845); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN100_tree = (Object)adaptor.create(RIGHT_PAREN100);
                    adaptor.addChild(root_0, RIGHT_PAREN100_tree);
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
    // RuleSet.g:974:1: event_prim returns [HashMap result] : ( ( custom_event )=>ce= custom_event | (web= WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )? | (web= WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )? | '(' evt= event_seq ')' );
    public final RuleSetParser.event_prim_return event_prim() throws RecognitionException {
        RuleSetParser.event_prim_return retval = new RuleSetParser.event_prim_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token web=null;
        Token spat=null;
        Token elem=null;
        Token PAGEVIEW101=null;
        Token char_literal102=null;
        Token char_literal103=null;
        RuleSetParser.custom_event_return ce = null;

        RuleSetParser.regex_return rpat = null;

        RuleSetParser.setting_return set = null;

        RuleSetParser.must_be_one_return opt = null;

        RuleSetParser.on_expr_return on = null;

        RuleSetParser.event_seq_return evt = null;


        Object web_tree=null;
        Object spat_tree=null;
        Object elem_tree=null;
        Object PAGEVIEW101_tree=null;
        Object char_literal102_tree=null;
        Object char_literal103_tree=null;


        	ArrayList filters = new ArrayList();

        try {
            // RuleSet.g:978:2: ( ( custom_event )=>ce= custom_event | (web= WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )? | (web= WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )? | '(' evt= event_seq ')' )
            int alt68=4;
            alt68 = dfa68.predict(input);
            switch (alt68) {
                case 1 :
                    // RuleSet.g:979:2: ( custom_event )=>ce= custom_event
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_custom_event_in_event_prim1878);
                    ce=custom_event();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, ce.getTree());
                    if ( state.backtracking==0 ) {

                      	 retval.result = ce.result;
                      	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:982:4: (web= WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )?
                    {
                    root_0 = (Object)adaptor.nil();

                    // RuleSet.g:982:7: (web= WEB )?
                    int alt62=2;
                    int LA62_0 = input.LA(1);

                    if ( (LA62_0==WEB) ) {
                        alt62=1;
                    }
                    switch (alt62) {
                        case 1 :
                            // RuleSet.g:0:0: web= WEB
                            {
                            web=(Token)match(input,WEB,FOLLOW_WEB_in_event_prim1887); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            web_tree = (Object)adaptor.create(web);
                            adaptor.addChild(root_0, web_tree);
                            }

                            }
                            break;

                    }

                    PAGEVIEW101=(Token)match(input,PAGEVIEW,FOLLOW_PAGEVIEW_in_event_prim1890); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    PAGEVIEW101_tree = (Object)adaptor.create(PAGEVIEW101);
                    adaptor.addChild(root_0, PAGEVIEW101_tree);
                    }
                    // RuleSet.g:982:22: (spat= STRING | rpat= regex )
                    int alt63=2;
                    int LA63_0 = input.LA(1);

                    if ( (LA63_0==STRING) ) {
                        alt63=1;
                    }
                    else if ( (LA63_0==REX) ) {
                        alt63=2;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        NoViableAltException nvae =
                            new NoViableAltException("", 63, 0, input);

                        throw nvae;
                    }
                    switch (alt63) {
                        case 1 :
                            // RuleSet.g:982:23: spat= STRING
                            {
                            spat=(Token)match(input,STRING,FOLLOW_STRING_in_event_prim1895); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            spat_tree = (Object)adaptor.create(spat);
                            adaptor.addChild(root_0, spat_tree);
                            }

                            }
                            break;
                        case 2 :
                            // RuleSet.g:982:35: rpat= regex
                            {
                            pushFollow(FOLLOW_regex_in_event_prim1899);
                            rpat=regex();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, rpat.getTree());

                            }
                            break;

                    }

                    // RuleSet.g:982:50: (set= setting )?
                    int alt64=2;
                    int LA64_0 = input.LA(1);

                    if ( (LA64_0==SETTING) ) {
                        alt64=1;
                    }
                    switch (alt64) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_event_prim1904);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		HashMap tmp = new HashMap();
                      		tmp.put("domain",(web!=null?web.getText():null));
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
                case 3 :
                    // RuleSet.g:994:4: (web= WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )?
                    {
                    root_0 = (Object)adaptor.nil();

                    // RuleSet.g:994:7: (web= WEB )?
                    int alt65=2;
                    int LA65_0 = input.LA(1);

                    if ( (LA65_0==WEB) ) {
                        alt65=1;
                    }
                    switch (alt65) {
                        case 1 :
                            // RuleSet.g:0:0: web= WEB
                            {
                            web=(Token)match(input,WEB,FOLLOW_WEB_in_event_prim1915); if (state.failed) return retval;
                            if ( state.backtracking==0 ) {
                            web_tree = (Object)adaptor.create(web);
                            adaptor.addChild(root_0, web_tree);
                            }

                            }
                            break;

                    }

                    pushFollow(FOLLOW_must_be_one_in_event_prim1920);
                    opt=must_be_one(sar("submit","click","dblclick","change","update"));

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, opt.getTree());
                    elem=(Token)match(input,STRING,FOLLOW_STRING_in_event_prim1925); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    elem_tree = (Object)adaptor.create(elem);
                    adaptor.addChild(root_0, elem_tree);
                    }
                    // RuleSet.g:994:95: (on= on_expr )?
                    int alt66=2;
                    int LA66_0 = input.LA(1);

                    if ( (LA66_0==ON) ) {
                        alt66=1;
                    }
                    switch (alt66) {
                        case 1 :
                            // RuleSet.g:0:0: on= on_expr
                            {
                            pushFollow(FOLLOW_on_expr_in_event_prim1929);
                            on=on_expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, on.getTree());

                            }
                            break;

                    }

                    // RuleSet.g:994:109: (set= setting )?
                    int alt67=2;
                    int LA67_0 = input.LA(1);

                    if ( (LA67_0==SETTING) ) {
                        alt67=1;
                    }
                    switch (alt67) {
                        case 1 :
                            // RuleSet.g:0:0: set= setting
                            {
                            pushFollow(FOLLOW_setting_in_event_prim1935);
                            set=setting();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, set.getTree());

                            }
                            break;

                    }

                    if ( state.backtracking==0 ) {

                      		HashMap tmp = new HashMap();

                      		tmp.put("domain",(web!=null?web.getText():null));
                      		tmp.put("element",strip_string((elem!=null?elem.getText():null)));
                      		tmp.put("type","prim_event"); 
                      		tmp.put("vars",(set!=null?set.result:null));
                      		tmp.put("op",(opt!=null?input.toString(opt.start,opt.stop):null));
                      		tmp.put("on",(on!=null?on.result:null));
                      		retval.result = tmp;			
                      	
                      	
                    }

                    }
                    break;
                case 4 :
                    // RuleSet.g:1006:4: '(' evt= event_seq ')'
                    {
                    root_0 = (Object)adaptor.nil();

                    char_literal102=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_event_prim1943); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal102_tree = (Object)adaptor.create(char_literal102);
                    adaptor.addChild(root_0, char_literal102_tree);
                    }
                    pushFollow(FOLLOW_event_seq_in_event_prim1947);
                    evt=event_seq();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, evt.getTree());
                    char_literal103=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_event_prim1949); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal103_tree = (Object)adaptor.create(char_literal103);
                    adaptor.addChild(root_0, char_literal103_tree);
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

    public static class custom_event_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "custom_event"
    // RuleSet.g:1012:1: custom_event returns [HashMap result] : dom= ( VAR | WEB ) oper= VAR (filter= event_filter )* (set= setting )? ;
    public final RuleSetParser.custom_event_return custom_event() throws RecognitionException {
        RuleSetParser.custom_event_return retval = new RuleSetParser.custom_event_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token dom=null;
        Token oper=null;
        RuleSetParser.event_filter_return filter = null;

        RuleSetParser.setting_return set = null;


        Object dom_tree=null;
        Object oper_tree=null;


        	ArrayList filters = new ArrayList();

        try {
            // RuleSet.g:1016:5: (dom= ( VAR | WEB ) oper= VAR (filter= event_filter )* (set= setting )? )
            // RuleSet.g:1017:9: dom= ( VAR | WEB ) oper= VAR (filter= event_filter )* (set= setting )?
            {
            root_0 = (Object)adaptor.nil();

            dom=(Token)input.LT(1);
            if ( input.LA(1)==VAR||input.LA(1)==WEB ) {
                input.consume();
                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(dom));
                state.errorRecovery=false;state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }

            oper=(Token)match(input,VAR,FOLLOW_VAR_in_custom_event1993); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            oper_tree = (Object)adaptor.create(oper);
            adaptor.addChild(root_0, oper_tree);
            }
            // RuleSet.g:1017:32: (filter= event_filter )*
            loop69:
            do {
                int alt69=2;
                int LA69_0 = input.LA(1);

                if ( (LA69_0==VAR) ) {
                    int LA69_2 = input.LA(2);

                    if ( (LA69_2==STRING||LA69_2==REX) ) {
                        alt69=1;
                    }


                }


                switch (alt69) {
            	case 1 :
            	    // RuleSet.g:1017:33: filter= event_filter
            	    {
            	    pushFollow(FOLLOW_event_filter_in_custom_event1998);
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
            	    break loop69;
                }
            } while (true);

            // RuleSet.g:1017:88: (set= setting )?
            int alt70=2;
            int LA70_0 = input.LA(1);

            if ( (LA70_0==SETTING) ) {
                alt70=1;
            }
            switch (alt70) {
                case 1 :
                    // RuleSet.g:0:0: set= setting
                    {
                    pushFollow(FOLLOW_setting_in_custom_event2005);
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
    // $ANTLR end "custom_event"

    public static class event_filter_return extends ParserRuleReturnScope {
        public HashMap result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "event_filter"
    // RuleSet.g:1029:1: event_filter returns [HashMap result] : typ= VAR (sfilt= STRING | rfilt= regex ) ;
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
            // RuleSet.g:1030:2: (typ= VAR (sfilt= STRING | rfilt= regex ) )
            // RuleSet.g:1030:4: typ= VAR (sfilt= STRING | rfilt= regex )
            {
            root_0 = (Object)adaptor.nil();

            typ=(Token)match(input,VAR,FOLLOW_VAR_in_event_filter2028); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            typ_tree = (Object)adaptor.create(typ);
            adaptor.addChild(root_0, typ_tree);
            }
            // RuleSet.g:1030:12: (sfilt= STRING | rfilt= regex )
            int alt71=2;
            int LA71_0 = input.LA(1);

            if ( (LA71_0==STRING) ) {
                alt71=1;
            }
            else if ( (LA71_0==REX) ) {
                alt71=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 71, 0, input);

                throw nvae;
            }
            switch (alt71) {
                case 1 :
                    // RuleSet.g:1030:13: sfilt= STRING
                    {
                    sfilt=(Token)match(input,STRING,FOLLOW_STRING_in_event_filter2033); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    sfilt_tree = (Object)adaptor.create(sfilt);
                    adaptor.addChild(root_0, sfilt_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1030:28: rfilt= regex
                    {
                    pushFollow(FOLLOW_regex_in_event_filter2039);
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
    // RuleSet.g:1041:1: on_expr returns [Object result] : ON (s= STRING | r= regex ) ;
    public final RuleSetParser.on_expr_return on_expr() throws RecognitionException {
        RuleSetParser.on_expr_return retval = new RuleSetParser.on_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token s=null;
        Token ON104=null;
        RuleSetParser.regex_return r = null;


        Object s_tree=null;
        Object ON104_tree=null;

        try {
            // RuleSet.g:1041:32: ( ON (s= STRING | r= regex ) )
            // RuleSet.g:1041:34: ON (s= STRING | r= regex )
            {
            root_0 = (Object)adaptor.nil();

            ON104=(Token)match(input,ON,FOLLOW_ON_in_on_expr2058); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            ON104_tree = (Object)adaptor.create(ON104);
            adaptor.addChild(root_0, ON104_tree);
            }
            // RuleSet.g:1042:2: (s= STRING | r= regex )
            int alt72=2;
            int LA72_0 = input.LA(1);

            if ( (LA72_0==STRING) ) {
                alt72=1;
            }
            else if ( (LA72_0==REX) ) {
                alt72=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 72, 0, input);

                throw nvae;
            }
            switch (alt72) {
                case 1 :
                    // RuleSet.g:1042:5: s= STRING
                    {
                    s=(Token)match(input,STRING,FOLLOW_STRING_in_on_expr2066); if (state.failed) return retval;
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
                    // RuleSet.g:1043:5: r= regex
                    {
                    pushFollow(FOLLOW_regex_in_on_expr2077);
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
    // RuleSet.g:1048:2: global_block : GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL ;
    public final RuleSetParser.global_block_return global_block() throws RecognitionException {
        RuleSetParser.global_block_return retval = new RuleSetParser.global_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token name=null;
        Token dtype=null;
        Token src=null;
        Token GLOBAL105=null;
        Token LEFT_CURL106=null;
        Token COLON107=null;
        Token LEFT_SMALL_ARROW108=null;
        Token SEMI110=null;
        Token RIGHT_CURL111=null;
        RuleSetParser.emit_block_return emt = null;

        RuleSetParser.must_be_one_return dst = null;

        RuleSetParser.cachable_return cas = null;

        RuleSetParser.css_emit_return cemt = null;

        RuleSetParser.decl_return decl109 = null;


        Object name_tree=null;
        Object dtype_tree=null;
        Object src_tree=null;
        Object GLOBAL105_tree=null;
        Object LEFT_CURL106_tree=null;
        Object COLON107_tree=null;
        Object LEFT_SMALL_ARROW108_tree=null;
        Object SEMI110_tree=null;
        Object RIGHT_CURL111_tree=null;


        	 ArrayList global_block_array = (ArrayList)rule_json.get("global");
        	 boolean found_cache = false;

        try {
            // RuleSet.g:1055:2: ( GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL )
            // RuleSet.g:1055:4: GLOBAL LEFT_CURL (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            GLOBAL105=(Token)match(input,GLOBAL,FOLLOW_GLOBAL_in_global_block2115); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            GLOBAL105_tree = (Object)adaptor.create(GLOBAL105);
            adaptor.addChild(root_0, GLOBAL105_tree);
            }
            LEFT_CURL106=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_global_block2117); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL106_tree = (Object)adaptor.create(LEFT_CURL106);
            adaptor.addChild(root_0, LEFT_CURL106_tree);
            }
            // RuleSet.g:1056:2: (emt= emit_block | dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )? | cemt= css_emit | decl[global_block_array] | SEMI )*
            loop75:
            do {
                int alt75=6;
                switch ( input.LA(1) ) {
                case EMIT:
                    {
                    alt75=1;
                    }
                    break;
                case VAR:
                    {
                    int LA75_3 = input.LA(2);

                    if ( (LA75_3==EQUAL) ) {
                        alt75=4;
                    }
                    else if ( (LA75_3==VAR) ) {
                        alt75=2;
                    }


                    }
                    break;
                case CSS:
                    {
                    alt75=3;
                    }
                    break;
                case OTHER_OPERATORS:
                case LIKE:
                case REPLACE:
                case MATCH:
                case VAR_DOMAIN:
                    {
                    alt75=4;
                    }
                    break;
                case SEMI:
                    {
                    alt75=5;
                    }
                    break;

                }

                switch (alt75) {
            	case 1 :
            	    // RuleSet.g:1056:4: emt= emit_block
            	    {
            	    pushFollow(FOLLOW_emit_block_in_global_block2124);
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
            	    // RuleSet.g:1061:4: dst= must_be_one[sar(\"dataset\",\"datasource\")] name= VAR ( COLON dtype= DTYPE )? LEFT_SMALL_ARROW src= STRING (cas= cachable )?
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_global_block2134);
            	    dst=must_be_one(sar("dataset","datasource"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, dst.getTree());
            	    name=(Token)match(input,VAR,FOLLOW_VAR_in_global_block2139); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    name_tree = (Object)adaptor.create(name);
            	    adaptor.addChild(root_0, name_tree);
            	    }
            	    // RuleSet.g:1061:58: ( COLON dtype= DTYPE )?
            	    int alt73=2;
            	    int LA73_0 = input.LA(1);

            	    if ( (LA73_0==COLON) ) {
            	        alt73=1;
            	    }
            	    switch (alt73) {
            	        case 1 :
            	            // RuleSet.g:1061:59: COLON dtype= DTYPE
            	            {
            	            COLON107=(Token)match(input,COLON,FOLLOW_COLON_in_global_block2142); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            COLON107_tree = (Object)adaptor.create(COLON107);
            	            adaptor.addChild(root_0, COLON107_tree);
            	            }
            	            dtype=(Token)match(input,DTYPE,FOLLOW_DTYPE_in_global_block2146); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            dtype_tree = (Object)adaptor.create(dtype);
            	            adaptor.addChild(root_0, dtype_tree);
            	            }

            	            }
            	            break;

            	    }

            	    LEFT_SMALL_ARROW108=(Token)match(input,LEFT_SMALL_ARROW,FOLLOW_LEFT_SMALL_ARROW_in_global_block2150); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    LEFT_SMALL_ARROW108_tree = (Object)adaptor.create(LEFT_SMALL_ARROW108);
            	    adaptor.addChild(root_0, LEFT_SMALL_ARROW108_tree);
            	    }
            	    src=(Token)match(input,STRING,FOLLOW_STRING_in_global_block2154); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    src_tree = (Object)adaptor.create(src);
            	    adaptor.addChild(root_0, src_tree);
            	    }
            	    // RuleSet.g:1061:107: (cas= cachable )?
            	    int alt74=2;
            	    int LA74_0 = input.LA(1);

            	    if ( (LA74_0==CACHABLE) ) {
            	        alt74=1;
            	    }
            	    switch (alt74) {
            	        case 1 :
            	            // RuleSet.g:1061:108: cas= cachable
            	            {
            	            pushFollow(FOLLOW_cachable_in_global_block2159);
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
            	      	        dtype = null;
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
            	    // RuleSet.g:1096:4: cemt= css_emit
            	    {
            	    pushFollow(FOLLOW_css_emit_in_global_block2174);
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
            	    // RuleSet.g:1102:4: decl[global_block_array]
            	    {
            	    pushFollow(FOLLOW_decl_in_global_block2182);
            	    decl109=decl(global_block_array);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decl109.getTree());

            	    }
            	    break;
            	case 5 :
            	    // RuleSet.g:1103:4: SEMI
            	    {
            	    SEMI110=(Token)match(input,SEMI,FOLLOW_SEMI_in_global_block2188); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI110_tree = (Object)adaptor.create(SEMI110);
            	    adaptor.addChild(root_0, SEMI110_tree);
            	    }

            	    }
            	    break;

            	default :
            	    break loop75;
                }
            } while (true);

            RIGHT_CURL111=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_global_block2193); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL111_tree = (Object)adaptor.create(RIGHT_CURL111);
            adaptor.addChild(root_0, RIGHT_CURL111_tree);
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
    // RuleSet.g:1110:1: decl[ArrayList block_array] : var= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) EQUAL (hval= HTML | jval= JS | e= expr ) ;
    public final RuleSetParser.decl_return decl(ArrayList  block_array) throws RecognitionException {
        RuleSetParser.decl_return retval = new RuleSetParser.decl_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token var=null;
        Token hval=null;
        Token jval=null;
        Token EQUAL112=null;
        RuleSetParser.expr_return e = null;


        Object var_tree=null;
        Object hval_tree=null;
        Object jval_tree=null;
        Object EQUAL112_tree=null;



        try {
            // RuleSet.g:1113:2: (var= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) EQUAL (hval= HTML | jval= JS | e= expr ) )
            // RuleSet.g:1114:2: var= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) EQUAL (hval= HTML | jval= JS | e= expr )
            {
            root_0 = (Object)adaptor.nil();

            var=(Token)input.LT(1);
            if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                input.consume();
                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(var));
                state.errorRecovery=false;state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }

            EQUAL112=(Token)match(input,EQUAL,FOLLOW_EQUAL_in_decl2234); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EQUAL112_tree = (Object)adaptor.create(EQUAL112);
            adaptor.addChild(root_0, EQUAL112_tree);
            }
            // RuleSet.g:1114:64: (hval= HTML | jval= JS | e= expr )
            int alt76=3;
            switch ( input.LA(1) ) {
            case HTML:
                {
                alt76=1;
                }
                break;
            case JS:
                {
                alt76=2;
                }
                break;
            case LEFT_CURL:
            case VAR:
            case INT:
            case OTHER_OPERATORS:
            case LIKE:
            case REPLACE:
            case MATCH:
            case STRING:
            case VAR_DOMAIN:
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
                alt76=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 76, 0, input);

                throw nvae;
            }

            switch (alt76) {
                case 1 :
                    // RuleSet.g:1114:65: hval= HTML
                    {
                    hval=(Token)match(input,HTML,FOLLOW_HTML_in_decl2239); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    hval_tree = (Object)adaptor.create(hval);
                    adaptor.addChild(root_0, hval_tree);
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1114:75: jval= JS
                    {
                    jval=(Token)match(input,JS,FOLLOW_JS_in_decl2243); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    jval_tree = (Object)adaptor.create(jval);
                    adaptor.addChild(root_0, jval_tree);
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1114:83: e= expr
                    {
                    pushFollow(FOLLOW_expr_in_decl2247);
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
    // RuleSet.g:1138:1: expr returns [Object result] : (fd= function_def | c= conditional_expression ) ;
    public final RuleSetParser.expr_return expr() throws RecognitionException {
        RuleSetParser.expr_return retval = new RuleSetParser.expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.function_def_return fd = null;

        RuleSetParser.conditional_expression_return c = null;




        	HashMap result_hash = new HashMap();

        try {
            // RuleSet.g:1142:2: ( (fd= function_def | c= conditional_expression ) )
            // RuleSet.g:1142:4: (fd= function_def | c= conditional_expression )
            {
            root_0 = (Object)adaptor.nil();

            // RuleSet.g:1142:4: (fd= function_def | c= conditional_expression )
            int alt77=2;
            int LA77_0 = input.LA(1);

            if ( (LA77_0==FUNCTION) ) {
                alt77=1;
            }
            else if ( (LA77_0==LEFT_CURL||(LA77_0>=VAR && LA77_0<=MATCH)||(LA77_0>=STRING && LA77_0<=VAR_DOMAIN)||LA77_0==LEFT_PAREN||LA77_0==NOT||(LA77_0>=REX && LA77_0<=SEEN)||(LA77_0>=FLOAT && LA77_0<=LEFT_BRACKET)||(LA77_0>=CURRENT && LA77_0<=HISTORY)) ) {
                alt77=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 77, 0, input);

                throw nvae;
            }
            switch (alt77) {
                case 1 :
                    // RuleSet.g:1142:5: fd= function_def
                    {
                    pushFollow(FOLLOW_function_def_in_expr2277);
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
                    // RuleSet.g:1145:4: c= conditional_expression
                    {
                    pushFollow(FOLLOW_conditional_expression_in_expr2286);
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
    // RuleSet.g:1149:1: function_def returns [Object result] : FUNCTION LEFT_PAREN (args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )? ( COMMA args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL ;
    public final RuleSetParser.function_def_return function_def() throws RecognitionException {
        RuleSetParser.function_def_return retval = new RuleSetParser.function_def_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token FUNCTION113=null;
        Token LEFT_PAREN114=null;
        Token COMMA115=null;
        Token RIGHT_PAREN116=null;
        Token LEFT_CURL117=null;
        Token SEMI118=null;
        Token SEMI119=null;
        Token RIGHT_CURL120=null;
        Token args=null;
        List list_args=null;
        List list_decs=null;
        RuleSetParser.expr_return e1 = null;

        RuleReturnScope decs = null;
        Object FUNCTION113_tree=null;
        Object LEFT_PAREN114_tree=null;
        Object COMMA115_tree=null;
        Object RIGHT_PAREN116_tree=null;
        Object LEFT_CURL117_tree=null;
        Object SEMI118_tree=null;
        Object SEMI119_tree=null;
        Object RIGHT_CURL120_tree=null;
        Object args_tree=null;


        	ArrayList block_array = new ArrayList();

        try {
            // RuleSet.g:1153:2: ( FUNCTION LEFT_PAREN (args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )? ( COMMA args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL )
            // RuleSet.g:1153:4: FUNCTION LEFT_PAREN (args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )? ( COMMA args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )* RIGHT_PAREN LEFT_CURL (decs+= decl[block_array] )? ( SEMI decs+= decl[block_array] )* ( SEMI )? e1= expr RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            FUNCTION113=(Token)match(input,FUNCTION,FOLLOW_FUNCTION_in_function_def2311); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            FUNCTION113_tree = (Object)adaptor.create(FUNCTION113);
            adaptor.addChild(root_0, FUNCTION113_tree);
            }
            LEFT_PAREN114=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_function_def2313); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_PAREN114_tree = (Object)adaptor.create(LEFT_PAREN114);
            adaptor.addChild(root_0, LEFT_PAREN114_tree);
            }
            // RuleSet.g:1153:28: (args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )?
            int alt78=2;
            int LA78_0 = input.LA(1);

            if ( (LA78_0==VAR||(LA78_0>=OTHER_OPERATORS && LA78_0<=MATCH)||LA78_0==VAR_DOMAIN) ) {
                alt78=1;
            }
            switch (alt78) {
                case 1 :
                    // RuleSet.g:0:0: args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
                    {
                    args=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(args));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    if (list_args==null) list_args=new ArrayList();
                    list_args.add(args);


                    }
                    break;

            }

            // RuleSet.g:1153:83: ( COMMA args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )*
            loop79:
            do {
                int alt79=2;
                int LA79_0 = input.LA(1);

                if ( (LA79_0==COMMA) ) {
                    alt79=1;
                }


                switch (alt79) {
            	case 1 :
            	    // RuleSet.g:1153:84: COMMA args+= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
            	    {
            	    COMMA115=(Token)match(input,COMMA,FOLLOW_COMMA_in_function_def2333); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    COMMA115_tree = (Object)adaptor.create(COMMA115);
            	    adaptor.addChild(root_0, COMMA115_tree);
            	    }
            	    args=(Token)input.LT(1);
            	    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            	        input.consume();
            	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(args));
            	        state.errorRecovery=false;state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }

            	    if (list_args==null) list_args=new ArrayList();
            	    list_args.add(args);


            	    }
            	    break;

            	default :
            	    break loop79;
                }
            } while (true);

            RIGHT_PAREN116=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_function_def2354); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_PAREN116_tree = (Object)adaptor.create(RIGHT_PAREN116);
            adaptor.addChild(root_0, RIGHT_PAREN116_tree);
            }
            LEFT_CURL117=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_function_def2356); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL117_tree = (Object)adaptor.create(LEFT_CURL117);
            adaptor.addChild(root_0, LEFT_CURL117_tree);
            }
            // RuleSet.g:1153:177: (decs+= decl[block_array] )?
            int alt80=2;
            switch ( input.LA(1) ) {
                case VAR_DOMAIN:
                    {
                    int LA80_1 = input.LA(2);

                    if ( (LA80_1==EQUAL) ) {
                        alt80=1;
                    }
                    }
                    break;
                case VAR:
                case OTHER_OPERATORS:
                case REPLACE:
                case MATCH:
                    {
                    int LA80_3 = input.LA(2);

                    if ( (LA80_3==EQUAL) ) {
                        alt80=1;
                    }
                    }
                    break;
                case LIKE:
                    {
                    int LA80_4 = input.LA(2);

                    if ( (LA80_4==EQUAL) ) {
                        alt80=1;
                    }
                    }
                    break;
            }

            switch (alt80) {
                case 1 :
                    // RuleSet.g:0:0: decs+= decl[block_array]
                    {
                    pushFollow(FOLLOW_decl_in_function_def2360);
                    decs=decl(block_array);

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, decs.getTree());
                    if (list_decs==null) list_decs=new ArrayList();
                    list_decs.add(decs.getTree());


                    }
                    break;

            }

            // RuleSet.g:1153:198: ( SEMI decs+= decl[block_array] )*
            loop81:
            do {
                int alt81=2;
                int LA81_0 = input.LA(1);

                if ( (LA81_0==SEMI) ) {
                    switch ( input.LA(2) ) {
                    case VAR_DOMAIN:
                        {
                        int LA81_3 = input.LA(3);

                        if ( (LA81_3==EQUAL) ) {
                            alt81=1;
                        }


                        }
                        break;
                    case VAR:
                    case OTHER_OPERATORS:
                    case REPLACE:
                    case MATCH:
                        {
                        int LA81_4 = input.LA(3);

                        if ( (LA81_4==EQUAL) ) {
                            alt81=1;
                        }


                        }
                        break;
                    case LIKE:
                        {
                        int LA81_5 = input.LA(3);

                        if ( (LA81_5==EQUAL) ) {
                            alt81=1;
                        }


                        }
                        break;

                    }

                }


                switch (alt81) {
            	case 1 :
            	    // RuleSet.g:1153:199: SEMI decs+= decl[block_array]
            	    {
            	    SEMI118=(Token)match(input,SEMI,FOLLOW_SEMI_in_function_def2365); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    SEMI118_tree = (Object)adaptor.create(SEMI118);
            	    adaptor.addChild(root_0, SEMI118_tree);
            	    }
            	    pushFollow(FOLLOW_decl_in_function_def2369);
            	    decs=decl(block_array);

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, decs.getTree());
            	    if (list_decs==null) list_decs=new ArrayList();
            	    list_decs.add(decs.getTree());


            	    }
            	    break;

            	default :
            	    break loop81;
                }
            } while (true);

            // RuleSet.g:1153:230: ( SEMI )?
            int alt82=2;
            int LA82_0 = input.LA(1);

            if ( (LA82_0==SEMI) ) {
                alt82=1;
            }
            switch (alt82) {
                case 1 :
                    // RuleSet.g:0:0: SEMI
                    {
                    SEMI119=(Token)match(input,SEMI,FOLLOW_SEMI_in_function_def2374); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEMI119_tree = (Object)adaptor.create(SEMI119);
                    adaptor.addChild(root_0, SEMI119_tree);
                    }

                    }
                    break;

            }

            pushFollow(FOLLOW_expr_in_function_def2379);
            e1=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
            RIGHT_CURL120=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_function_def2381); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL120_tree = (Object)adaptor.create(RIGHT_CURL120);
            adaptor.addChild(root_0, RIGHT_CURL120_tree);
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
    // RuleSet.g:1173:1: conditional_expression returns [Object result] : d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )? ;
    public final RuleSetParser.conditional_expression_return conditional_expression() throws RecognitionException {
        RuleSetParser.conditional_expression_return retval = new RuleSetParser.conditional_expression_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ARROW_RIGHT121=null;
        Token PIPE122=null;
        RuleSetParser.disjunction_return d = null;

        RuleSetParser.expr_return e1 = null;

        RuleSetParser.expr_return e2 = null;


        Object ARROW_RIGHT121_tree=null;
        Object PIPE122_tree=null;


        	ArrayList tmp_list = new ArrayList();

        try {
            // RuleSet.g:1177:2: (d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )? )
            // RuleSet.g:1177:5: d= disjunction ( ARROW_RIGHT e1= expr PIPE e2= expr )?
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_disjunction_in_conditional_expression2407);
            d=disjunction();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, d.getTree());
            // RuleSet.g:1177:19: ( ARROW_RIGHT e1= expr PIPE e2= expr )?
            int alt83=2;
            int LA83_0 = input.LA(1);

            if ( (LA83_0==ARROW_RIGHT) ) {
                alt83=1;
            }
            switch (alt83) {
                case 1 :
                    // RuleSet.g:1177:20: ARROW_RIGHT e1= expr PIPE e2= expr
                    {
                    ARROW_RIGHT121=(Token)match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_conditional_expression2410); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    ARROW_RIGHT121_tree = (Object)adaptor.create(ARROW_RIGHT121);
                    adaptor.addChild(root_0, ARROW_RIGHT121_tree);
                    }
                    pushFollow(FOLLOW_expr_in_conditional_expression2414);
                    e1=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
                    PIPE122=(Token)match(input,PIPE,FOLLOW_PIPE_in_conditional_expression2416); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    PIPE122_tree = (Object)adaptor.create(PIPE122);
                    adaptor.addChild(root_0, PIPE122_tree);
                    }
                    pushFollow(FOLLOW_expr_in_conditional_expression2420);
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
    // RuleSet.g:1198:1: disjunction returns [Object result] : me1= equality_expr (op= ( OR | AND ) me2= equality_expr )* ;
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
            // RuleSet.g:1203:2: (me1= equality_expr (op= ( OR | AND ) me2= equality_expr )* )
            // RuleSet.g:1203:4: me1= equality_expr (op= ( OR | AND ) me2= equality_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_equality_expr_in_disjunction2452);
            me1=equality_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1203:22: (op= ( OR | AND ) me2= equality_expr )*
            loop84:
            do {
                int alt84=2;
                int LA84_0 = input.LA(1);

                if ( ((LA84_0>=OR && LA84_0<=AND)) ) {
                    alt84=1;
                }


                switch (alt84) {
            	case 1 :
            	    // RuleSet.g:1203:23: op= ( OR | AND ) me2= equality_expr
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

            	    pushFollow(FOLLOW_equality_expr_in_disjunction2465);
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
            	    break loop84;
                }
            } while (true);

            if ( state.backtracking==0 ) {

              		if(found_op) {
              			retval.result = build_exp_result(result);
              			 }
              		else
              		{
              			retval.result = (me1!=null?me1.result:null);
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
    // $ANTLR end "disjunction"

    public static class equality_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "equality_expr"
    // RuleSet.g:1225:1: equality_expr returns [Object result] : me1= add_expr (op= ( PREDOP | LIKE ) me2= add_expr )* ;
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
            // RuleSet.g:1230:2: (me1= add_expr (op= ( PREDOP | LIKE ) me2= add_expr )* )
            // RuleSet.g:1230:4: me1= add_expr (op= ( PREDOP | LIKE ) me2= add_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_add_expr_in_equality_expr2498);
            me1=add_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1230:17: (op= ( PREDOP | LIKE ) me2= add_expr )*
            loop85:
            do {
                int alt85=2;
                alt85 = dfa85.predict(input);
                switch (alt85) {
            	case 1 :
            	    // RuleSet.g:1230:18: op= ( PREDOP | LIKE ) me2= add_expr
            	    {
            	    op=(Token)input.LT(1);
            	    if ( input.LA(1)==LIKE||input.LA(1)==PREDOP ) {
            	        input.consume();
            	        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(op));
            	        state.errorRecovery=false;state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        throw mse;
            	    }

            	    pushFollow(FOLLOW_add_expr_in_equality_expr2511);
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
            	    break loop85;
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

    public static class mult_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "mult_expr"
    // RuleSet.g:1247:1: mult_expr returns [Object result] : me1= unary_expr (op= MULT_OP me2= unary_expr )* ;
    public final RuleSetParser.mult_expr_return mult_expr() throws RecognitionException {
        RuleSetParser.mult_expr_return retval = new RuleSetParser.mult_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token op=null;
        RuleSetParser.unary_expr_return me1 = null;

        RuleSetParser.unary_expr_return me2 = null;


        Object op_tree=null;


             	boolean found_op = false;
             	ArrayList result = new ArrayList();
             
        try {
            // RuleSet.g:1252:7: (me1= unary_expr (op= MULT_OP me2= unary_expr )* )
            // RuleSet.g:1252:9: me1= unary_expr (op= MULT_OP me2= unary_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_unary_expr_in_mult_expr2548);
            me1=unary_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1252:25: (op= MULT_OP me2= unary_expr )*
            loop86:
            do {
                int alt86=2;
                int LA86_0 = input.LA(1);

                if ( (LA86_0==MULT_OP) ) {
                    alt86=1;
                }


                switch (alt86) {
            	case 1 :
            	    // RuleSet.g:1252:26: op= MULT_OP me2= unary_expr
            	    {
            	    op=(Token)match(input,MULT_OP,FOLLOW_MULT_OP_in_mult_expr2554); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    op_tree = (Object)adaptor.create(op);
            	    adaptor.addChild(root_0, op_tree);
            	    }
            	    pushFollow(FOLLOW_unary_expr_in_mult_expr2558);
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
            	    break loop86;
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
    // $ANTLR end "mult_expr"

    public static class add_expr_return extends ParserRuleReturnScope {
        public Object result;
        Object tree;
        public Object getTree() { return tree; }
    };

    // $ANTLR start "add_expr"
    // RuleSet.g:1272:1: add_expr returns [Object result] : me1= mult_expr (op= ( ADD_OP | REX ) me2= mult_expr )* ;
    public final RuleSetParser.add_expr_return add_expr() throws RecognitionException {
        RuleSetParser.add_expr_return retval = new RuleSetParser.add_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token op=null;
        RuleSetParser.mult_expr_return me1 = null;

        RuleSetParser.mult_expr_return me2 = null;


        Object op_tree=null;


        	boolean found_op = false;
        	ArrayList result = new ArrayList();

        try {
            // RuleSet.g:1277:2: (me1= mult_expr (op= ( ADD_OP | REX ) me2= mult_expr )* )
            // RuleSet.g:1277:4: me1= mult_expr (op= ( ADD_OP | REX ) me2= mult_expr )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_mult_expr_in_add_expr2605);
            me1=mult_expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, me1.getTree());
            // RuleSet.g:1277:19: (op= ( ADD_OP | REX ) me2= mult_expr )*
            loop87:
            do {
                int alt87=2;
                alt87 = dfa87.predict(input);
                switch (alt87) {
            	case 1 :
            	    // RuleSet.g:1277:20: op= ( ADD_OP | REX ) me2= mult_expr
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

            	    pushFollow(FOLLOW_mult_expr_in_add_expr2619);
            	    me2=mult_expr();

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
            	    break loop87;
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
    // RuleSet.g:1296:1: unary_expr returns [Object result] options {backtrack=true; } : ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe | roe= regex | oe= operator_expr );
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
        Token NOT123=null;
        Token SEEN124=null;
        Token char_literal126=null;
        Token SEEN127=null;
        Token char_literal129=null;
        Token COLON130=null;
        Token COLON131=null;
        RuleSetParser.unary_expr_return ue = null;

        RuleSetParser.timeframe_return t = null;

        RuleSetParser.must_be_one_return op = null;

        RuleSetParser.expr_return e = null;

        RuleSetParser.regex_return roe = null;

        RuleSetParser.operator_expr_return oe = null;

        RuleSetParser.must_be_return must_be125 = null;

        RuleSetParser.must_be_return must_be128 = null;


        Object rx_tree=null;
        Object vd_tree=null;
        Object v_tree=null;
        Object rx_1_tree=null;
        Object rx_2_tree=null;
        Object pop_tree=null;
        Object NOT123_tree=null;
        Object SEEN124_tree=null;
        Object char_literal126_tree=null;
        Object SEEN127_tree=null;
        Object char_literal129_tree=null;
        Object COLON130_tree=null;
        Object COLON131_tree=null;




        try {
            // RuleSet.g:1300:2: ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe | roe= regex | oe= operator_expr )
            int alt89=7;
            alt89 = dfa89.predict(input);
            switch (alt89) {
                case 1 :
                    // RuleSet.g:1300:4: NOT ue= unary_expr
                    {
                    root_0 = (Object)adaptor.nil();

                    NOT123=(Token)match(input,NOT,FOLLOW_NOT_in_unary_expr2663); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    NOT123_tree = (Object)adaptor.create(NOT123);
                    adaptor.addChild(root_0, NOT123_tree);
                    }
                    pushFollow(FOLLOW_unary_expr_in_unary_expr2667);
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
                    // RuleSet.g:1309:4: SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )?
                    {
                    root_0 = (Object)adaptor.nil();

                    SEEN124=(Token)match(input,SEEN,FOLLOW_SEEN_in_unary_expr2676); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEEN124_tree = (Object)adaptor.create(SEEN124);
                    adaptor.addChild(root_0, SEEN124_tree);
                    }
                    rx=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2680); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_tree = (Object)adaptor.create(rx);
                    adaptor.addChild(root_0, rx_tree);
                    }
                    pushFollow(FOLLOW_must_be_in_unary_expr2682);
                    must_be125=must_be("in");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be125.getTree());
                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2687); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    char_literal126=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2689); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal126_tree = (Object)adaptor.create(char_literal126);
                    adaptor.addChild(root_0, char_literal126_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    // RuleSet.g:1309:106: (t= timeframe )?
                    int alt88=2;
                    alt88 = dfa88.predict(input);
                    switch (alt88) {
                        case 1 :
                            // RuleSet.g:0:0: t= timeframe
                            {
                            pushFollow(FOLLOW_timeframe_in_unary_expr2709);
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
                      		     else
                      		      	tmp.put("timeframe",null);

                      	      	retval.result = tmp;		
                      	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1323:4: SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
                    {
                    root_0 = (Object)adaptor.nil();

                    SEEN127=(Token)match(input,SEEN,FOLLOW_SEEN_in_unary_expr2717); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    SEEN127_tree = (Object)adaptor.create(SEEN127);
                    adaptor.addChild(root_0, SEEN127_tree);
                    }
                    rx_1=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2721); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_1_tree = (Object)adaptor.create(rx_1);
                    adaptor.addChild(root_0, rx_1_tree);
                    }
                    pushFollow(FOLLOW_must_be_one_in_unary_expr2725);
                    op=must_be_one(sar("before","after"));

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, op.getTree());
                    rx_2=(Token)match(input,STRING,FOLLOW_STRING_in_unary_expr2730); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    rx_2_tree = (Object)adaptor.create(rx_2);
                    adaptor.addChild(root_0, rx_2_tree);
                    }
                    pushFollow(FOLLOW_must_be_in_unary_expr2733);
                    must_be128=must_be("in");

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be128.getTree());
                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2738); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    char_literal129=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2740); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal129_tree = (Object)adaptor.create(char_literal129);
                    adaptor.addChild(root_0, char_literal129_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
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
                    // RuleSet.g:1333:4: vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe
                    {
                    root_0 = (Object)adaptor.nil();

                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2765); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    COLON130=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2767); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON130_tree = (Object)adaptor.create(COLON130);
                    adaptor.addChild(root_0, COLON130_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    pop=(Token)input.LT(1);
                    if ( input.LA(1)==LIKE||input.LA(1)==PREDOP ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(pop));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    pushFollow(FOLLOW_expr_in_unary_expr2795);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    pushFollow(FOLLOW_timeframe_in_unary_expr2799);
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
                    // RuleSet.g:1345:4: vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe
                    {
                    root_0 = (Object)adaptor.nil();

                    vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_unary_expr2809); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    vd_tree = (Object)adaptor.create(vd);
                    adaptor.addChild(root_0, vd_tree);
                    }
                    COLON131=(Token)match(input,COLON,FOLLOW_COLON_in_unary_expr2811); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON131_tree = (Object)adaptor.create(COLON131);
                    adaptor.addChild(root_0, COLON131_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    pushFollow(FOLLOW_timeframe_in_unary_expr2831);
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
                      	      	HashMap tmp2 = new HashMap();
                      	      	tmp2.put("val","true");
                      	      	tmp2.put("type","bool");
                      	      	tmp.put("expr",tmp2);
                      	      	tmp.put("ineq","==");
                      	      	tmp.put("var",(v!=null?v.getText():null));
                      	      	retval.result = tmp;		
                      	
                      	
                    }

                    }
                    break;
                case 6 :
                    // RuleSet.g:1360:4: roe= regex
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_regex_in_unary_expr2840);
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
                    // RuleSet.g:1363:4: oe= operator_expr
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_operator_expr_in_unary_expr2849);
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
    // RuleSet.g:1369:1: operator_expr returns [Object result] : f= factor (o= operator )* ;
    public final RuleSetParser.operator_expr_return operator_expr() throws RecognitionException {
        RuleSetParser.operator_expr_return retval = new RuleSetParser.operator_expr_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.factor_return f = null;

        RuleSetParser.operator_return o = null;




        	ArrayList operators = new ArrayList();

        try {
            // RuleSet.g:1374:2: (f= factor (o= operator )* )
            // RuleSet.g:1374:4: f= factor (o= operator )*
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_factor_in_operator_expr2878);
            f=factor();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, f.getTree());
            // RuleSet.g:1374:14: (o= operator )*
            loop90:
            do {
                int alt90=2;
                int LA90_0 = input.LA(1);

                if ( (LA90_0==DOT) ) {
                    alt90=1;
                }


                switch (alt90) {
            	case 1 :
            	    // RuleSet.g:1374:15: o= operator
            	    {
            	    pushFollow(FOLLOW_operator_in_operator_expr2884);
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
            	    break loop90;
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
    // RuleSet.g:1412:1: operator returns [String oper,ArrayList exprs] : DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN ) ;
    public final RuleSetParser.operator_return operator() throws RecognitionException {
        RuleSetParser.operator_return retval = new RuleSetParser.operator_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token o=null;
        Token o1=null;
        Token o2=null;
        Token DOT132=null;
        Token LEFT_PAREN133=null;
        Token char_literal134=null;
        Token RIGHT_PAREN135=null;
        Token LEFT_PAREN136=null;
        Token RIGHT_PAREN137=null;
        Token LEFT_PAREN138=null;
        Token char_literal139=null;
        Token RIGHT_PAREN140=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.expr_return e1 = null;

        RuleSetParser.expr_return rx = null;


        Object o_tree=null;
        Object o1_tree=null;
        Object o2_tree=null;
        Object DOT132_tree=null;
        Object LEFT_PAREN133_tree=null;
        Object char_literal134_tree=null;
        Object RIGHT_PAREN135_tree=null;
        Object LEFT_PAREN136_tree=null;
        Object RIGHT_PAREN137_tree=null;
        Object LEFT_PAREN138_tree=null;
        Object char_literal139_tree=null;
        Object RIGHT_PAREN140_tree=null;

        	
        	ArrayList rexprs = new ArrayList();

        try {
            // RuleSet.g:1417:2: ( DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN ) )
            // RuleSet.g:1417:4: DOT (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN )
            {
            root_0 = (Object)adaptor.nil();

            DOT132=(Token)match(input,DOT,FOLLOW_DOT_in_operator2911); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            DOT132_tree = (Object)adaptor.create(DOT132);
            adaptor.addChild(root_0, DOT132_tree);
            }
            // RuleSet.g:1417:8: (o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN | o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN | o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN )
            int alt93=3;
            switch ( input.LA(1) ) {
            case OTHER_OPERATORS:
                {
                alt93=1;
                }
                break;
            case MATCH:
                {
                alt93=2;
                }
                break;
            case REPLACE:
                {
                alt93=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 93, 0, input);

                throw nvae;
            }

            switch (alt93) {
                case 1 :
                    // RuleSet.g:1417:10: o= OTHER_OPERATORS LEFT_PAREN (e= expr ( ',' e1= expr )* )? RIGHT_PAREN
                    {
                    o=(Token)match(input,OTHER_OPERATORS,FOLLOW_OTHER_OPERATORS_in_operator2917); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o_tree = (Object)adaptor.create(o);
                    adaptor.addChild(root_0, o_tree);
                    }
                    LEFT_PAREN133=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator2919); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN133_tree = (Object)adaptor.create(LEFT_PAREN133);
                    adaptor.addChild(root_0, LEFT_PAREN133_tree);
                    }
                    // RuleSet.g:1417:39: (e= expr ( ',' e1= expr )* )?
                    int alt92=2;
                    int LA92_0 = input.LA(1);

                    if ( (LA92_0==LEFT_CURL||(LA92_0>=VAR && LA92_0<=MATCH)||(LA92_0>=STRING && LA92_0<=VAR_DOMAIN)||LA92_0==LEFT_PAREN||LA92_0==NOT||LA92_0==FUNCTION||(LA92_0>=REX && LA92_0<=SEEN)||(LA92_0>=FLOAT && LA92_0<=LEFT_BRACKET)||(LA92_0>=CURRENT && LA92_0<=HISTORY)) ) {
                        alt92=1;
                    }
                    switch (alt92) {
                        case 1 :
                            // RuleSet.g:1417:40: e= expr ( ',' e1= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_operator2924);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                              rexprs.add(e.result); 
                            }
                            // RuleSet.g:1417:72: ( ',' e1= expr )*
                            loop91:
                            do {
                                int alt91=2;
                                int LA91_0 = input.LA(1);

                                if ( (LA91_0==COMMA) ) {
                                    alt91=1;
                                }


                                switch (alt91) {
                            	case 1 :
                            	    // RuleSet.g:1417:73: ',' e1= expr
                            	    {
                            	    char_literal134=(Token)match(input,COMMA,FOLLOW_COMMA_in_operator2929); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    char_literal134_tree = (Object)adaptor.create(char_literal134);
                            	    adaptor.addChild(root_0, char_literal134_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_operator2933);
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
                            	    break loop91;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN135=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator2942); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN135_tree = (Object)adaptor.create(RIGHT_PAREN135);
                    adaptor.addChild(root_0, RIGHT_PAREN135_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		// Remove .
                            		retval.oper = (o!=null?o.getText():null);
                            		retval.exprs = rexprs;
                            	
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1423:9: o1= MATCH LEFT_PAREN e= expr RIGHT_PAREN
                    {
                    o1=(Token)match(input,MATCH,FOLLOW_MATCH_in_operator2966); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o1_tree = (Object)adaptor.create(o1);
                    adaptor.addChild(root_0, o1_tree);
                    }
                    LEFT_PAREN136=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator2968); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN136_tree = (Object)adaptor.create(LEFT_PAREN136);
                    adaptor.addChild(root_0, LEFT_PAREN136_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator2972);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    if ( state.backtracking==0 ) {
                       rexprs.add(e.result); 
                    }
                    RIGHT_PAREN137=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator2977); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN137_tree = (Object)adaptor.create(RIGHT_PAREN137);
                    adaptor.addChild(root_0, RIGHT_PAREN137_tree);
                    }
                    if ( state.backtracking==0 ) {

                            		// Remove .
                            		retval.oper = (o1!=null?o1.getText():null);
                            		retval.exprs = rexprs;
                            	
                    }

                    }
                    break;
                case 3 :
                    // RuleSet.g:1429:9: o2= REPLACE LEFT_PAREN rx= expr ',' e1= expr RIGHT_PAREN
                    {
                    o2=(Token)match(input,REPLACE,FOLLOW_REPLACE_in_operator3002); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    o2_tree = (Object)adaptor.create(o2);
                    adaptor.addChild(root_0, o2_tree);
                    }
                    LEFT_PAREN138=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_operator3004); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN138_tree = (Object)adaptor.create(LEFT_PAREN138);
                    adaptor.addChild(root_0, LEFT_PAREN138_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator3008);
                    rx=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, rx.getTree());
                    if ( state.backtracking==0 ) {
                      rexprs.add((rx!=null?rx.result:null)); 
                    }
                    char_literal139=(Token)match(input,COMMA,FOLLOW_COMMA_in_operator3012); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    char_literal139_tree = (Object)adaptor.create(char_literal139);
                    adaptor.addChild(root_0, char_literal139_tree);
                    }
                    pushFollow(FOLLOW_expr_in_operator3016);
                    e1=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e1.getTree());
                    RIGHT_PAREN140=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_operator3019); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN140_tree = (Object)adaptor.create(RIGHT_PAREN140);
                    adaptor.addChild(root_0, RIGHT_PAREN140_tree);
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
    // RuleSet.g:1440:1: factor returns [Object result] options {backtrack=true; } : (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | CURRENT d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | HISTORY e= expr d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex );
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
        Token LEFT_BRACKET141=null;
        Token RIGHT_BRACKET142=null;
        Token COLON143=null;
        Token CURRENT144=null;
        Token COLON145=null;
        Token HISTORY146=null;
        Token COLON147=null;
        Token LEFT_PAREN148=null;
        Token COMMA149=null;
        Token RIGHT_PAREN150=null;
        Token LEFT_PAREN151=null;
        Token COMMA152=null;
        Token RIGHT_PAREN153=null;
        Token LEFT_BRACKET154=null;
        Token COMMA155=null;
        Token RIGHT_BRACKET156=null;
        Token LEFT_CURL157=null;
        Token COMMA158=null;
        Token RIGHT_CURL159=null;
        Token LEFT_PAREN160=null;
        Token RIGHT_PAREN161=null;
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
        Object LEFT_BRACKET141_tree=null;
        Object RIGHT_BRACKET142_tree=null;
        Object COLON143_tree=null;
        Object CURRENT144_tree=null;
        Object COLON145_tree=null;
        Object HISTORY146_tree=null;
        Object COLON147_tree=null;
        Object LEFT_PAREN148_tree=null;
        Object COMMA149_tree=null;
        Object RIGHT_PAREN150_tree=null;
        Object LEFT_PAREN151_tree=null;
        Object COMMA152_tree=null;
        Object RIGHT_PAREN153_tree=null;
        Object LEFT_BRACKET154_tree=null;
        Object COMMA155_tree=null;
        Object RIGHT_BRACKET156_tree=null;
        Object LEFT_CURL157_tree=null;
        Object COMMA158_tree=null;
        Object RIGHT_CURL159_tree=null;
        Object LEFT_PAREN160_tree=null;
        Object RIGHT_PAREN161_tree=null;


              ArrayList exprs2 = new ArrayList(); 


        try {
            // RuleSet.g:1445:2: (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | CURRENT d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | HISTORY e= expr d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex )
            int alt102=15;
            alt102 = dfa102.predict(input);
            switch (alt102) {
                case 1 :
                    // RuleSet.g:1445:4: iv= INT
                    {
                    root_0 = (Object)adaptor.nil();

                    iv=(Token)match(input,INT,FOLLOW_INT_in_factor3059); if (state.failed) return retval;
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
                    // RuleSet.g:1451:9: sv= STRING
                    {
                    root_0 = (Object)adaptor.nil();

                    sv=(Token)match(input,STRING,FOLLOW_STRING_in_factor3074); if (state.failed) return retval;
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
                    // RuleSet.g:1457:9: fv= FLOAT
                    {
                    root_0 = (Object)adaptor.nil();

                    fv=(Token)match(input,FLOAT,FOLLOW_FLOAT_in_factor3094); if (state.failed) return retval;
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
                    // RuleSet.g:1463:9: bv= ( TRUE | FALSE )
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
                    // RuleSet.g:1469:9: bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET
                    {
                    root_0 = (Object)adaptor.nil();

                    bv=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(bv));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    LEFT_BRACKET141=(Token)match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_factor3148); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_BRACKET141_tree = (Object)adaptor.create(LEFT_BRACKET141);
                    adaptor.addChild(root_0, LEFT_BRACKET141_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor3152);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    RIGHT_BRACKET142=(Token)match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_factor3154); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_BRACKET142_tree = (Object)adaptor.create(RIGHT_BRACKET142);
                    adaptor.addChild(root_0, RIGHT_BRACKET142_tree);
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
                    // RuleSet.g:1483:9: d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
                    {
                    root_0 = (Object)adaptor.nil();

                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor3169); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON143=(Token)match(input,COLON,FOLLOW_COLON_in_factor3171); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON143_tree = (Object)adaptor.create(COLON143);
                    adaptor.addChild(root_0, COLON143_tree);
                    }
                    vv=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(vv));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
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
                    // RuleSet.g:1490:9: CURRENT d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
                    {
                    root_0 = (Object)adaptor.nil();

                    CURRENT144=(Token)match(input,CURRENT,FOLLOW_CURRENT_in_factor3199); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    CURRENT144_tree = (Object)adaptor.create(CURRENT144);
                    adaptor.addChild(root_0, CURRENT144_tree);
                    }
                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor3203); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON145=(Token)match(input,COLON,FOLLOW_COLON_in_factor3205); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON145_tree = (Object)adaptor.create(COLON145);
                    adaptor.addChild(root_0, COLON145_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
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
                      	      	tmp.put("domain",(d!=null?d.getText():null));
                      	      	tmp.put("name",(v!=null?v.getText():null));
                      	      	tmp.put("type","trail_history");
                      	      	HashMap tmp2 = new HashMap();
                      	      	tmp2.put("val","0");
                      	      	tmp2.put("type","num");
                      	      	tmp.put("offset",tmp2);
                      	      	retval.result = tmp;
                            
                    }

                    }
                    break;
                case 8 :
                    // RuleSet.g:1501:9: HISTORY e= expr d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
                    {
                    root_0 = (Object)adaptor.nil();

                    HISTORY146=(Token)match(input,HISTORY,FOLLOW_HISTORY_in_factor3234); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    HISTORY146_tree = (Object)adaptor.create(HISTORY146);
                    adaptor.addChild(root_0, HISTORY146_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor3238);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_factor3242); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    d_tree = (Object)adaptor.create(d);
                    adaptor.addChild(root_0, d_tree);
                    }
                    COLON147=(Token)match(input,COLON,FOLLOW_COLON_in_factor3244); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    COLON147_tree = (Object)adaptor.create(COLON147);
                    adaptor.addChild(root_0, COLON147_tree);
                    }
                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
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
                    // RuleSet.g:1511:9: n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_namespace_in_factor3274);
                    n=namespace();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, n.getTree());
                    p=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(p));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    LEFT_PAREN148=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3292); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN148_tree = (Object)adaptor.create(LEFT_PAREN148);
                    adaptor.addChild(root_0, LEFT_PAREN148_tree);
                    }
                    // RuleSet.g:1511:86: (e= expr ( COMMA e= expr )* )?
                    int alt95=2;
                    int LA95_0 = input.LA(1);

                    if ( (LA95_0==LEFT_CURL||(LA95_0>=VAR && LA95_0<=MATCH)||(LA95_0>=STRING && LA95_0<=VAR_DOMAIN)||LA95_0==LEFT_PAREN||LA95_0==NOT||LA95_0==FUNCTION||(LA95_0>=REX && LA95_0<=SEEN)||(LA95_0>=FLOAT && LA95_0<=LEFT_BRACKET)||(LA95_0>=CURRENT && LA95_0<=HISTORY)) ) {
                        alt95=1;
                    }
                    switch (alt95) {
                        case 1 :
                            // RuleSet.g:1511:87: e= expr ( COMMA e= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3297);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                               exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1511:121: ( COMMA e= expr )*
                            loop94:
                            do {
                                int alt94=2;
                                int LA94_0 = input.LA(1);

                                if ( (LA94_0==COMMA) ) {
                                    alt94=1;
                                }


                                switch (alt94) {
                            	case 1 :
                            	    // RuleSet.g:1511:123: COMMA e= expr
                            	    {
                            	    COMMA149=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3303); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA149_tree = (Object)adaptor.create(COMMA149);
                            	    adaptor.addChild(root_0, COMMA149_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3307);
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
                            	    break loop94;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN150=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3316); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN150_tree = (Object)adaptor.create(RIGHT_PAREN150);
                    adaptor.addChild(root_0, RIGHT_PAREN150_tree);
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
                    // RuleSet.g:1519:9: v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                        input.consume();
                        if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                        state.errorRecovery=false;state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return retval;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        throw mse;
                    }

                    LEFT_PAREN151=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3345); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN151_tree = (Object)adaptor.create(LEFT_PAREN151);
                    adaptor.addChild(root_0, LEFT_PAREN151_tree);
                    }
                    // RuleSet.g:1519:74: (e= expr ( COMMA e= expr )* )?
                    int alt97=2;
                    int LA97_0 = input.LA(1);

                    if ( (LA97_0==LEFT_CURL||(LA97_0>=VAR && LA97_0<=MATCH)||(LA97_0>=STRING && LA97_0<=VAR_DOMAIN)||LA97_0==LEFT_PAREN||LA97_0==NOT||LA97_0==FUNCTION||(LA97_0>=REX && LA97_0<=SEEN)||(LA97_0>=FLOAT && LA97_0<=LEFT_BRACKET)||(LA97_0>=CURRENT && LA97_0<=HISTORY)) ) {
                        alt97=1;
                    }
                    switch (alt97) {
                        case 1 :
                            // RuleSet.g:1519:75: e= expr ( COMMA e= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3350);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                                exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1519:109: ( COMMA e= expr )*
                            loop96:
                            do {
                                int alt96=2;
                                int LA96_0 = input.LA(1);

                                if ( (LA96_0==COMMA) ) {
                                    alt96=1;
                                }


                                switch (alt96) {
                            	case 1 :
                            	    // RuleSet.g:1519:111: COMMA e= expr
                            	    {
                            	    COMMA152=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3355); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA152_tree = (Object)adaptor.create(COMMA152);
                            	    adaptor.addChild(root_0, COMMA152_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3359);
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
                            	    break loop96;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_PAREN153=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3368); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN153_tree = (Object)adaptor.create(RIGHT_PAREN153);
                    adaptor.addChild(root_0, RIGHT_PAREN153_tree);
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
                    // RuleSet.g:1530:9: LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_BRACKET154=(Token)match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_factor3380); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_BRACKET154_tree = (Object)adaptor.create(LEFT_BRACKET154);
                    adaptor.addChild(root_0, LEFT_BRACKET154_tree);
                    }
                    // RuleSet.g:1530:22: (e= expr ( COMMA e2= expr )* )?
                    int alt99=2;
                    int LA99_0 = input.LA(1);

                    if ( (LA99_0==LEFT_CURL||(LA99_0>=VAR && LA99_0<=MATCH)||(LA99_0>=STRING && LA99_0<=VAR_DOMAIN)||LA99_0==LEFT_PAREN||LA99_0==NOT||LA99_0==FUNCTION||(LA99_0>=REX && LA99_0<=SEEN)||(LA99_0>=FLOAT && LA99_0<=LEFT_BRACKET)||(LA99_0>=CURRENT && LA99_0<=HISTORY)) ) {
                        alt99=1;
                    }
                    switch (alt99) {
                        case 1 :
                            // RuleSet.g:1530:23: e= expr ( COMMA e2= expr )*
                            {
                            pushFollow(FOLLOW_expr_in_factor3385);
                            e=expr();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                            if ( state.backtracking==0 ) {
                               exprs2.add((e!=null?e.result:null)); 
                            }
                            // RuleSet.g:1530:57: ( COMMA e2= expr )*
                            loop98:
                            do {
                                int alt98=2;
                                int LA98_0 = input.LA(1);

                                if ( (LA98_0==COMMA) ) {
                                    alt98=1;
                                }


                                switch (alt98) {
                            	case 1 :
                            	    // RuleSet.g:1530:58: COMMA e2= expr
                            	    {
                            	    COMMA155=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3390); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA155_tree = (Object)adaptor.create(COMMA155);
                            	    adaptor.addChild(root_0, COMMA155_tree);
                            	    }
                            	    pushFollow(FOLLOW_expr_in_factor3394);
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
                            	    break loop98;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_BRACKET156=(Token)match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_factor3402); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_BRACKET156_tree = (Object)adaptor.create(RIGHT_BRACKET156);
                    adaptor.addChild(root_0, RIGHT_BRACKET156_tree);
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
                    // RuleSet.g:1537:9: LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_CURL157=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_factor3414); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_CURL157_tree = (Object)adaptor.create(LEFT_CURL157);
                    adaptor.addChild(root_0, LEFT_CURL157_tree);
                    }
                    // RuleSet.g:1537:19: (h1= hash_line ( COMMA h2= hash_line )* )?
                    int alt101=2;
                    int LA101_0 = input.LA(1);

                    if ( (LA101_0==STRING) ) {
                        alt101=1;
                    }
                    switch (alt101) {
                        case 1 :
                            // RuleSet.g:1537:20: h1= hash_line ( COMMA h2= hash_line )*
                            {
                            pushFollow(FOLLOW_hash_line_in_factor3419);
                            h1=hash_line();

                            state._fsp--;
                            if (state.failed) return retval;
                            if ( state.backtracking==0 ) adaptor.addChild(root_0, h1.getTree());
                            if ( state.backtracking==0 ) {
                                exprs2.add((h1!=null?h1.result:null));
                            }
                            // RuleSet.g:1537:61: ( COMMA h2= hash_line )*
                            loop100:
                            do {
                                int alt100=2;
                                int LA100_0 = input.LA(1);

                                if ( (LA100_0==COMMA) ) {
                                    alt100=1;
                                }


                                switch (alt100) {
                            	case 1 :
                            	    // RuleSet.g:1537:62: COMMA h2= hash_line
                            	    {
                            	    COMMA158=(Token)match(input,COMMA,FOLLOW_COMMA_in_factor3424); if (state.failed) return retval;
                            	    if ( state.backtracking==0 ) {
                            	    COMMA158_tree = (Object)adaptor.create(COMMA158);
                            	    adaptor.addChild(root_0, COMMA158_tree);
                            	    }
                            	    pushFollow(FOLLOW_hash_line_in_factor3428);
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
                            	    break loop100;
                                }
                            } while (true);


                            }
                            break;

                    }

                    RIGHT_CURL159=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_factor3437); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_CURL159_tree = (Object)adaptor.create(RIGHT_CURL159);
                    adaptor.addChild(root_0, RIGHT_CURL159_tree);
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
                    // RuleSet.g:1544:9: LEFT_PAREN e= expr RIGHT_PAREN
                    {
                    root_0 = (Object)adaptor.nil();

                    LEFT_PAREN160=(Token)match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_factor3449); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    LEFT_PAREN160_tree = (Object)adaptor.create(LEFT_PAREN160);
                    adaptor.addChild(root_0, LEFT_PAREN160_tree);
                    }
                    pushFollow(FOLLOW_expr_in_factor3453);
                    e=expr();

                    state._fsp--;
                    if (state.failed) return retval;
                    if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
                    RIGHT_PAREN161=(Token)match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_factor3456); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    RIGHT_PAREN161_tree = (Object)adaptor.create(RIGHT_PAREN161);
                    adaptor.addChild(root_0, RIGHT_PAREN161_tree);
                    }
                    if ( state.backtracking==0 ) {
                       retval.result =(e!=null?e.result:null); 
                    }

                    }
                    break;
                case 14 :
                    // RuleSet.g:1545:9: v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH )
                    {
                    root_0 = (Object)adaptor.nil();

                    v=(Token)input.LT(1);
                    if ( input.LA(1)==VAR||input.LA(1)==OTHER_OPERATORS||(input.LA(1)>=REPLACE && input.LA(1)<=MATCH) ) {
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
                    // RuleSet.g:1551:9: reg= regex
                    {
                    root_0 = (Object)adaptor.nil();

                    pushFollow(FOLLOW_regex_in_factor3499);
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
    // RuleSet.g:1564:10: fragment namespace returns [String result] : v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) ':' ;
    public final RuleSetParser.namespace_return namespace() throws RecognitionException {
        RuleSetParser.namespace_return retval = new RuleSetParser.namespace_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token v=null;
        Token char_literal162=null;

        Object v_tree=null;
        Object char_literal162_tree=null;

        try {
            // RuleSet.g:1565:2: (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) ':' )
            // RuleSet.g:1565:4: v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) ':'
            {
            root_0 = (Object)adaptor.nil();

            v=(Token)input.LT(1);
            if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
                input.consume();
                if ( state.backtracking==0 ) adaptor.addChild(root_0, (Object)adaptor.create(v));
                state.errorRecovery=false;state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return retval;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                throw mse;
            }

            char_literal162=(Token)match(input,COLON,FOLLOW_COLON_in_namespace3546); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            char_literal162_tree = (Object)adaptor.create(char_literal162);
            adaptor.addChild(root_0, char_literal162_tree);
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
    // RuleSet.g:1572:1: timeframe returns [Object result,String time] : WITHIN e= expr p= period ;
    public final RuleSetParser.timeframe_return timeframe() throws RecognitionException {
        RuleSetParser.timeframe_return retval = new RuleSetParser.timeframe_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token WITHIN163=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.period_return p = null;


        Object WITHIN163_tree=null;

        try {
            // RuleSet.g:1573:2: ( WITHIN e= expr p= period )
            // RuleSet.g:1573:5: WITHIN e= expr p= period
            {
            root_0 = (Object)adaptor.nil();

            WITHIN163=(Token)match(input,WITHIN,FOLLOW_WITHIN_in_timeframe3568); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            WITHIN163_tree = (Object)adaptor.create(WITHIN163);
            adaptor.addChild(root_0, WITHIN163_tree);
            }
            pushFollow(FOLLOW_expr_in_timeframe3572);
            e=expr();

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, e.getTree());
            pushFollow(FOLLOW_period_in_timeframe3576);
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
    // RuleSet.g:1581:1: hash_line returns [HashMap result] : s= STRING COLON e= expr ;
    public final RuleSetParser.hash_line_return hash_line() throws RecognitionException {
        RuleSetParser.hash_line_return retval = new RuleSetParser.hash_line_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token s=null;
        Token COLON164=null;
        RuleSetParser.expr_return e = null;


        Object s_tree=null;
        Object COLON164_tree=null;

        try {
            // RuleSet.g:1582:2: (s= STRING COLON e= expr )
            // RuleSet.g:1582:4: s= STRING COLON e= expr
            {
            root_0 = (Object)adaptor.nil();

            s=(Token)match(input,STRING,FOLLOW_STRING_in_hash_line3603); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            s_tree = (Object)adaptor.create(s);
            adaptor.addChild(root_0, s_tree);
            }
            COLON164=(Token)match(input,COLON,FOLLOW_COLON_in_hash_line3605); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON164_tree = (Object)adaptor.create(COLON164);
            adaptor.addChild(root_0, COLON164_tree);
            }
            pushFollow(FOLLOW_expr_in_hash_line3609);
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
    // RuleSet.g:1591:1: css_emit returns [String emit_value] : CSS (h= HTML | h= STRING ) ;
    public final RuleSetParser.css_emit_return css_emit() throws RecognitionException {
        RuleSetParser.css_emit_return retval = new RuleSetParser.css_emit_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token h=null;
        Token CSS165=null;

        Object h_tree=null;
        Object CSS165_tree=null;

        try {
            // RuleSet.g:1592:2: ( CSS (h= HTML | h= STRING ) )
            // RuleSet.g:1592:4: CSS (h= HTML | h= STRING )
            {
            root_0 = (Object)adaptor.nil();

            CSS165=(Token)match(input,CSS,FOLLOW_CSS_in_css_emit3627); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            CSS165_tree = (Object)adaptor.create(CSS165);
            adaptor.addChild(root_0, CSS165_tree);
            }
            // RuleSet.g:1592:8: (h= HTML | h= STRING )
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
                    // RuleSet.g:1592:10: h= HTML
                    {
                    h=(Token)match(input,HTML,FOLLOW_HTML_in_css_emit3633); if (state.failed) return retval;
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
                    // RuleSet.g:1593:3: h= STRING
                    {
                    h=(Token)match(input,STRING,FOLLOW_STRING_in_css_emit3641); if (state.failed) return retval;
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
    // RuleSet.g:1597:1: period : must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")] ;
    public final RuleSetParser.period_return period() throws RecognitionException {
        RuleSetParser.period_return retval = new RuleSetParser.period_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        RuleSetParser.must_be_one_return must_be_one166 = null;



        try {
            // RuleSet.g:1598:2: ( must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")] )
            // RuleSet.g:1599:3: must_be_one[sar( \"years\", \"months\", \"weeks\", \"days\", \"hours\", \"minutes\", \"seconds\", \"year\", \"month\", \"week\", \"day\", \"hour\", \"minute\", \"second\")]
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_one_in_period3661);
            must_be_one166=must_be_one(sar( "years", "months", "weeks", "days", "hours", "minutes", "seconds", "year", "month", "week", "day", "hour", "minute", "second"));

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be_one166.getTree());

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
    // RuleSet.g:1619:1: cachable returns [Object what] : ca= CACHABLE ( FOR tm= INT per= period )? ;
    public final RuleSetParser.cachable_return cachable() throws RecognitionException {
        RuleSetParser.cachable_return retval = new RuleSetParser.cachable_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token ca=null;
        Token tm=null;
        Token FOR167=null;
        RuleSetParser.period_return per = null;


        Object ca_tree=null;
        Object tm_tree=null;
        Object FOR167_tree=null;


        	retval.what = null;

        try {
            // RuleSet.g:1623:2: (ca= CACHABLE ( FOR tm= INT per= period )? )
            // RuleSet.g:1624:3: ca= CACHABLE ( FOR tm= INT per= period )?
            {
            root_0 = (Object)adaptor.nil();

            ca=(Token)match(input,CACHABLE,FOLLOW_CACHABLE_in_cachable3695); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            ca_tree = (Object)adaptor.create(ca);
            adaptor.addChild(root_0, ca_tree);
            }
            // RuleSet.g:1624:15: ( FOR tm= INT per= period )?
            int alt104=2;
            int LA104_0 = input.LA(1);

            if ( (LA104_0==FOR) ) {
                alt104=1;
            }
            switch (alt104) {
                case 1 :
                    // RuleSet.g:1624:16: FOR tm= INT per= period
                    {
                    FOR167=(Token)match(input,FOR,FOLLOW_FOR_in_cachable3698); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    FOR167_tree = (Object)adaptor.create(FOR167);
                    adaptor.addChild(root_0, FOR167_tree);
                    }
                    tm=(Token)match(input,INT,FOLLOW_INT_in_cachable3702); if (state.failed) return retval;
                    if ( state.backtracking==0 ) {
                    tm_tree = (Object)adaptor.create(tm);
                    adaptor.addChild(root_0, tm_tree);
                    }
                    pushFollow(FOLLOW_period_in_cachable3706);
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
    // RuleSet.g:1643:1: emit_block returns [String emit_value] : EMIT (h= HTML | h= STRING | h= JS ) ;
    public final RuleSetParser.emit_block_return emit_block() throws RecognitionException {
        RuleSetParser.emit_block_return retval = new RuleSetParser.emit_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token h=null;
        Token EMIT168=null;

        Object h_tree=null;
        Object EMIT168_tree=null;

        try {
            // RuleSet.g:1644:2: ( EMIT (h= HTML | h= STRING | h= JS ) )
            // RuleSet.g:1644:4: EMIT (h= HTML | h= STRING | h= JS )
            {
            root_0 = (Object)adaptor.nil();

            EMIT168=(Token)match(input,EMIT,FOLLOW_EMIT_in_emit_block3728); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            EMIT168_tree = (Object)adaptor.create(EMIT168);
            adaptor.addChild(root_0, EMIT168_tree);
            }
            // RuleSet.g:1644:9: (h= HTML | h= STRING | h= JS )
            int alt105=3;
            switch ( input.LA(1) ) {
            case HTML:
                {
                alt105=1;
                }
                break;
            case STRING:
                {
                alt105=2;
                }
                break;
            case JS:
                {
                alt105=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 105, 0, input);

                throw nvae;
            }

            switch (alt105) {
                case 1 :
                    // RuleSet.g:1644:11: h= HTML
                    {
                    h=(Token)match(input,HTML,FOLLOW_HTML_in_emit_block3734); if (state.failed) return retval;
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
                    // RuleSet.g:1645:3: h= STRING
                    {
                    h=(Token)match(input,STRING,FOLLOW_STRING_in_emit_block3742); if (state.failed) return retval;
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
                    // RuleSet.g:1646:3: h= JS
                    {
                    h=(Token)match(input,JS,FOLLOW_JS_in_emit_block3750); if (state.failed) return retval;
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
    // RuleSet.g:1649:1: meta_block : META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL ;
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
        Token META169=null;
        Token LEFT_CURL170=null;
        Token KEY171=null;
        Token LEFT_CURL172=null;
        Token COMMA174=null;
        Token RIGHT_CURL176=null;
        Token AUTHZ177=null;
        Token REQUIRE178=null;
        Token LOGGING180=null;
        Token USE181=null;
        Token MODULE183=null;
        Token ALIAS184=null;
        Token RIGHT_CURL185=null;
        RuleSetParser.must_be_one_return name = null;

        RuleSetParser.must_be_one_return what = null;

        RuleSetParser.name_value_pair_return name_value_pair173 = null;

        RuleSetParser.name_value_pair_return name_value_pair175 = null;

        RuleSetParser.must_be_return must_be179 = null;

        RuleSetParser.must_be_return must_be182 = null;


        Object html_desc_tree=null;
        Object string_desc_tree=null;
        Object key_value_tree=null;
        Object onoff_tree=null;
        Object rtype_tree=null;
        Object url_tree=null;
        Object nicename_tree=null;
        Object modname_tree=null;
        Object alias_tree=null;
        Object META169_tree=null;
        Object LEFT_CURL170_tree=null;
        Object KEY171_tree=null;
        Object LEFT_CURL172_tree=null;
        Object COMMA174_tree=null;
        Object RIGHT_CURL176_tree=null;
        Object AUTHZ177_tree=null;
        Object REQUIRE178_tree=null;
        Object LOGGING180_tree=null;
        Object USE181_tree=null;
        Object MODULE183_tree=null;
        Object ALIAS184_tree=null;
        Object RIGHT_CURL185_tree=null;


        	 HashMap meta_block_hash = (HashMap)rule_json.get("meta");
        	 ArrayList use_list = new ArrayList();
        	 HashMap keys_map = new HashMap();
        	 HashMap key_values = new HashMap();

        try {
            // RuleSet.g:1666:2: ( META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL )
            // RuleSet.g:1666:4: META LEFT_CURL (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            META169=(Token)match(input,META,FOLLOW_META_in_meta_block3779); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            META169_tree = (Object)adaptor.create(META169);
            adaptor.addChild(root_0, META169_tree);
            }
            LEFT_CURL170=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_meta_block3781); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL170_tree = (Object)adaptor.create(LEFT_CURL170);
            adaptor.addChild(root_0, LEFT_CURL170_tree);
            }
            // RuleSet.g:1667:2: (name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING ) | KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+ | AUTHZ REQUIRE must_be[\"user\"] | LOGGING onoff= ( ON | OFF ) | USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) ) )*
            loop112:
            do {
                int alt112=6;
                switch ( input.LA(1) ) {
                case VAR:
                    {
                    alt112=1;
                    }
                    break;
                case KEY:
                    {
                    alt112=2;
                    }
                    break;
                case AUTHZ:
                    {
                    alt112=3;
                    }
                    break;
                case LOGGING:
                    {
                    alt112=4;
                    }
                    break;
                case USE:
                    {
                    alt112=5;
                    }
                    break;

                }

                switch (alt112) {
            	case 1 :
            	    // RuleSet.g:1667:5: name= must_be_one[sar(\"description\",\"name\",\"author\")] (html_desc= HTML | string_desc= STRING )
            	    {
            	    pushFollow(FOLLOW_must_be_one_in_meta_block3790);
            	    name=must_be_one(sar("description","name","author"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name.getTree());
            	    // RuleSet.g:1667:58: (html_desc= HTML | string_desc= STRING )
            	    int alt106=2;
            	    int LA106_0 = input.LA(1);

            	    if ( (LA106_0==HTML) ) {
            	        alt106=1;
            	    }
            	    else if ( (LA106_0==STRING) ) {
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
            	            // RuleSet.g:1667:59: html_desc= HTML
            	            {
            	            html_desc=(Token)match(input,HTML,FOLLOW_HTML_in_meta_block3796); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            html_desc_tree = (Object)adaptor.create(html_desc);
            	            adaptor.addChild(root_0, html_desc_tree);
            	            }

            	            }
            	            break;
            	        case 2 :
            	            // RuleSet.g:1667:74: string_desc= STRING
            	            {
            	            string_desc=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3800); if (state.failed) return retval;
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
            	    // RuleSet.g:1677:5: KEY what= must_be_one[sar(\"errorstack\",\"googleanalytics\",\"facebook\",\"twitter\",\"amazon\",\"kpds\",\"google\")] (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+
            	    {
            	    KEY171=(Token)match(input,KEY,FOLLOW_KEY_in_meta_block3814); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    KEY171_tree = (Object)adaptor.create(KEY171);
            	    adaptor.addChild(root_0, KEY171_tree);
            	    }
            	    pushFollow(FOLLOW_must_be_one_in_meta_block3818);
            	    what=must_be_one(sar("errorstack","googleanalytics","facebook","twitter","amazon","kpds","google"));

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, what.getTree());
            	    // RuleSet.g:1677:109: (key_value= STRING | LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL )+
            	    int cnt108=0;
            	    loop108:
            	    do {
            	        int alt108=3;
            	        int LA108_0 = input.LA(1);

            	        if ( (LA108_0==STRING) ) {
            	            alt108=1;
            	        }
            	        else if ( (LA108_0==LEFT_CURL) ) {
            	            alt108=2;
            	        }


            	        switch (alt108) {
            	    	case 1 :
            	    	    // RuleSet.g:1677:110: key_value= STRING
            	    	    {
            	    	    key_value=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3824); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    key_value_tree = (Object)adaptor.create(key_value);
            	    	    adaptor.addChild(root_0, key_value_tree);
            	    	    }

            	    	    }
            	    	    break;
            	    	case 2 :
            	    	    // RuleSet.g:1678:6: LEFT_CURL ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* ) RIGHT_CURL
            	    	    {
            	    	    LEFT_CURL172=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_meta_block3832); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    LEFT_CURL172_tree = (Object)adaptor.create(LEFT_CURL172);
            	    	    adaptor.addChild(root_0, LEFT_CURL172_tree);
            	    	    }
            	    	    // RuleSet.g:1678:16: ( name_value_pair[key_values] ( COMMA name_value_pair[key_values] )* )
            	    	    // RuleSet.g:1678:17: name_value_pair[key_values] ( COMMA name_value_pair[key_values] )*
            	    	    {
            	    	    pushFollow(FOLLOW_name_value_pair_in_meta_block3835);
            	    	    name_value_pair173=name_value_pair(key_values);

            	    	    state._fsp--;
            	    	    if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name_value_pair173.getTree());
            	    	    // RuleSet.g:1678:45: ( COMMA name_value_pair[key_values] )*
            	    	    loop107:
            	    	    do {
            	    	        int alt107=2;
            	    	        int LA107_0 = input.LA(1);

            	    	        if ( (LA107_0==COMMA) ) {
            	    	            alt107=1;
            	    	        }


            	    	        switch (alt107) {
            	    	    	case 1 :
            	    	    	    // RuleSet.g:1678:46: COMMA name_value_pair[key_values]
            	    	    	    {
            	    	    	    COMMA174=(Token)match(input,COMMA,FOLLOW_COMMA_in_meta_block3839); if (state.failed) return retval;
            	    	    	    if ( state.backtracking==0 ) {
            	    	    	    COMMA174_tree = (Object)adaptor.create(COMMA174);
            	    	    	    adaptor.addChild(root_0, COMMA174_tree);
            	    	    	    }
            	    	    	    pushFollow(FOLLOW_name_value_pair_in_meta_block3841);
            	    	    	    name_value_pair175=name_value_pair(key_values);

            	    	    	    state._fsp--;
            	    	    	    if (state.failed) return retval;
            	    	    	    if ( state.backtracking==0 ) adaptor.addChild(root_0, name_value_pair175.getTree());

            	    	    	    }
            	    	    	    break;

            	    	    	default :
            	    	    	    break loop107;
            	    	        }
            	    	    } while (true);


            	    	    }

            	    	    RIGHT_CURL176=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_meta_block3847); if (state.failed) return retval;
            	    	    if ( state.backtracking==0 ) {
            	    	    RIGHT_CURL176_tree = (Object)adaptor.create(RIGHT_CURL176);
            	    	    adaptor.addChild(root_0, RIGHT_CURL176_tree);
            	    	    }

            	    	    }
            	    	    break;

            	    	default :
            	    	    if ( cnt108 >= 1 ) break loop108;
            	    	    if (state.backtracking>0) {state.failed=true; return retval;}
            	                EarlyExitException eee =
            	                    new EarlyExitException(108, input);
            	                throw eee;
            	        }
            	        cnt108++;
            	    } while (true);

            	    if ( state.backtracking==0 ) {
            	       
            	      		if(!key_values.isEmpty()) 
            	      			keys_map.put((what!=null?input.toString(what.start,what.stop):null),key_values); 
            	      		else 
            	      			keys_map.put((what!=null?input.toString(what.start,what.stop):null),strip_string((key_value!=null?key_value.getText():null)));
            	              key_values = new HashMap();
            	      	
            	    }

            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:1685:4: AUTHZ REQUIRE must_be[\"user\"]
            	    {
            	    AUTHZ177=(Token)match(input,AUTHZ,FOLLOW_AUTHZ_in_meta_block3859); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    AUTHZ177_tree = (Object)adaptor.create(AUTHZ177);
            	    adaptor.addChild(root_0, AUTHZ177_tree);
            	    }
            	    REQUIRE178=(Token)match(input,REQUIRE,FOLLOW_REQUIRE_in_meta_block3861); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    REQUIRE178_tree = (Object)adaptor.create(REQUIRE178);
            	    adaptor.addChild(root_0, REQUIRE178_tree);
            	    }
            	    pushFollow(FOLLOW_must_be_in_meta_block3863);
            	    must_be179=must_be("user");

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be179.getTree());
            	    if ( state.backtracking==0 ) {
            	        
            	      		HashMap tmp = new HashMap(); 
            	      		tmp.put("level","user");
            	      		tmp.put("type","require");
            	      		meta_block_hash.put("authz",tmp);
            	      	   
            	    }

            	    }
            	    break;
            	case 4 :
            	    // RuleSet.g:1691:4: LOGGING onoff= ( ON | OFF )
            	    {
            	    LOGGING180=(Token)match(input,LOGGING,FOLLOW_LOGGING_in_meta_block3872); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    LOGGING180_tree = (Object)adaptor.create(LOGGING180);
            	    adaptor.addChild(root_0, LOGGING180_tree);
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
            	    // RuleSet.g:1692:4: USE ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) )
            	    {
            	    USE181=(Token)match(input,USE,FOLLOW_USE_in_meta_block3887); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    USE181_tree = (Object)adaptor.create(USE181);
            	    adaptor.addChild(root_0, USE181_tree);
            	    }
            	    // RuleSet.g:1692:8: ( (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) ) | ( MODULE modname= VAR ( ALIAS alias= VAR )? ) )
            	    int alt111=2;
            	    int LA111_0 = input.LA(1);

            	    if ( (LA111_0==CSS||LA111_0==JAVASCRIPT) ) {
            	        alt111=1;
            	    }
            	    else if ( (LA111_0==MODULE) ) {
            	        alt111=2;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return retval;}
            	        NoViableAltException nvae =
            	            new NoViableAltException("", 111, 0, input);

            	        throw nvae;
            	    }
            	    switch (alt111) {
            	        case 1 :
            	            // RuleSet.g:1692:10: (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) )
            	            {
            	            // RuleSet.g:1692:10: (rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR ) )
            	            // RuleSet.g:1692:11: rtype= ( CSS | JAVASCRIPT ) must_be[\"resource\"] (url= STRING | nicename= VAR )
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

            	            pushFollow(FOLLOW_must_be_in_meta_block3900);
            	            must_be182=must_be("resource");

            	            state._fsp--;
            	            if (state.failed) return retval;
            	            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be182.getTree());
            	            // RuleSet.g:1692:54: (url= STRING | nicename= VAR )
            	            int alt109=2;
            	            int LA109_0 = input.LA(1);

            	            if ( (LA109_0==STRING) ) {
            	                alt109=1;
            	            }
            	            else if ( (LA109_0==VAR) ) {
            	                alt109=2;
            	            }
            	            else {
            	                if (state.backtracking>0) {state.failed=true; return retval;}
            	                NoViableAltException nvae =
            	                    new NoViableAltException("", 109, 0, input);

            	                throw nvae;
            	            }
            	            switch (alt109) {
            	                case 1 :
            	                    // RuleSet.g:1692:55: url= STRING
            	                    {
            	                    url=(Token)match(input,STRING,FOLLOW_STRING_in_meta_block3906); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    url_tree = (Object)adaptor.create(url);
            	                    adaptor.addChild(root_0, url_tree);
            	                    }

            	                    }
            	                    break;
            	                case 2 :
            	                    // RuleSet.g:1692:68: nicename= VAR
            	                    {
            	                    nicename=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3912); if (state.failed) return retval;
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
            	              		
            	              		tmp.put("type","resource");
            	              		tmp.put("resource_type",(rtype!=null?rtype.getText():null));
            	              		use_list.add(tmp);
            	              	 
            	            }

            	            }


            	            }
            	            break;
            	        case 2 :
            	            // RuleSet.g:1711:6: ( MODULE modname= VAR ( ALIAS alias= VAR )? )
            	            {
            	            // RuleSet.g:1711:6: ( MODULE modname= VAR ( ALIAS alias= VAR )? )
            	            // RuleSet.g:1711:7: MODULE modname= VAR ( ALIAS alias= VAR )?
            	            {
            	            MODULE183=(Token)match(input,MODULE,FOLLOW_MODULE_in_meta_block3927); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            MODULE183_tree = (Object)adaptor.create(MODULE183);
            	            adaptor.addChild(root_0, MODULE183_tree);
            	            }
            	            modname=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3932); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            modname_tree = (Object)adaptor.create(modname);
            	            adaptor.addChild(root_0, modname_tree);
            	            }
            	            // RuleSet.g:1711:27: ( ALIAS alias= VAR )?
            	            int alt110=2;
            	            int LA110_0 = input.LA(1);

            	            if ( (LA110_0==ALIAS) ) {
            	                alt110=1;
            	            }
            	            switch (alt110) {
            	                case 1 :
            	                    // RuleSet.g:1711:28: ALIAS alias= VAR
            	                    {
            	                    ALIAS184=(Token)match(input,ALIAS,FOLLOW_ALIAS_in_meta_block3935); if (state.failed) return retval;
            	                    if ( state.backtracking==0 ) {
            	                    ALIAS184_tree = (Object)adaptor.create(ALIAS184);
            	                    adaptor.addChild(root_0, ALIAS184_tree);
            	                    }
            	                    alias=(Token)match(input,VAR,FOLLOW_VAR_in_meta_block3939); if (state.failed) return retval;
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
            	              //		if((alias!=null?alias.getText():null) != null) {
            	              			tmp.put("alias",(alias!=null?alias.getText():null));
            	              			alias = null;
            	              //		}
            	              		use_list.add(tmp);
            	              	 
            	            }

            	            }
            	            break;

            	    }


            	    }
            	    break;

            	default :
            	    break loop112;
                }
            } while (true);

            RIGHT_CURL185=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_meta_block3954); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL185_tree = (Object)adaptor.create(RIGHT_CURL185);
            adaptor.addChild(root_0, RIGHT_CURL185_tree);
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
    // RuleSet.g:1726:1: dispatch_block : must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL ;
    public final RuleSetParser.dispatch_block_return dispatch_block() throws RecognitionException {
        RuleSetParser.dispatch_block_return retval = new RuleSetParser.dispatch_block_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token domain=null;
        Token rsid=null;
        Token LEFT_CURL187=null;
        Token RIGHT_SMALL_ARROW189=null;
        Token RIGHT_CURL190=null;
        RuleSetParser.must_be_return must_be186 = null;

        RuleSetParser.must_be_return must_be188 = null;


        Object domain_tree=null;
        Object rsid_tree=null;
        Object LEFT_CURL187_tree=null;
        Object RIGHT_SMALL_ARROW189_tree=null;
        Object RIGHT_CURL190_tree=null;


        	 ArrayList dispatch_block_array = (ArrayList)rule_json.get("dispatch");

        try {
            // RuleSet.g:1732:2: ( must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL )
            // RuleSet.g:1732:4: must_be[\"dispatch\"] LEFT_CURL ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )* RIGHT_CURL
            {
            root_0 = (Object)adaptor.nil();

            pushFollow(FOLLOW_must_be_in_dispatch_block3985);
            must_be186=must_be("dispatch");

            state._fsp--;
            if (state.failed) return retval;
            if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be186.getTree());
            LEFT_CURL187=(Token)match(input,LEFT_CURL,FOLLOW_LEFT_CURL_in_dispatch_block3989); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            LEFT_CURL187_tree = (Object)adaptor.create(LEFT_CURL187);
            adaptor.addChild(root_0, LEFT_CURL187_tree);
            }
            // RuleSet.g:1732:35: ( must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )? )*
            loop114:
            do {
                int alt114=2;
                int LA114_0 = input.LA(1);

                if ( (LA114_0==VAR) ) {
                    alt114=1;
                }


                switch (alt114) {
            	case 1 :
            	    // RuleSet.g:1732:37: must_be[\"domain\"] domain= STRING ( RIGHT_SMALL_ARROW rsid= STRING )?
            	    {
            	    pushFollow(FOLLOW_must_be_in_dispatch_block3993);
            	    must_be188=must_be("domain");

            	    state._fsp--;
            	    if (state.failed) return retval;
            	    if ( state.backtracking==0 ) adaptor.addChild(root_0, must_be188.getTree());
            	    domain=(Token)match(input,STRING,FOLLOW_STRING_in_dispatch_block3998); if (state.failed) return retval;
            	    if ( state.backtracking==0 ) {
            	    domain_tree = (Object)adaptor.create(domain);
            	    adaptor.addChild(root_0, domain_tree);
            	    }
            	    // RuleSet.g:1732:69: ( RIGHT_SMALL_ARROW rsid= STRING )?
            	    int alt113=2;
            	    int LA113_0 = input.LA(1);

            	    if ( (LA113_0==RIGHT_SMALL_ARROW) ) {
            	        alt113=1;
            	    }
            	    switch (alt113) {
            	        case 1 :
            	            // RuleSet.g:1732:70: RIGHT_SMALL_ARROW rsid= STRING
            	            {
            	            RIGHT_SMALL_ARROW189=(Token)match(input,RIGHT_SMALL_ARROW,FOLLOW_RIGHT_SMALL_ARROW_in_dispatch_block4001); if (state.failed) return retval;
            	            if ( state.backtracking==0 ) {
            	            RIGHT_SMALL_ARROW189_tree = (Object)adaptor.create(RIGHT_SMALL_ARROW189);
            	            adaptor.addChild(root_0, RIGHT_SMALL_ARROW189_tree);
            	            }
            	            rsid=(Token)match(input,STRING,FOLLOW_STRING_in_dispatch_block4005); if (state.failed) return retval;
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
            	      			rsid = null;
            	      			
            	      		}
            	      		else
            	      		{
            	      			tmp.put("ruleset_id",null);
            	      			rsid = null;


            	      		}
            	      		dispatch_block_array.add(tmp);
            	      		
            	    }

            	    }
            	    break;

            	default :
            	    break loop114;
                }
            } while (true);

            RIGHT_CURL190=(Token)match(input,RIGHT_CURL,FOLLOW_RIGHT_CURL_in_dispatch_block4016); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            RIGHT_CURL190_tree = (Object)adaptor.create(RIGHT_CURL190);
            adaptor.addChild(root_0, RIGHT_CURL190_tree);
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
    // RuleSet.g:1755:1: name_value_pair[HashMap key_values] : k= STRING COLON (v= INT | v= FLOAT | v= STRING ) ;
    public final RuleSetParser.name_value_pair_return name_value_pair(HashMap key_values) throws RecognitionException {
        RuleSetParser.name_value_pair_return retval = new RuleSetParser.name_value_pair_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token k=null;
        Token v=null;
        Token COLON191=null;

        Object k_tree=null;
        Object v_tree=null;
        Object COLON191_tree=null;


        	Object value = null;

        try {
            // RuleSet.g:1759:2: (k= STRING COLON (v= INT | v= FLOAT | v= STRING ) )
            // RuleSet.g:1759:4: k= STRING COLON (v= INT | v= FLOAT | v= STRING )
            {
            root_0 = (Object)adaptor.nil();

            k=(Token)match(input,STRING,FOLLOW_STRING_in_name_value_pair4039); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            k_tree = (Object)adaptor.create(k);
            adaptor.addChild(root_0, k_tree);
            }
            COLON191=(Token)match(input,COLON,FOLLOW_COLON_in_name_value_pair4041); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            COLON191_tree = (Object)adaptor.create(COLON191);
            adaptor.addChild(root_0, COLON191_tree);
            }
            // RuleSet.g:1759:19: (v= INT | v= FLOAT | v= STRING )
            int alt115=3;
            switch ( input.LA(1) ) {
            case INT:
                {
                alt115=1;
                }
                break;
            case FLOAT:
                {
                alt115=2;
                }
                break;
            case STRING:
                {
                alt115=3;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return retval;}
                NoViableAltException nvae =
                    new NoViableAltException("", 115, 0, input);

                throw nvae;
            }

            switch (alt115) {
                case 1 :
                    // RuleSet.g:1760:3: v= INT
                    {
                    v=(Token)match(input,INT,FOLLOW_INT_in_name_value_pair4049); if (state.failed) return retval;
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
                    // RuleSet.g:1761:5: v= FLOAT
                    {
                    v=(Token)match(input,FLOAT,FOLLOW_FLOAT_in_name_value_pair4060); if (state.failed) return retval;
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
                    // RuleSet.g:1762:5: v= STRING
                    {
                    v=(Token)match(input,STRING,FOLLOW_STRING_in_name_value_pair4071); if (state.failed) return retval;
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
    // RuleSet.g:1772:1: regex returns [HashMap result] : rx= REX ;
    public final RuleSetParser.regex_return regex() throws RecognitionException {
        RuleSetParser.regex_return retval = new RuleSetParser.regex_return();
        retval.start = input.LT(1);

        Object root_0 = null;

        Token rx=null;

        Object rx_tree=null;

           


        try {
            // RuleSet.g:1776:6: (rx= REX )
            // RuleSet.g:1777:8: rx= REX
            {
            root_0 = (Object)adaptor.nil();

            rx=(Token)match(input,REX,FOLLOW_REX_in_regex4117); if (state.failed) return retval;
            if ( state.backtracking==0 ) {
            rx_tree = (Object)adaptor.create(rx);
            adaptor.addChild(root_0, rx_tree);
            }
            if ( state.backtracking==0 ) {

                          HashMap tmp = new HashMap();
                          tmp.put("type","regexp");
                          if((rx!=null?rx.getText():null).charAt(0) == '#')
                          {
                              tmp.put("val",(rx!=null?rx.getText():null));                
                          }
                          else
                          {
                              tmp.put("val",(rx!=null?rx.getText():null).substring(2,(rx!=null?rx.getText():null).length()));
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
    // $ANTLR end "regex"

    // $ANTLR start synpred14_RuleSet
    public final void synpred14_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:308:20: ( SEMI )
        // RuleSet.g:308:20: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred14_RuleSet335); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred14_RuleSet

    // $ANTLR start synpred15_RuleSet
    public final void synpred15_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.emit_block_return eb = null;


        // RuleSet.g:308:28: (eb= emit_block )
        // RuleSet.g:308:28: eb= emit_block
        {
        pushFollow(FOLLOW_emit_block_in_synpred15_RuleSet340);
        eb=emit_block();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred15_RuleSet

    // $ANTLR start synpred16_RuleSet
    public final void synpred16_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:308:41: ( SEMI )
        // RuleSet.g:308:41: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred16_RuleSet343); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred16_RuleSet

    // $ANTLR start synpred17_RuleSet
    public final void synpred17_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:308:71: ( SEMI )
        // RuleSet.g:308:71: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred17_RuleSet350); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred17_RuleSet

    // $ANTLR start synpred20_RuleSet
    public final void synpred20_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:308:93: ( SEMI )
        // RuleSet.g:308:93: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred20_RuleSet360); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred20_RuleSet

    // $ANTLR start synpred29_RuleSet
    public final void synpred29_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.persistent_expr_return pe = null;


        // RuleSet.g:392:6: (pe= persistent_expr )
        // RuleSet.g:392:6: pe= persistent_expr
        {
        pushFollow(FOLLOW_persistent_expr_in_synpred29_RuleSet513);
        pe=persistent_expr();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred29_RuleSet

    // $ANTLR start synpred31_RuleSet
    public final void synpred31_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.log_statement_return l = null;


        // RuleSet.g:394:4: (l= log_statement )
        // RuleSet.g:394:4: l= log_statement
        {
        pushFollow(FOLLOW_log_statement_in_synpred31_RuleSet530);
        l=log_statement();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred31_RuleSet

    // $ANTLR start synpred47_RuleSet
    public final void synpred47_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:626:62: ( SEMI )
        // RuleSet.g:626:62: SEMI
        {
        match(input,SEMI,FOLLOW_SEMI_in_synpred47_RuleSet1135); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred47_RuleSet

    // $ANTLR start synpred54_RuleSet
    public final void synpred54_RuleSet_fragment() throws RecognitionException {   
        Token label=null;

        // RuleSet.g:667:6: (label= VAR ARROW_RIGHT )
        // RuleSet.g:667:6: label= VAR ARROW_RIGHT
        {
        label=(Token)match(input,VAR,FOLLOW_VAR_in_synpred54_RuleSet1287); if (state.failed) return ;
        match(input,ARROW_RIGHT,FOLLOW_ARROW_RIGHT_in_synpred54_RuleSet1289); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred54_RuleSet

    // $ANTLR start synpred83_RuleSet
    public final void synpred83_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.must_be_one_return tb = null;

        RuleSetParser.event_or_return eor2 = null;


        // RuleSet.g:812:17: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )
        // RuleSet.g:812:17: tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or
        {
        pushFollow(FOLLOW_must_be_one_in_synpred83_RuleSet1701);
        tb=must_be_one(sar("then","before"));

        state._fsp--;
        if (state.failed) return ;
        pushFollow(FOLLOW_event_or_in_synpred83_RuleSet1706);
        eor2=event_or();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred83_RuleSet

    // $ANTLR start synpred88_RuleSet
    public final void synpred88_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:979:2: ( custom_event )
        // RuleSet.g:979:3: custom_event
        {
        pushFollow(FOLLOW_custom_event_in_synpred88_RuleSet1873);
        custom_event();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred88_RuleSet

    // $ANTLR start synpred137_RuleSet
    public final void synpred137_RuleSet_fragment() throws RecognitionException {   
        Token op=null;
        RuleSetParser.add_expr_return me2 = null;


        // RuleSet.g:1230:18: (op= ( PREDOP | LIKE ) me2= add_expr )
        // RuleSet.g:1230:18: op= ( PREDOP | LIKE ) me2= add_expr
        {
        op=(Token)input.LT(1);
        if ( input.LA(1)==LIKE||input.LA(1)==PREDOP ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        pushFollow(FOLLOW_add_expr_in_synpred137_RuleSet2511);
        me2=add_expr();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred137_RuleSet

    // $ANTLR start synpred140_RuleSet
    public final void synpred140_RuleSet_fragment() throws RecognitionException {   
        Token op=null;
        RuleSetParser.mult_expr_return me2 = null;


        // RuleSet.g:1277:20: (op= ( ADD_OP | REX ) me2= mult_expr )
        // RuleSet.g:1277:20: op= ( ADD_OP | REX ) me2= mult_expr
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

        pushFollow(FOLLOW_mult_expr_in_synpred140_RuleSet2619);
        me2=mult_expr();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred140_RuleSet

    // $ANTLR start synpred147_RuleSet
    public final void synpred147_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1309:106: (t= timeframe )
        // RuleSet.g:1309:106: t= timeframe
        {
        pushFollow(FOLLOW_timeframe_in_synpred147_RuleSet2709);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred147_RuleSet

    // $ANTLR start synpred148_RuleSet
    public final void synpred148_RuleSet_fragment() throws RecognitionException {   
        Token rx=null;
        Token vd=null;
        Token v=null;
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1309:4: ( SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )? )
        // RuleSet.g:1309:4: SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )?
        {
        match(input,SEEN,FOLLOW_SEEN_in_synpred148_RuleSet2676); if (state.failed) return ;
        rx=(Token)match(input,STRING,FOLLOW_STRING_in_synpred148_RuleSet2680); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_in_synpred148_RuleSet2682);
        must_be("in");

        state._fsp--;
        if (state.failed) return ;
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred148_RuleSet2687); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred148_RuleSet2689); if (state.failed) return ;
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        // RuleSet.g:1309:106: (t= timeframe )?
        int alt136=2;
        int LA136_0 = input.LA(1);

        if ( (LA136_0==WITHIN) ) {
            alt136=1;
        }
        switch (alt136) {
            case 1 :
                // RuleSet.g:0:0: t= timeframe
                {
                pushFollow(FOLLOW_timeframe_in_synpred148_RuleSet2709);
                t=timeframe();

                state._fsp--;
                if (state.failed) return ;

                }
                break;

        }


        }
    }
    // $ANTLR end synpred148_RuleSet

    // $ANTLR start synpred154_RuleSet
    public final void synpred154_RuleSet_fragment() throws RecognitionException {   
        Token rx_1=null;
        Token rx_2=null;
        Token vd=null;
        Token v=null;
        RuleSetParser.must_be_one_return op = null;


        // RuleSet.g:1323:4: ( SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )
        // RuleSet.g:1323:4: SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
        {
        match(input,SEEN,FOLLOW_SEEN_in_synpred154_RuleSet2717); if (state.failed) return ;
        rx_1=(Token)match(input,STRING,FOLLOW_STRING_in_synpred154_RuleSet2721); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_one_in_synpred154_RuleSet2725);
        op=must_be_one(sar("before","after"));

        state._fsp--;
        if (state.failed) return ;
        rx_2=(Token)match(input,STRING,FOLLOW_STRING_in_synpred154_RuleSet2730); if (state.failed) return ;
        pushFollow(FOLLOW_must_be_in_synpred154_RuleSet2733);
        must_be("in");

        state._fsp--;
        if (state.failed) return ;
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred154_RuleSet2738); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred154_RuleSet2740); if (state.failed) return ;
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
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
    // $ANTLR end synpred154_RuleSet

    // $ANTLR start synpred161_RuleSet
    public final void synpred161_RuleSet_fragment() throws RecognitionException {   
        Token vd=null;
        Token v=null;
        Token pop=null;
        RuleSetParser.expr_return e = null;

        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1333:4: (vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe )
        // RuleSet.g:1333:4: vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe
        {
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred161_RuleSet2765); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred161_RuleSet2767); if (state.failed) return ;
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        pop=(Token)input.LT(1);
        if ( input.LA(1)==LIKE||input.LA(1)==PREDOP ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        pushFollow(FOLLOW_expr_in_synpred161_RuleSet2795);
        e=expr();

        state._fsp--;
        if (state.failed) return ;
        pushFollow(FOLLOW_timeframe_in_synpred161_RuleSet2799);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred161_RuleSet

    // $ANTLR start synpred167_RuleSet
    public final void synpred167_RuleSet_fragment() throws RecognitionException {   
        Token vd=null;
        Token v=null;
        RuleSetParser.timeframe_return t = null;


        // RuleSet.g:1345:4: (vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe )
        // RuleSet.g:1345:4: vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe
        {
        vd=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred167_RuleSet2809); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred167_RuleSet2811); if (state.failed) return ;
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        pushFollow(FOLLOW_timeframe_in_synpred167_RuleSet2831);
        t=timeframe();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred167_RuleSet

    // $ANTLR start synpred168_RuleSet
    public final void synpred168_RuleSet_fragment() throws RecognitionException {   
        RuleSetParser.regex_return roe = null;


        // RuleSet.g:1360:4: (roe= regex )
        // RuleSet.g:1360:4: roe= regex
        {
        pushFollow(FOLLOW_regex_in_synpred168_RuleSet2840);
        roe=regex();

        state._fsp--;
        if (state.failed) return ;

        }
    }
    // $ANTLR end synpred168_RuleSet

    // $ANTLR start synpred184_RuleSet
    public final void synpred184_RuleSet_fragment() throws RecognitionException {   
        Token bv=null;
        RuleSetParser.expr_return e = null;


        // RuleSet.g:1469:9: (bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET )
        // RuleSet.g:1469:9: bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET
        {
        bv=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        match(input,LEFT_BRACKET,FOLLOW_LEFT_BRACKET_in_synpred184_RuleSet3148); if (state.failed) return ;
        pushFollow(FOLLOW_expr_in_synpred184_RuleSet3152);
        e=expr();

        state._fsp--;
        if (state.failed) return ;
        match(input,RIGHT_BRACKET,FOLLOW_RIGHT_BRACKET_in_synpred184_RuleSet3154); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred184_RuleSet

    // $ANTLR start synpred190_RuleSet
    public final void synpred190_RuleSet_fragment() throws RecognitionException {   
        Token d=null;
        Token vv=null;

        // RuleSet.g:1483:9: (d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) )
        // RuleSet.g:1483:9: d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN )
        {
        d=(Token)match(input,VAR_DOMAIN,FOLLOW_VAR_DOMAIN_in_synpred190_RuleSet3169); if (state.failed) return ;
        match(input,COLON,FOLLOW_COLON_in_synpred190_RuleSet3171); if (state.failed) return ;
        vv=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
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
    // $ANTLR end synpred190_RuleSet

    // $ANTLR start synpred210_RuleSet
    public final void synpred210_RuleSet_fragment() throws RecognitionException {   
        Token p=null;
        RuleSetParser.namespace_return n = null;

        RuleSetParser.expr_return e = null;


        // RuleSet.g:1511:9: (n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN )
        // RuleSet.g:1511:9: n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
        {
        pushFollow(FOLLOW_namespace_in_synpred210_RuleSet3274);
        n=namespace();

        state._fsp--;
        if (state.failed) return ;
        p=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_synpred210_RuleSet3292); if (state.failed) return ;
        // RuleSet.g:1511:86: (e= expr ( COMMA e= expr )* )?
        int alt142=2;
        int LA142_0 = input.LA(1);

        if ( (LA142_0==LEFT_CURL||(LA142_0>=VAR && LA142_0<=MATCH)||(LA142_0>=STRING && LA142_0<=VAR_DOMAIN)||LA142_0==LEFT_PAREN||LA142_0==NOT||LA142_0==FUNCTION||(LA142_0>=REX && LA142_0<=SEEN)||(LA142_0>=FLOAT && LA142_0<=LEFT_BRACKET)||(LA142_0>=CURRENT && LA142_0<=HISTORY)) ) {
            alt142=1;
        }
        switch (alt142) {
            case 1 :
                // RuleSet.g:1511:87: e= expr ( COMMA e= expr )*
                {
                pushFollow(FOLLOW_expr_in_synpred210_RuleSet3297);
                e=expr();

                state._fsp--;
                if (state.failed) return ;
                // RuleSet.g:1511:121: ( COMMA e= expr )*
                loop141:
                do {
                    int alt141=2;
                    int LA141_0 = input.LA(1);

                    if ( (LA141_0==COMMA) ) {
                        alt141=1;
                    }


                    switch (alt141) {
                	case 1 :
                	    // RuleSet.g:1511:123: COMMA e= expr
                	    {
                	    match(input,COMMA,FOLLOW_COMMA_in_synpred210_RuleSet3303); if (state.failed) return ;
                	    pushFollow(FOLLOW_expr_in_synpred210_RuleSet3307);
                	    e=expr();

                	    state._fsp--;
                	    if (state.failed) return ;

                	    }
                	    break;

                	default :
                	    break loop141;
                    }
                } while (true);


                }
                break;

        }

        match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_synpred210_RuleSet3316); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred210_RuleSet

    // $ANTLR start synpred218_RuleSet
    public final void synpred218_RuleSet_fragment() throws RecognitionException {   
        Token v=null;
        RuleSetParser.expr_return e = null;


        // RuleSet.g:1519:9: (v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN )
        // RuleSet.g:1519:9: v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN
        {
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||(input.LA(1)>=OTHER_OPERATORS && input.LA(1)<=MATCH)||input.LA(1)==VAR_DOMAIN ) {
            input.consume();
            state.errorRecovery=false;state.failed=false;
        }
        else {
            if (state.backtracking>0) {state.failed=true; return ;}
            MismatchedSetException mse = new MismatchedSetException(null,input);
            throw mse;
        }

        match(input,LEFT_PAREN,FOLLOW_LEFT_PAREN_in_synpred218_RuleSet3345); if (state.failed) return ;
        // RuleSet.g:1519:74: (e= expr ( COMMA e= expr )* )?
        int alt145=2;
        int LA145_0 = input.LA(1);

        if ( (LA145_0==LEFT_CURL||(LA145_0>=VAR && LA145_0<=MATCH)||(LA145_0>=STRING && LA145_0<=VAR_DOMAIN)||LA145_0==LEFT_PAREN||LA145_0==NOT||LA145_0==FUNCTION||(LA145_0>=REX && LA145_0<=SEEN)||(LA145_0>=FLOAT && LA145_0<=LEFT_BRACKET)||(LA145_0>=CURRENT && LA145_0<=HISTORY)) ) {
            alt145=1;
        }
        switch (alt145) {
            case 1 :
                // RuleSet.g:1519:75: e= expr ( COMMA e= expr )*
                {
                pushFollow(FOLLOW_expr_in_synpred218_RuleSet3350);
                e=expr();

                state._fsp--;
                if (state.failed) return ;
                // RuleSet.g:1519:109: ( COMMA e= expr )*
                loop144:
                do {
                    int alt144=2;
                    int LA144_0 = input.LA(1);

                    if ( (LA144_0==COMMA) ) {
                        alt144=1;
                    }


                    switch (alt144) {
                	case 1 :
                	    // RuleSet.g:1519:111: COMMA e= expr
                	    {
                	    match(input,COMMA,FOLLOW_COMMA_in_synpred218_RuleSet3355); if (state.failed) return ;
                	    pushFollow(FOLLOW_expr_in_synpred218_RuleSet3359);
                	    e=expr();

                	    state._fsp--;
                	    if (state.failed) return ;

                	    }
                	    break;

                	default :
                	    break loop144;
                    }
                } while (true);


                }
                break;

        }

        match(input,RIGHT_PAREN,FOLLOW_RIGHT_PAREN_in_synpred218_RuleSet3368); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred218_RuleSet

    // $ANTLR start synpred229_RuleSet
    public final void synpred229_RuleSet_fragment() throws RecognitionException {   
        Token v=null;

        // RuleSet.g:1545:9: (v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) )
        // RuleSet.g:1545:9: v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH )
        {
        v=(Token)input.LT(1);
        if ( input.LA(1)==VAR||input.LA(1)==OTHER_OPERATORS||(input.LA(1)>=REPLACE && input.LA(1)<=MATCH) ) {
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
    // $ANTLR end synpred229_RuleSet

    // Delegated rules

    public final boolean synpred47_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred47_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred88_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred88_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred137_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred137_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred29_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred29_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred83_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred83_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred154_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred154_RuleSet_fragment(); // can never throw exception
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
    public final boolean synpred210_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred210_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred54_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred54_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred168_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred168_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred31_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred31_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred229_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred229_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred14_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred14_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred147_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred147_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred184_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred184_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred218_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred218_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred161_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred161_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred20_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred20_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred190_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred190_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred15_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred15_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred17_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred17_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred140_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred140_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred167_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred167_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }
    public final boolean synpred148_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred148_RuleSet_fragment(); // can never throw exception
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
    protected DFA57 dfa57 = new DFA57(this);
    protected DFA68 dfa68 = new DFA68(this);
    protected DFA85 dfa85 = new DFA85(this);
    protected DFA87 dfa87 = new DFA87(this);
    protected DFA89 dfa89 = new DFA89(this);
    protected DFA88 dfa88 = new DFA88(this);
    protected DFA102 dfa102 = new DFA102(this);
    static final String DFA20_eotS =
        "\12\uffff";
    static final String DFA20_eofS =
        "\1\uffff\1\4\4\uffff\1\5\3\uffff";
    static final String DFA20_minS =
        "\1\7\1\5\1\uffff\1\25\2\uffff\1\6\1\7\1\uffff\1\0";
    static final String DFA20_maxS =
        "\1\30\1\102\1\uffff\1\77\2\uffff\1\77\1\24\1\uffff\1\0";
    static final String DFA20_acceptS =
        "\2\uffff\1\1\1\uffff\1\4\1\3\2\uffff\1\2\1\uffff";
    static final String DFA20_specialS =
        "\11\uffff\1\0}>";
    static final String[] DFA20_transitionS = {
            "\1\1\14\uffff\1\2\2\uffff\2\2",
            "\1\5\1\4\1\6\5\5\2\4\4\uffff\1\5\1\3\11\uffff\1\5\12\uffff"+
            "\1\5\10\uffff\1\5\6\uffff\2\5\1\uffff\4\5\1\uffff\2\5",
            "",
            "\1\7\10\uffff\1\5\40\uffff\1\5",
            "",
            "",
            "\1\5\1\10\2\uffff\1\5\2\uffff\2\5\6\uffff\1\5\7\uffff\2\5\25"+
            "\uffff\6\5\1\uffff\1\5\3\uffff\1\5",
            "\1\11\1\uffff\4\5\7\uffff\1\5",
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
            return "392:5: (pe= persistent_expr | rs= raise_statement | l= log_statement | las= must_be[\"last\"] )";
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
                        if ( (synpred29_RuleSet()) ) {s = 2;}

                        else if ( (synpred31_RuleSet()) ) {s = 5;}

                         
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
    static final String DFA57_eotS =
        "\20\uffff";
    static final String DFA57_eofS =
        "\20\uffff";
    static final String DFA57_minS =
        "\1\5\5\uffff\1\0\11\uffff";
    static final String DFA57_maxS =
        "\1\106\5\uffff\1\0\11\uffff";
    static final String DFA57_acceptS =
        "\1\uffff\1\2\15\uffff\1\1";
    static final String DFA57_specialS =
        "\6\uffff\1\0\11\uffff}>";
    static final String[] DFA57_transitionS = {
            "\2\1\1\6\1\uffff\7\1\4\uffff\1\1\6\uffff\2\1\2\uffff\2\1\4\uffff"+
            "\2\1\37\uffff\1\1",
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
            ""
    };

    static final short[] DFA57_eot = DFA.unpackEncodedString(DFA57_eotS);
    static final short[] DFA57_eof = DFA.unpackEncodedString(DFA57_eofS);
    static final char[] DFA57_min = DFA.unpackEncodedStringToUnsignedChars(DFA57_minS);
    static final char[] DFA57_max = DFA.unpackEncodedStringToUnsignedChars(DFA57_maxS);
    static final short[] DFA57_accept = DFA.unpackEncodedString(DFA57_acceptS);
    static final short[] DFA57_special = DFA.unpackEncodedString(DFA57_specialS);
    static final short[][] DFA57_transition;

    static {
        int numStates = DFA57_transitionS.length;
        DFA57_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA57_transition[i] = DFA.unpackEncodedString(DFA57_transitionS[i]);
        }
    }

    class DFA57 extends DFA {

        public DFA57(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 57;
            this.eot = DFA57_eot;
            this.eof = DFA57_eof;
            this.min = DFA57_min;
            this.max = DFA57_max;
            this.accept = DFA57_accept;
            this.special = DFA57_special;
            this.transition = DFA57_transition;
        }
        public String getDescription() {
            return "()* loopback of 812:16: (tb= must_be_one[sar(\"then\",\"before\")] eor2= event_or )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA57_6 = input.LA(1);

                         
                        int index57_6 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred83_RuleSet()) ) {s = 15;}

                        else if ( (true) ) {s = 1;}

                         
                        input.seek(index57_6);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 57, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA68_eotS =
        "\34\uffff";
    static final String DFA68_eofS =
        "\5\uffff\1\33\26\uffff";
    static final String DFA68_minS =
        "\3\7\2\uffff\1\5\26\uffff";
    static final String DFA68_maxS =
        "\2\54\1\23\2\uffff\1\106\26\uffff";
    static final String DFA68_acceptS =
        "\3\uffff\1\2\1\4\1\uffff\1\1\1\3\24\1";
    static final String DFA68_specialS =
        "\2\uffff\1\1\2\uffff\1\0\26\uffff}>";
    static final String[] DFA68_transitionS = {
            "\1\2\26\uffff\1\4\14\uffff\1\1\1\3",
            "\1\5\44\uffff\1\3",
            "\1\6\13\uffff\1\7",
            "",
            "",
            "\1\26\1\30\1\10\1\uffff\1\23\1\24\2\23\1\20\1\22\1\27\3\uffff"+
            "\1\7\1\24\6\uffff\2\25\2\uffff\1\31\1\32\1\14\2\uffff\1\11\1"+
            "\17\1\16\1\uffff\1\15\1\12\1\13\33\uffff\1\21",
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

    static final short[] DFA68_eot = DFA.unpackEncodedString(DFA68_eotS);
    static final short[] DFA68_eof = DFA.unpackEncodedString(DFA68_eofS);
    static final char[] DFA68_min = DFA.unpackEncodedStringToUnsignedChars(DFA68_minS);
    static final char[] DFA68_max = DFA.unpackEncodedStringToUnsignedChars(DFA68_maxS);
    static final short[] DFA68_accept = DFA.unpackEncodedString(DFA68_acceptS);
    static final short[] DFA68_special = DFA.unpackEncodedString(DFA68_specialS);
    static final short[][] DFA68_transition;

    static {
        int numStates = DFA68_transitionS.length;
        DFA68_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA68_transition[i] = DFA.unpackEncodedString(DFA68_transitionS[i]);
        }
    }

    class DFA68 extends DFA {

        public DFA68(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 68;
            this.eot = DFA68_eot;
            this.eof = DFA68_eof;
            this.min = DFA68_min;
            this.max = DFA68_max;
            this.accept = DFA68_accept;
            this.special = DFA68_special;
            this.transition = DFA68_transition;
        }
        public String getDescription() {
            return "974:1: event_prim returns [HashMap result] : ( ( custom_event )=>ce= custom_event | (web= WEB )? PAGEVIEW (spat= STRING | rpat= regex ) (set= setting )? | (web= WEB )? opt= must_be_one[sar(\"submit\",\"click\",\"dblclick\",\"change\",\"update\")] elem= STRING (on= on_expr )? (set= setting )? | '(' evt= event_seq ')' );";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA68_5 = input.LA(1);

                         
                        int index68_5 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (LA68_5==STRING) ) {s = 7;}

                        else if ( (LA68_5==VAR) && (synpred88_RuleSet())) {s = 8;}

                        else if ( (LA68_5==SETTING) && (synpred88_RuleSet())) {s = 9;}

                        else if ( (LA68_5==NOT) && (synpred88_RuleSet())) {s = 10;}

                        else if ( (LA68_5==BETWEEN) && (synpred88_RuleSet())) {s = 11;}

                        else if ( (LA68_5==AND_AND) && (synpred88_RuleSet())) {s = 12;}

                        else if ( (LA68_5==OR_OR) && (synpred88_RuleSet())) {s = 13;}

                        else if ( (LA68_5==FOREACH) && (synpred88_RuleSet())) {s = 14;}

                        else if ( (LA68_5==PRE) && (synpred88_RuleSet())) {s = 15;}

                        else if ( (LA68_5==SEMI) && (synpred88_RuleSet())) {s = 16;}

                        else if ( (LA68_5==EMIT) && (synpred88_RuleSet())) {s = 17;}

                        else if ( (LA68_5==IF) && (synpred88_RuleSet())) {s = 18;}

                        else if ( (LA68_5==OTHER_OPERATORS||(LA68_5>=REPLACE && LA68_5<=MATCH)) && (synpred88_RuleSet())) {s = 19;}

                        else if ( (LA68_5==LIKE||LA68_5==VAR_DOMAIN) && (synpred88_RuleSet())) {s = 20;}

                        else if ( ((LA68_5>=EVERY && LA68_5<=CHOOSE)) && (synpred88_RuleSet())) {s = 21;}

                        else if ( (LA68_5==LEFT_CURL) && (synpred88_RuleSet())) {s = 22;}

                        else if ( (LA68_5==CALLBACKS) && (synpred88_RuleSet())) {s = 23;}

                        else if ( (LA68_5==RIGHT_CURL) && (synpred88_RuleSet())) {s = 24;}

                        else if ( (LA68_5==COMMA) && (synpred88_RuleSet())) {s = 25;}

                        else if ( (LA68_5==RIGHT_PAREN) && (synpred88_RuleSet())) {s = 26;}

                        else if ( (LA68_5==EOF) && (synpred88_RuleSet())) {s = 27;}

                         
                        input.seek(index68_5);
                        if ( s>=0 ) return s;
                        break;
                    case 1 : 
                        int LA68_2 = input.LA(1);

                         
                        int index68_2 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (LA68_2==VAR) && (synpred88_RuleSet())) {s = 6;}

                        else if ( (LA68_2==STRING) ) {s = 7;}

                         
                        input.seek(index68_2);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 68, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA85_eotS =
        "\44\uffff";
    static final String DFA85_eofS =
        "\1\1\43\uffff";
    static final String DFA85_minS =
        "\1\5\25\uffff\1\0\15\uffff";
    static final String DFA85_maxS =
        "\1\106\25\uffff\1\0\15\uffff";
    static final String DFA85_acceptS =
        "\1\uffff\1\2\41\uffff\1\1";
    static final String DFA85_specialS =
        "\26\uffff\1\0\15\uffff}>";
    static final String[] DFA85_transitionS = {
            "\5\1\1\26\5\1\3\uffff\2\1\6\uffff\7\1\2\uffff\1\1\4\uffff\1"+
            "\1\10\uffff\4\1\1\43\2\uffff\2\1\1\uffff\11\1\1\uffff\1\1",
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
            return "()* loopback of 1230:17: (op= ( PREDOP | LIKE ) me2= add_expr )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA85_22 = input.LA(1);

                         
                        int index85_22 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred137_RuleSet()) ) {s = 35;}

                        else if ( (true) ) {s = 1;}

                         
                        input.seek(index85_22);
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
    static final String DFA87_eotS =
        "\45\uffff";
    static final String DFA87_eofS =
        "\1\1\44\uffff";
    static final String DFA87_minS =
        "\1\5\27\uffff\1\0\14\uffff";
    static final String DFA87_maxS =
        "\1\106\27\uffff\1\0\14\uffff";
    static final String DFA87_acceptS =
        "\1\uffff\1\2\42\uffff\1\1";
    static final String DFA87_specialS =
        "\30\uffff\1\0\14\uffff}>";
    static final String[] DFA87_transitionS = {
            "\13\1\3\uffff\2\1\6\uffff\7\1\2\uffff\1\1\4\uffff\1\1\10\uffff"+
            "\5\1\1\uffff\1\44\1\30\1\1\1\uffff\11\1\1\uffff\1\1",
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

    static final short[] DFA87_eot = DFA.unpackEncodedString(DFA87_eotS);
    static final short[] DFA87_eof = DFA.unpackEncodedString(DFA87_eofS);
    static final char[] DFA87_min = DFA.unpackEncodedStringToUnsignedChars(DFA87_minS);
    static final char[] DFA87_max = DFA.unpackEncodedStringToUnsignedChars(DFA87_maxS);
    static final short[] DFA87_accept = DFA.unpackEncodedString(DFA87_acceptS);
    static final short[] DFA87_special = DFA.unpackEncodedString(DFA87_specialS);
    static final short[][] DFA87_transition;

    static {
        int numStates = DFA87_transitionS.length;
        DFA87_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA87_transition[i] = DFA.unpackEncodedString(DFA87_transitionS[i]);
        }
    }

    class DFA87 extends DFA {

        public DFA87(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 87;
            this.eot = DFA87_eot;
            this.eof = DFA87_eof;
            this.min = DFA87_min;
            this.max = DFA87_max;
            this.accept = DFA87_accept;
            this.special = DFA87_special;
            this.transition = DFA87_transition;
        }
        public String getDescription() {
            return "()* loopback of 1277:19: (op= ( ADD_OP | REX ) me2= mult_expr )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA87_24 = input.LA(1);

                         
                        int index87_24 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred140_RuleSet()) ) {s = 36;}

                        else if ( (true) ) {s = 1;}

                         
                        input.seek(index87_24);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 87, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA89_eotS =
        "\25\uffff";
    static final String DFA89_eofS =
        "\25\uffff";
    static final String DFA89_minS =
        "\1\5\1\uffff\3\0\20\uffff";
    static final String DFA89_maxS =
        "\1\102\1\uffff\3\0\20\uffff";
    static final String DFA89_acceptS =
        "\1\uffff\1\1\3\uffff\1\7\12\uffff\1\2\1\3\1\4\1\5\1\6";
    static final String DFA89_specialS =
        "\2\uffff\1\0\1\1\1\2\20\uffff}>";
    static final String[] DFA89_transitionS = {
            "\1\5\1\uffff\6\5\6\uffff\1\5\1\3\11\uffff\1\5\12\uffff\1\1\17"+
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

    static final short[] DFA89_eot = DFA.unpackEncodedString(DFA89_eotS);
    static final short[] DFA89_eof = DFA.unpackEncodedString(DFA89_eofS);
    static final char[] DFA89_min = DFA.unpackEncodedStringToUnsignedChars(DFA89_minS);
    static final char[] DFA89_max = DFA.unpackEncodedStringToUnsignedChars(DFA89_maxS);
    static final short[] DFA89_accept = DFA.unpackEncodedString(DFA89_acceptS);
    static final short[] DFA89_special = DFA.unpackEncodedString(DFA89_specialS);
    static final short[][] DFA89_transition;

    static {
        int numStates = DFA89_transitionS.length;
        DFA89_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA89_transition[i] = DFA.unpackEncodedString(DFA89_transitionS[i]);
        }
    }

    class DFA89 extends DFA {

        public DFA89(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 89;
            this.eot = DFA89_eot;
            this.eof = DFA89_eof;
            this.min = DFA89_min;
            this.max = DFA89_max;
            this.accept = DFA89_accept;
            this.special = DFA89_special;
            this.transition = DFA89_transition;
        }
        public String getDescription() {
            return "1296:1: unary_expr returns [Object result] options {backtrack=true; } : ( NOT ue= unary_expr | SEEN rx= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) (t= timeframe )? | SEEN rx_1= STRING op= must_be_one[sar(\"before\",\"after\")] rx_2= STRING must_be[\"in\"] vd= VAR_DOMAIN ':' v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) pop= ( PREDOP | LIKE ) e= expr t= timeframe | vd= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) t= timeframe | roe= regex | oe= operator_expr );";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA89_2 = input.LA(1);

                         
                        int index89_2 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred148_RuleSet()) ) {s = 16;}

                        else if ( (synpred154_RuleSet()) ) {s = 17;}

                         
                        input.seek(index89_2);
                        if ( s>=0 ) return s;
                        break;
                    case 1 : 
                        int LA89_3 = input.LA(1);

                         
                        int index89_3 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred161_RuleSet()) ) {s = 18;}

                        else if ( (synpred167_RuleSet()) ) {s = 19;}

                        else if ( (true) ) {s = 5;}

                         
                        input.seek(index89_3);
                        if ( s>=0 ) return s;
                        break;
                    case 2 : 
                        int LA89_4 = input.LA(1);

                         
                        int index89_4 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred168_RuleSet()) ) {s = 20;}

                        else if ( (true) ) {s = 5;}

                         
                        input.seek(index89_4);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 89, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA88_eotS =
        "\47\uffff";
    static final String DFA88_eofS =
        "\1\2\46\uffff";
    static final String DFA88_minS =
        "\1\5\1\0\45\uffff";
    static final String DFA88_maxS =
        "\1\106\1\0\45\uffff";
    static final String DFA88_acceptS =
        "\2\uffff\1\2\43\uffff\1\1";
    static final String DFA88_specialS =
        "\1\uffff\1\0\45\uffff}>";
    static final String[] DFA88_transitionS = {
            "\13\2\3\uffff\2\2\6\uffff\7\2\2\uffff\1\2\4\uffff\1\2\10\uffff"+
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
            "",
            "",
            ""
    };

    static final short[] DFA88_eot = DFA.unpackEncodedString(DFA88_eotS);
    static final short[] DFA88_eof = DFA.unpackEncodedString(DFA88_eofS);
    static final char[] DFA88_min = DFA.unpackEncodedStringToUnsignedChars(DFA88_minS);
    static final char[] DFA88_max = DFA.unpackEncodedStringToUnsignedChars(DFA88_maxS);
    static final short[] DFA88_accept = DFA.unpackEncodedString(DFA88_acceptS);
    static final short[] DFA88_special = DFA.unpackEncodedString(DFA88_specialS);
    static final short[][] DFA88_transition;

    static {
        int numStates = DFA88_transitionS.length;
        DFA88_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA88_transition[i] = DFA.unpackEncodedString(DFA88_transitionS[i]);
        }
    }

    class DFA88 extends DFA {

        public DFA88(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 88;
            this.eot = DFA88_eot;
            this.eof = DFA88_eof;
            this.min = DFA88_min;
            this.max = DFA88_max;
            this.accept = DFA88_accept;
            this.special = DFA88_special;
            this.transition = DFA88_transition;
        }
        public String getDescription() {
            return "1309:106: (t= timeframe )?";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA88_1 = input.LA(1);

                         
                        int index88_1 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred147_RuleSet()) ) {s = 38;}

                        else if ( (true) ) {s = 2;}

                         
                        input.seek(index88_1);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 88, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA102_eotS =
        "\23\uffff";
    static final String DFA102_eofS =
        "\23\uffff";
    static final String DFA102_minS =
        "\1\5\4\uffff\2\0\5\uffff\1\0\6\uffff";
    static final String DFA102_maxS =
        "\1\102\4\uffff\2\0\5\uffff\1\0\6\uffff";
    static final String DFA102_acceptS =
        "\1\uffff\1\1\1\2\1\3\1\4\2\uffff\1\7\1\10\1\13\1\14\1\15\1\uffff"+
        "\1\17\1\5\1\6\1\11\1\12\1\16";
    static final String DFA102_specialS =
        "\5\uffff\1\0\1\1\5\uffff\1\2\6\uffff}>";
    static final String[] DFA102_transitionS = {
            "\1\12\1\uffff\1\6\1\1\1\6\1\14\2\6\6\uffff\1\2\1\5\11\uffff"+
            "\1\13\32\uffff\1\15\2\uffff\1\3\2\4\1\11\1\uffff\1\7\1\10",
            "",
            "",
            "",
            "",
            "\1\uffff",
            "\1\uffff",
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
            ""
    };

    static final short[] DFA102_eot = DFA.unpackEncodedString(DFA102_eotS);
    static final short[] DFA102_eof = DFA.unpackEncodedString(DFA102_eofS);
    static final char[] DFA102_min = DFA.unpackEncodedStringToUnsignedChars(DFA102_minS);
    static final char[] DFA102_max = DFA.unpackEncodedStringToUnsignedChars(DFA102_maxS);
    static final short[] DFA102_accept = DFA.unpackEncodedString(DFA102_acceptS);
    static final short[] DFA102_special = DFA.unpackEncodedString(DFA102_specialS);
    static final short[][] DFA102_transition;

    static {
        int numStates = DFA102_transitionS.length;
        DFA102_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA102_transition[i] = DFA.unpackEncodedString(DFA102_transitionS[i]);
        }
    }

    class DFA102 extends DFA {

        public DFA102(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 102;
            this.eot = DFA102_eot;
            this.eof = DFA102_eof;
            this.min = DFA102_min;
            this.max = DFA102_max;
            this.accept = DFA102_accept;
            this.special = DFA102_special;
            this.transition = DFA102_transition;
        }
        public String getDescription() {
            return "1440:1: factor returns [Object result] options {backtrack=true; } : (iv= INT | sv= STRING | fv= FLOAT | bv= ( TRUE | FALSE ) | bv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_BRACKET e= expr RIGHT_BRACKET | d= VAR_DOMAIN COLON vv= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | CURRENT d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | HISTORY e= expr d= VAR_DOMAIN COLON v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) | n= namespace p= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | LIKE | REPLACE | MATCH | VAR_DOMAIN ) LEFT_PAREN (e= expr ( COMMA e= expr )* )? RIGHT_PAREN | LEFT_BRACKET (e= expr ( COMMA e2= expr )* )? RIGHT_BRACKET | LEFT_CURL (h1= hash_line ( COMMA h2= hash_line )* )? RIGHT_CURL | LEFT_PAREN e= expr RIGHT_PAREN | v= ( VAR | OTHER_OPERATORS | REPLACE | MATCH ) | reg= regex );";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            TokenStream input = (TokenStream)_input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA102_5 = input.LA(1);

                         
                        int index102_5 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred184_RuleSet()) ) {s = 14;}

                        else if ( (synpred190_RuleSet()) ) {s = 15;}

                        else if ( (synpred210_RuleSet()) ) {s = 16;}

                        else if ( (synpred218_RuleSet()) ) {s = 17;}

                         
                        input.seek(index102_5);
                        if ( s>=0 ) return s;
                        break;
                    case 1 : 
                        int LA102_6 = input.LA(1);

                         
                        int index102_6 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred184_RuleSet()) ) {s = 14;}

                        else if ( (synpred210_RuleSet()) ) {s = 16;}

                        else if ( (synpred218_RuleSet()) ) {s = 17;}

                        else if ( (synpred229_RuleSet()) ) {s = 18;}

                         
                        input.seek(index102_6);
                        if ( s>=0 ) return s;
                        break;
                    case 2 : 
                        int LA102_12 = input.LA(1);

                         
                        int index102_12 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred184_RuleSet()) ) {s = 14;}

                        else if ( (synpred210_RuleSet()) ) {s = 16;}

                        else if ( (synpred218_RuleSet()) ) {s = 17;}

                         
                        input.seek(index102_12);
                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 102, _s, input);
            error(nvae);
            throw nvae;
        }
    }
 

    public static final BitSet FOLLOW_RULE_SET_in_ruleset100 = new BitSet(new long[]{0x0000000000000180L});
    public static final BitSet FOLLOW_rulesetname_in_ruleset102 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_ruleset109 = new BitSet(new long[]{0x00004000000000C0L,0x0000000000000080L});
    public static final BitSet FOLLOW_meta_block_in_ruleset116 = new BitSet(new long[]{0x00004000000000C0L,0x0000000000000080L});
    public static final BitSet FOLLOW_dispatch_block_in_ruleset120 = new BitSet(new long[]{0x00004000000000C0L,0x0000000000000080L});
    public static final BitSet FOLLOW_global_block_in_ruleset124 = new BitSet(new long[]{0x00004000000000C0L,0x0000000000000080L});
    public static final BitSet FOLLOW_rule_in_ruleset128 = new BitSet(new long[]{0x00004000000000C0L,0x0000000000000080L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_ruleset134 = new BitSet(new long[]{0x0000000000000000L});
    public static final BitSet FOLLOW_EOF_in_ruleset138 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_must_be161 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_must_be_one186 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_rulesetname0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_rule_name0 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_rule257 = new BitSet(new long[]{0x0000000000001F80L});
    public static final BitSet FOLLOW_rule_name_in_rule264 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_rule275 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_rule287 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_rule292 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_rule302 = new BitSet(new long[]{0x0000008800000000L});
    public static final BitSet FOLLOW_using_in_rule309 = new BitSet(new long[]{0x000000601810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_when_in_rule313 = new BitSet(new long[]{0x000000601810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_foreach_in_rule319 = new BitSet(new long[]{0x000000601810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_pre_block_in_rule332 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_SEMI_in_rule335 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_emit_block_in_rule340 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_SEMI_in_rule343 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_action_in_rule347 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_SEMI_in_rule350 = new BitSet(new long[]{0x000000001810FEE0L,0x0000000000000040L});
    public static final BitSet FOLLOW_callbacks_in_rule357 = new BitSet(new long[]{0x00000000000020C0L});
    public static final BitSet FOLLOW_SEMI_in_rule360 = new BitSet(new long[]{0x00000000000020C0L});
    public static final BitSet FOLLOW_post_block_in_rule365 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_rule368 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_rule373 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_post_block404 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_post_block407 = new BitSet(new long[]{0x0000000001900080L});
    public static final BitSet FOLLOW_post_statement_in_post_block414 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_post_block419 = new BitSet(new long[]{0x0000000001900080L});
    public static final BitSet FOLLOW_post_statement_in_post_block423 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_post_block431 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_post_block434 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_post_alternate_in_post_block440 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_post_alternate467 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_post_alternate470 = new BitSet(new long[]{0x00000000019020C0L});
    public static final BitSet FOLLOW_post_statement_in_post_alternate475 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_post_alternate480 = new BitSet(new long[]{0x0000000001900080L});
    public static final BitSet FOLLOW_post_statement_in_post_alternate484 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_post_alternate492 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_post_alternate495 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_expr_in_post_statement513 = new BitSet(new long[]{0x0000000000004002L});
    public static final BitSet FOLLOW_raise_statement_in_post_statement523 = new BitSet(new long[]{0x0000000000004002L});
    public static final BitSet FOLLOW_log_statement_in_post_statement530 = new BitSet(new long[]{0x0000000000004002L});
    public static final BitSet FOLLOW_must_be_in_post_statement540 = new BitSet(new long[]{0x0000000000004002L});
    public static final BitSet FOLLOW_IF_in_post_statement546 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_post_statement550 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_raise_statement575 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_raise_statement578 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_raise_statement581 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_raise_statement587 = new BitSet(new long[]{0x0000000006000002L});
    public static final BitSet FOLLOW_for_clause_in_raise_statement591 = new BitSet(new long[]{0x0000000002000002L});
    public static final BitSet FOLLOW_modifier_clause_in_raise_statement596 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_log_statement616 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_log_statement622 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CALLBACKS_in_callbacks640 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_callbacks642 = new BitSet(new long[]{0x0000000000030040L});
    public static final BitSet FOLLOW_success_in_callbacks646 = new BitSet(new long[]{0x0000000000020040L});
    public static final BitSet FOLLOW_failure_in_callbacks651 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_callbacks654 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SUCCESS_in_success676 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_success678 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_success682 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_success688 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_success692 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_success699 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_success703 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FAILURE_in_failure731 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_failure733 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_failure737 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_failure743 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_click_in_failure747 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_failure755 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_failure759 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_click777 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_click782 = new BitSet(new long[]{0x0000000000040000L});
    public static final BitSet FOLLOW_EQUAL_in_click784 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_click788 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_click_link_in_click792 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_click_link812 = new BitSet(new long[]{0x0000000001900080L});
    public static final BitSet FOLLOW_persistent_expr_in_click_link817 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_clear_set_in_persistent_expr839 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_iterate_in_persistent_expr849 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_trail_forget_in_persistent_expr862 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_trail_mark_in_persistent_expr875 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_persistent_clear_set900 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_persistent_clear_set906 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_persistent_clear_set908 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_persistent_clear_set912 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_persistent_iterate933 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_persistent_iterate935 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_persistent_iterate939 = new BitSet(new long[]{0x0000000000400000L});
    public static final BitSet FOLLOW_COUNTER_OP_in_persistent_iterate943 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_persistent_iterate947 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_counter_start_in_persistent_iterate951 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FORGET_in_trail_forget968 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_trail_forget973 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_trail_forget975 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_trail_forget981 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_trail_forget983 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_trail_forget987 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MARK_in_trail_mark1006 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_trail_mark1010 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_trail_mark1012 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_trail_mark1016 = new BitSet(new long[]{0x0000000002000002L});
    public static final BitSet FOLLOW_trail_with_in_trail_mark1020 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITH_in_trail_with1039 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_trail_with1043 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_counter_start1061 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_counter_start1066 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOR_in_for_clause1087 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_for_clause1092 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_conditional_action_in_action1126 = new BitSet(new long[]{0x0000000000002002L});
    public static final BitSet FOLLOW_unconditional_action_in_action1131 = new BitSet(new long[]{0x0000000000002002L});
    public static final BitSet FOLLOW_SEMI_in_action1135 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_IF_in_conditional_action1150 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_conditional_action1154 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_conditional_action1156 = new BitSet(new long[]{0x0000000018105EA0L,0x0000000000000040L});
    public static final BitSet FOLLOW_unconditional_action_in_conditional_action1159 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_primrule_in_unconditional_action1184 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_action_block_in_unconditional_action1194 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_action_block1218 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_action_block1231 = new BitSet(new long[]{0x0000000000101E80L,0x0000000000000040L});
    public static final BitSet FOLLOW_primrule_in_action_block1236 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_action_block1246 = new BitSet(new long[]{0x0000000000101E80L,0x0000000000000040L});
    public static final BitSet FOLLOW_primrule_in_action_block1250 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_action_block1257 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_action_block1260 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_primrule1287 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_primrule1289 = new BitSet(new long[]{0x0000000000101E80L,0x0000000000000040L});
    public static final BitSet FOLLOW_namespace_in_primrule1300 = new BitSet(new long[]{0x0000000000001A80L});
    public static final BitSet FOLLOW_set_in_primrule1306 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_primrule1316 = new BitSet(new long[]{0xF6040201C0181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_primrule1321 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_primrule1326 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_primrule1330 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_primrule1338 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_primrule1342 = new BitSet(new long[]{0x0000001002000002L});
    public static final BitSet FOLLOW_setting_in_primrule1347 = new BitSet(new long[]{0x0000000002000002L});
    public static final BitSet FOLLOW_modifier_clause_in_primrule1352 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_primrule1363 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_primrule1365 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000040L});
    public static final BitSet FOLLOW_emit_block_in_primrule1371 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITH_in_modifier_clause1403 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_modifier_in_modifier_clause1407 = new BitSet(new long[]{0x0000000200000002L});
    public static final BitSet FOLLOW_AND_AND_in_modifier_clause1412 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_modifier_in_modifier_clause1416 = new BitSet(new long[]{0x0000000200000002L});
    public static final BitSet FOLLOW_VAR_in_modifier1441 = new BitSet(new long[]{0x0000000000040000L});
    public static final BitSet FOLLOW_EQUAL_in_modifier1443 = new BitSet(new long[]{0xF604020440181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_modifier1447 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_modifier1453 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_USING_in_using1477 = new BitSet(new long[]{0x0200000000080000L});
    public static final BitSet FOLLOW_STRING_in_using1482 = new BitSet(new long[]{0x0000001000000002L});
    public static final BitSet FOLLOW_regex_in_using1486 = new BitSet(new long[]{0x0000001000000002L});
    public static final BitSet FOLLOW_setting_in_using1491 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SETTING_in_setting1512 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_setting1514 = new BitSet(new long[]{0x0000000100001E80L});
    public static final BitSet FOLLOW_set_in_setting1519 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_setting1533 = new BitSet(new long[]{0x0000000000001E80L});
    public static final BitSet FOLLOW_set_in_setting1537 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_setting1555 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_PRE_in_pre_block1580 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_pre_block1582 = new BitSet(new long[]{0x0000000000103EC0L});
    public static final BitSet FOLLOW_decl_in_pre_block1586 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_pre_block1590 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_decl_in_pre_block1592 = new BitSet(new long[]{0x0000000000002040L});
    public static final BitSet FOLLOW_SEMI_in_pre_block1600 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_pre_block1603 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FOREACH_in_foreach1624 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_foreach1628 = new BitSet(new long[]{0x0000001000000000L});
    public static final BitSet FOLLOW_setting_in_foreach1632 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WHEN_in_when1665 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_seq_in_when1669 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_event_or_in_event_seq1696 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_must_be_one_in_event_seq1701 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_or_in_event_seq1706 = new BitSet(new long[]{0x0000000000000082L});
    public static final BitSet FOLLOW_event_and_in_event_or1747 = new BitSet(new long[]{0x0000010000000002L});
    public static final BitSet FOLLOW_OR_OR_in_event_or1752 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_and_in_event_or1756 = new BitSet(new long[]{0x0000010000000002L});
    public static final BitSet FOLLOW_event_btwn_in_event_and1785 = new BitSet(new long[]{0x0000000200000002L});
    public static final BitSet FOLLOW_AND_AND_in_event_and1790 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_btwn_in_event_and1794 = new BitSet(new long[]{0x0000000200000002L});
    public static final BitSet FOLLOW_event_prim_in_event_btwn1820 = new BitSet(new long[]{0x0000060000000002L});
    public static final BitSet FOLLOW_NOT_in_event_btwn1826 = new BitSet(new long[]{0x0000040000000000L});
    public static final BitSet FOLLOW_BETWEEN_in_event_btwn1831 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_event_btwn1833 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_seq_in_event_btwn1837 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_COMMA_in_event_btwn1839 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_seq_in_event_btwn1843 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_event_btwn1845 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_custom_event_in_event_prim1878 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WEB_in_event_prim1887 = new BitSet(new long[]{0x0000100000000000L});
    public static final BitSet FOLLOW_PAGEVIEW_in_event_prim1890 = new BitSet(new long[]{0x0200000000080000L});
    public static final BitSet FOLLOW_STRING_in_event_prim1895 = new BitSet(new long[]{0x0000001000000002L});
    public static final BitSet FOLLOW_regex_in_event_prim1899 = new BitSet(new long[]{0x0000001000000002L});
    public static final BitSet FOLLOW_setting_in_event_prim1904 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WEB_in_event_prim1915 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_event_prim1920 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_event_prim1925 = new BitSet(new long[]{0x0000201000000002L});
    public static final BitSet FOLLOW_on_expr_in_event_prim1929 = new BitSet(new long[]{0x0000001000000002L});
    public static final BitSet FOLLOW_setting_in_event_prim1935 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_event_prim1943 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_seq_in_event_prim1947 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_event_prim1949 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_custom_event1985 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_custom_event1993 = new BitSet(new long[]{0x0000001000000082L});
    public static final BitSet FOLLOW_event_filter_in_custom_event1998 = new BitSet(new long[]{0x0000001000000082L});
    public static final BitSet FOLLOW_setting_in_custom_event2005 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_event_filter2028 = new BitSet(new long[]{0x0200000000080000L});
    public static final BitSet FOLLOW_STRING_in_event_filter2033 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_event_filter2039 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_ON_in_on_expr2058 = new BitSet(new long[]{0x0200000000080000L});
    public static final BitSet FOLLOW_STRING_in_on_expr2066 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_on_expr2077 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_GLOBAL_in_global_block2115 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_global_block2117 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_emit_block_in_global_block2124 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_must_be_one_in_global_block2134 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_global_block2139 = new BitSet(new long[]{0x0001000000200000L});
    public static final BitSet FOLLOW_COLON_in_global_block2142 = new BitSet(new long[]{0x0000800000000000L});
    public static final BitSet FOLLOW_DTYPE_in_global_block2146 = new BitSet(new long[]{0x0001000000000000L});
    public static final BitSet FOLLOW_LEFT_SMALL_ARROW_in_global_block2150 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_global_block2154 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000070L});
    public static final BitSet FOLLOW_cachable_in_global_block2159 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_css_emit_in_global_block2174 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_decl_in_global_block2182 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_SEMI_in_global_block2188 = new BitSet(new long[]{0x0000000000103EC0L,0x0000000000000050L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_global_block2193 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_decl2220 = new BitSet(new long[]{0x0000000000040000L});
    public static final BitSet FOLLOW_EQUAL_in_decl2234 = new BitSet(new long[]{0xF606020440181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_HTML_in_decl2239 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_decl2243 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_expr_in_decl2247 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_function_def_in_expr2277 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_conditional_expression_in_expr2286 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FUNCTION_in_function_def2311 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_function_def2313 = new BitSet(new long[]{0x0000000180101E80L});
    public static final BitSet FOLLOW_set_in_function_def2317 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_function_def2333 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_function_def2337 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_function_def2354 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_function_def2356 = new BitSet(new long[]{0xF604020040183FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_decl_in_function_def2360 = new BitSet(new long[]{0xF604020040183FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_SEMI_in_function_def2365 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_decl_in_function_def2369 = new BitSet(new long[]{0xF604020040183FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_SEMI_in_function_def2374 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_function_def2379 = new BitSet(new long[]{0x0000000000000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_function_def2381 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_disjunction_in_conditional_expression2407 = new BitSet(new long[]{0x0000000020000002L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_conditional_expression2410 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_conditional_expression2414 = new BitSet(new long[]{0x0008000000000000L});
    public static final BitSet FOLLOW_PIPE_in_conditional_expression2416 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_conditional_expression2420 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_equality_expr_in_disjunction2452 = new BitSet(new long[]{0x0030000000000002L});
    public static final BitSet FOLLOW_set_in_disjunction2457 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_equality_expr_in_disjunction2465 = new BitSet(new long[]{0x0030000000000002L});
    public static final BitSet FOLLOW_add_expr_in_equality_expr2498 = new BitSet(new long[]{0x0040000000000402L});
    public static final BitSet FOLLOW_set_in_equality_expr2503 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_add_expr_in_equality_expr2511 = new BitSet(new long[]{0x0040000000000402L});
    public static final BitSet FOLLOW_unary_expr_in_mult_expr2548 = new BitSet(new long[]{0x0080000000000002L});
    public static final BitSet FOLLOW_MULT_OP_in_mult_expr2554 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_unary_expr_in_mult_expr2558 = new BitSet(new long[]{0x0080000000000002L});
    public static final BitSet FOLLOW_mult_expr_in_add_expr2605 = new BitSet(new long[]{0x0300000000000002L});
    public static final BitSet FOLLOW_set_in_add_expr2611 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_mult_expr_in_add_expr2619 = new BitSet(new long[]{0x0300000000000002L});
    public static final BitSet FOLLOW_NOT_in_unary_expr2663 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_unary_expr_in_unary_expr2667 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_unary_expr2676 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2680 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_unary_expr2682 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2687 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2689 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_unary_expr2693 = new BitSet(new long[]{0x0000000000000002L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2709 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_unary_expr2717 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2721 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_unary_expr2725 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_unary_expr2730 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_unary_expr2733 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2738 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2740 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_unary_expr2744 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2765 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2767 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_unary_expr2771 = new BitSet(new long[]{0x0040000000000400L});
    public static final BitSet FOLLOW_set_in_unary_expr2787 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_unary_expr2795 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2799 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_unary_expr2809 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_unary_expr2811 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_unary_expr2815 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_unary_expr2831 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_unary_expr2840 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_operator_expr_in_unary_expr2849 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_factor_in_operator_expr2878 = new BitSet(new long[]{0x0800000000000002L});
    public static final BitSet FOLLOW_operator_in_operator_expr2884 = new BitSet(new long[]{0x0800000000000002L});
    public static final BitSet FOLLOW_DOT_in_operator2911 = new BitSet(new long[]{0x0000000000001A00L});
    public static final BitSet FOLLOW_OTHER_OPERATORS_in_operator2917 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator2919 = new BitSet(new long[]{0xF604020140181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_operator2924 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_operator2929 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_operator2933 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator2942 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_MATCH_in_operator2966 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator2968 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_operator2972 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator2977 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_REPLACE_in_operator3002 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_operator3004 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_operator3008 = new BitSet(new long[]{0x0000000080000000L});
    public static final BitSet FOLLOW_COMMA_in_operator3012 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_operator3016 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_operator3019 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_INT_in_factor3059 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_factor3074 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FLOAT_in_factor3094 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor3114 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor3134 = new BitSet(new long[]{0x8000000000000000L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_factor3148 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3152 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000001L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_factor3154 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor3169 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_factor3171 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_factor3175 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CURRENT_in_factor3199 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor3203 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_factor3205 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_factor3209 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_HISTORY_in_factor3234 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3238 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_factor3242 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_factor3244 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_factor3248 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_namespace_in_factor3274 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_factor3278 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3292 = new BitSet(new long[]{0xF604020140181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3297 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_factor3303 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3307 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3316 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor3331 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3345 = new BitSet(new long[]{0xF604020140181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3350 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_factor3355 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3359 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3368 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_factor3380 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000007L});
    public static final BitSet FOLLOW_expr_in_factor3385 = new BitSet(new long[]{0x0000000080000000L,0x0000000000000001L});
    public static final BitSet FOLLOW_COMMA_in_factor3390 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3394 = new BitSet(new long[]{0x0000000080000000L,0x0000000000000001L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_factor3402 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_CURL_in_factor3414 = new BitSet(new long[]{0x0000000000080040L});
    public static final BitSet FOLLOW_hash_line_in_factor3419 = new BitSet(new long[]{0x0000000080000040L});
    public static final BitSet FOLLOW_COMMA_in_factor3424 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_hash_line_in_factor3428 = new BitSet(new long[]{0x0000000080000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_factor3437 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_factor3449 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_factor3453 = new BitSet(new long[]{0x0000000100000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_factor3456 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_factor3475 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_factor3499 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_namespace3532 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_namespace3546 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_WITHIN_in_timeframe3568 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_timeframe3572 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_period_in_timeframe3576 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_hash_line3603 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_hash_line3605 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_hash_line3609 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CSS_in_css_emit3627 = new BitSet(new long[]{0x0002000000080000L});
    public static final BitSet FOLLOW_HTML_in_css_emit3633 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_css_emit3641 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_period3661 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_CACHABLE_in_cachable3695 = new BitSet(new long[]{0x0000000004000002L});
    public static final BitSet FOLLOW_FOR_in_cachable3698 = new BitSet(new long[]{0x0000000000000100L});
    public static final BitSet FOLLOW_INT_in_cachable3702 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_period_in_cachable3706 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_EMIT_in_emit_block3728 = new BitSet(new long[]{0x0002000400080000L});
    public static final BitSet FOLLOW_HTML_in_emit_block3734 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_emit_block3742 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_JS_in_emit_block3750 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_META_in_meta_block3779 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_meta_block3781 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_must_be_one_in_meta_block3790 = new BitSet(new long[]{0x0002000000080000L});
    public static final BitSet FOLLOW_HTML_in_meta_block3796 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_STRING_in_meta_block3800 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_KEY_in_meta_block3814 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_meta_block3818 = new BitSet(new long[]{0x0000000000080020L});
    public static final BitSet FOLLOW_STRING_in_meta_block3824 = new BitSet(new long[]{0x00000000000800E0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_LEFT_CURL_in_meta_block3832 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_name_value_pair_in_meta_block3835 = new BitSet(new long[]{0x0000000080000040L});
    public static final BitSet FOLLOW_COMMA_in_meta_block3839 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_name_value_pair_in_meta_block3841 = new BitSet(new long[]{0x0000000080000040L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_meta_block3847 = new BitSet(new long[]{0x00000000000800E0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_AUTHZ_in_meta_block3859 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000400L});
    public static final BitSet FOLLOW_REQUIRE_in_meta_block3861 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_meta_block3863 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_LOGGING_in_meta_block3872 = new BitSet(new long[]{0x0000200000000000L,0x0000000000001000L});
    public static final BitSet FOLLOW_set_in_meta_block3876 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_USE_in_meta_block3887 = new BitSet(new long[]{0x0000000000000000L,0x000000000000C010L});
    public static final BitSet FOLLOW_set_in_meta_block3894 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_meta_block3900 = new BitSet(new long[]{0x0000000000080080L});
    public static final BitSet FOLLOW_STRING_in_meta_block3906 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_VAR_in_meta_block3912 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_MODULE_in_meta_block3927 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_meta_block3932 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000012B00L});
    public static final BitSet FOLLOW_ALIAS_in_meta_block3935 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_VAR_in_meta_block3939 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000002B00L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_meta_block3954 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_in_dispatch_block3985 = new BitSet(new long[]{0x0000000000000020L});
    public static final BitSet FOLLOW_LEFT_CURL_in_dispatch_block3989 = new BitSet(new long[]{0x00000000000000C0L});
    public static final BitSet FOLLOW_must_be_in_dispatch_block3993 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_dispatch_block3998 = new BitSet(new long[]{0x00000000000000C0L,0x0000000000020000L});
    public static final BitSet FOLLOW_RIGHT_SMALL_ARROW_in_dispatch_block4001 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_dispatch_block4005 = new BitSet(new long[]{0x00000000000000C0L});
    public static final BitSet FOLLOW_RIGHT_CURL_in_dispatch_block4016 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_name_value_pair4039 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_name_value_pair4041 = new BitSet(new long[]{0x1000000000080100L});
    public static final BitSet FOLLOW_INT_in_name_value_pair4049 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FLOAT_in_name_value_pair4060 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_name_value_pair4071 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_REX_in_regex4117 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred14_RuleSet335 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_emit_block_in_synpred15_RuleSet340 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred16_RuleSet343 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred17_RuleSet350 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred20_RuleSet360 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_persistent_expr_in_synpred29_RuleSet513 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_log_statement_in_synpred31_RuleSet530 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEMI_in_synpred47_RuleSet1135 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_in_synpred54_RuleSet1287 = new BitSet(new long[]{0x0000000020000000L});
    public static final BitSet FOLLOW_ARROW_RIGHT_in_synpred54_RuleSet1289 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_must_be_one_in_synpred83_RuleSet1701 = new BitSet(new long[]{0x0000180040000080L});
    public static final BitSet FOLLOW_event_or_in_synpred83_RuleSet1706 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_custom_event_in_synpred88_RuleSet1873 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred137_RuleSet2503 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_add_expr_in_synpred137_RuleSet2511 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred140_RuleSet2611 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_mult_expr_in_synpred140_RuleSet2619 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_timeframe_in_synpred147_RuleSet2709 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_synpred148_RuleSet2676 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_synpred148_RuleSet2680 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_synpred148_RuleSet2682 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred148_RuleSet2687 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_synpred148_RuleSet2689 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred148_RuleSet2693 = new BitSet(new long[]{0x0000000000000002L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_synpred148_RuleSet2709 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_SEEN_in_synpred154_RuleSet2717 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_synpred154_RuleSet2721 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_one_in_synpred154_RuleSet2725 = new BitSet(new long[]{0x0000000000080000L});
    public static final BitSet FOLLOW_STRING_in_synpred154_RuleSet2730 = new BitSet(new long[]{0x0000000000000080L});
    public static final BitSet FOLLOW_must_be_in_synpred154_RuleSet2733 = new BitSet(new long[]{0x0000000000100000L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred154_RuleSet2738 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_synpred154_RuleSet2740 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred154_RuleSet2744 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred161_RuleSet2765 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_synpred161_RuleSet2767 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred161_RuleSet2771 = new BitSet(new long[]{0x0040000000000400L});
    public static final BitSet FOLLOW_set_in_synpred161_RuleSet2787 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred161_RuleSet2795 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_synpred161_RuleSet2799 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred167_RuleSet2809 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_synpred167_RuleSet2811 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred167_RuleSet2815 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000008L});
    public static final BitSet FOLLOW_timeframe_in_synpred167_RuleSet2831 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_regex_in_synpred168_RuleSet2840 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred184_RuleSet3134 = new BitSet(new long[]{0x8000000000000000L});
    public static final BitSet FOLLOW_LEFT_BRACKET_in_synpred184_RuleSet3148 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred184_RuleSet3152 = new BitSet(new long[]{0x0000000000000000L,0x0000000000000001L});
    public static final BitSet FOLLOW_RIGHT_BRACKET_in_synpred184_RuleSet3154 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_VAR_DOMAIN_in_synpred190_RuleSet3169 = new BitSet(new long[]{0x0000000000200000L});
    public static final BitSet FOLLOW_COLON_in_synpred190_RuleSet3171 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred190_RuleSet3175 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_namespace_in_synpred210_RuleSet3274 = new BitSet(new long[]{0x0000000000101E80L});
    public static final BitSet FOLLOW_set_in_synpred210_RuleSet3278 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_synpred210_RuleSet3292 = new BitSet(new long[]{0xF604020140181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred210_RuleSet3297 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_synpred210_RuleSet3303 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred210_RuleSet3307 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_synpred210_RuleSet3316 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred218_RuleSet3331 = new BitSet(new long[]{0x0000000040000000L});
    public static final BitSet FOLLOW_LEFT_PAREN_in_synpred218_RuleSet3345 = new BitSet(new long[]{0xF604020140181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred218_RuleSet3350 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_COMMA_in_synpred218_RuleSet3355 = new BitSet(new long[]{0xF604020040181FA0L,0x0000000000000006L});
    public static final BitSet FOLLOW_expr_in_synpred218_RuleSet3359 = new BitSet(new long[]{0x0000000180000000L});
    public static final BitSet FOLLOW_RIGHT_PAREN_in_synpred218_RuleSet3368 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_set_in_synpred229_RuleSet3475 = new BitSet(new long[]{0x0000000000000002L});

}