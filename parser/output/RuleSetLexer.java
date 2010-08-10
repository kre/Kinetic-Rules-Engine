// $ANTLR 3.2 Sep 23, 2009 12:02:23 RuleSet.g 2010-08-09 09:33:34

	package com.kynetx;
	


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
public class RuleSetLexer extends Lexer {
    public static final int FUNCTION=49;
    public static final int ARROW_RIGHT=25;
    public static final int EXPONENT=85;
    public static final int LEFT_BRACKET=62;
    public static final int EMIT=69;
    public static final int OCTAL_ESC=88;
    public static final int FOR=22;
    public static final int PRE=36;
    public static final int FLOAT=59;
    public static final int NOT=40;
    public static final int HTML=48;
    public static final int CALLBACKS=11;
    public static final int AND=52;
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
    public static final int DOT=58;
    public static final int COMMENT=82;
    public static final int WITH=21;
    public static final int VAR_DOMAIN=16;
    public static final int AUTHZ=72;
    public static final int OR_OR=39;
    public static final int OTHER_OPERATORS=28;
    public static final int MULT_OP=55;
    public static final int CHOOSE=24;
    public static final int MARK=20;
    public static final int POUND=84;
    public static final int KEY=71;
    public static final int WEB=42;
    public static final int UNICODE_ESC=87;
    public static final int JS=33;
    public static final int ADD_OP=54;
    public static final int EVERY=23;
    public static final int ON=44;
    public static final int CACHABLE=68;
    public static final int HEX_DIGIT=86;
    public static final int MATCH=27;
    public static final int INT=8;
    public static final int LOGGING=74;
    public static final int MODULE=78;
    public static final int SEMI=9;
    public static final int TRUE=60;
    public static final int DTYPE=46;
    public static final int SEEN=57;
    public static final int CURRENT=64;
    public static final int COLON=17;
    public static final int COUNTER_OP=18;
    public static final int WS=83;
    public static final int WHEN=38;
    public static final int JAVASCRIPT=77;
    public static final int OR=51;
    public static final int PAGEVIEW=43;
    public static final int ALIAS=79;
    public static final int WITHIN=66;
    public static final int LEFT_PAREN=29;
    public static final int FORGET=19;
    public static final int FOREACH=37;
    public static final int USE=76;
    public static final int GLOBAL=45;
    public static final int FALSE=61;
    public static final int BETWEEN=41;
    public static final int STRING=15;

    	public boolean canbeReg = true;


    // delegates
    // delegators

    public RuleSetLexer() {;} 
    public RuleSetLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public RuleSetLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "RuleSet.g"; }

    // $ANTLR start "REX"
    public final void mREX() throws RecognitionException {
        try {
            int _type = REX;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1652:6: ( 're/' ( ( ESC_SEQ )=> ESC_SEQ | '\\\\/' | ~ ( '/' ) )* '/' ( 'g' | 'i' | 'm' )* )
            // RuleSet.g:1652:8: 're/' ( ( ESC_SEQ )=> ESC_SEQ | '\\\\/' | ~ ( '/' ) )* '/' ( 'g' | 'i' | 'm' )*
            {
            match("re/"); if (state.failed) return ;

            // RuleSet.g:1652:14: ( ( ESC_SEQ )=> ESC_SEQ | '\\\\/' | ~ ( '/' ) )*
            loop1:
            do {
                int alt1=4;
                alt1 = dfa1.predict(input);
                switch (alt1) {
            	case 1 :
            	    // RuleSet.g:1652:15: ( ESC_SEQ )=> ESC_SEQ
            	    {
            	    mESC_SEQ(); if (state.failed) return ;

            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:1652:36: '\\\\/'
            	    {
            	    match("\\/"); if (state.failed) return ;


            	    }
            	    break;
            	case 3 :
            	    // RuleSet.g:1652:44: ~ ( '/' )
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='.')||(input.LA(1)>='0' && input.LA(1)<='\uFFFF') ) {
            	        input.consume();
            	    state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return ;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);

            match('/'); if (state.failed) return ;
            // RuleSet.g:1652:59: ( 'g' | 'i' | 'm' )*
            loop2:
            do {
                int alt2=2;
                int LA2_0 = input.LA(1);

                if ( (LA2_0=='g'||LA2_0=='i'||LA2_0=='m') ) {
                    alt2=1;
                }


                switch (alt2) {
            	case 1 :
            	    // RuleSet.g:
            	    {
            	    if ( input.LA(1)=='g'||input.LA(1)=='i'||input.LA(1)=='m' ) {
            	        input.consume();
            	    state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return ;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop2;
                }
            } while (true);


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "REX"

    // $ANTLR start "ARROW_RIGHT"
    public final void mARROW_RIGHT() throws RecognitionException {
        try {
            int _type = ARROW_RIGHT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1670:2: ( '=>' )
            // RuleSet.g:1670:4: '=>'
            {
            match("=>"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ARROW_RIGHT"

    // $ANTLR start "PIPE"
    public final void mPIPE() throws RecognitionException {
        try {
            int _type = PIPE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1671:6: ( '|' )
            // RuleSet.g:1672:1: '|'
            {
            match('|'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PIPE"

    // $ANTLR start "SEMI"
    public final void mSEMI() throws RecognitionException {
        try {
            int _type = SEMI;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1674:6: ( ';' )
            // RuleSet.g:1674:8: ';'
            {
            match(';'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SEMI"

    // $ANTLR start "FUNCTION"
    public final void mFUNCTION() throws RecognitionException {
        try {
            int _type = FUNCTION;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1675:10: ( 'function' )
            // RuleSet.g:1675:12: 'function'
            {
            match("function"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FUNCTION"

    // $ANTLR start "EQUAL"
    public final void mEQUAL() throws RecognitionException {
        try {
            int _type = EQUAL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1676:7: ( '=' )
            // RuleSet.g:1676:8: '='
            {
            match('='); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "EQUAL"

    // $ANTLR start "OR"
    public final void mOR() throws RecognitionException {
        try {
            int _type = OR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1679:2: ( '||' )
            // RuleSet.g:1679:5: '||'
            {
            match("||"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OR"

    // $ANTLR start "AND"
    public final void mAND() throws RecognitionException {
        try {
            int _type = AND;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1681:2: ( '&&' )
            // RuleSet.g:1681:5: '&&'
            {
            match("&&"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "AND"

    // $ANTLR start "VAR_DOMAIN"
    public final void mVAR_DOMAIN() throws RecognitionException {
        try {
            int _type = VAR_DOMAIN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1683:11: ( 'ent' | 'app' )
            int alt3=2;
            int LA3_0 = input.LA(1);

            if ( (LA3_0=='e') ) {
                alt3=1;
            }
            else if ( (LA3_0=='a') ) {
                alt3=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 3, 0, input);

                throw nvae;
            }
            switch (alt3) {
                case 1 :
                    // RuleSet.g:1683:13: 'ent'
                    {
                    match("ent"); if (state.failed) return ;


                    }
                    break;
                case 2 :
                    // RuleSet.g:1683:21: 'app'
                    {
                    match("app"); if (state.failed) return ;


                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "VAR_DOMAIN"

    // $ANTLR start "WITH"
    public final void mWITH() throws RecognitionException {
        try {
            int _type = WITH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1686:6: ( 'with' )
            // RuleSet.g:1686:8: 'with'
            {
            match("with"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WITH"

    // $ANTLR start "USING"
    public final void mUSING() throws RecognitionException {
        try {
            int _type = USING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1687:7: ( 'using' )
            // RuleSet.g:1687:9: 'using'
            {
            match("using"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "USING"

    // $ANTLR start "SETTING"
    public final void mSETTING() throws RecognitionException {
        try {
            int _type = SETTING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1690:2: ( 'setting' )
            // RuleSet.g:1690:5: 'setting'
            {
            match("setting"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SETTING"

    // $ANTLR start "PRE"
    public final void mPRE() throws RecognitionException {
        try {
            int _type = PRE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1691:5: ( 'pre' )
            // RuleSet.g:1691:7: 'pre'
            {
            match("pre"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PRE"

    // $ANTLR start "FOREACH"
    public final void mFOREACH() throws RecognitionException {
        try {
            int _type = FOREACH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1693:8: ( 'foreach' )
            // RuleSet.g:1693:10: 'foreach'
            {
            match("foreach"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FOREACH"

    // $ANTLR start "WHEN"
    public final void mWHEN() throws RecognitionException {
        try {
            int _type = WHEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1695:6: ( 'when' )
            // RuleSet.g:1695:7: 'when'
            {
            match("when"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WHEN"

    // $ANTLR start "OR_OR"
    public final void mOR_OR() throws RecognitionException {
        try {
            int _type = OR_OR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1696:7: ( 'or' )
            // RuleSet.g:1696:9: 'or'
            {
            match("or"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OR_OR"

    // $ANTLR start "AND_AND"
    public final void mAND_AND() throws RecognitionException {
        try {
            int _type = AND_AND;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1698:9: ( 'and' )
            // RuleSet.g:1698:11: 'and'
            {
            match("and"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "AND_AND"

    // $ANTLR start "BETWEEN"
    public final void mBETWEEN() throws RecognitionException {
        try {
            int _type = BETWEEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1700:9: ( 'between' )
            // RuleSet.g:1700:11: 'between'
            {
            match("between"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "BETWEEN"

    // $ANTLR start "WEB"
    public final void mWEB() throws RecognitionException {
        try {
            int _type = WEB;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1702:4: ( 'web' )
            // RuleSet.g:1702:6: 'web'
            {
            match("web"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WEB"

    // $ANTLR start "PAGEVIEW"
    public final void mPAGEVIEW() throws RecognitionException {
        try {
            int _type = PAGEVIEW;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1703:10: ( 'pageview' )
            // RuleSet.g:1703:11: 'pageview'
            {
            match("pageview"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PAGEVIEW"

    // $ANTLR start "LEFT_SMALL_ARROW"
    public final void mLEFT_SMALL_ARROW() throws RecognitionException {
        try {
            int _type = LEFT_SMALL_ARROW;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1707:2: ( '<-' )
            // RuleSet.g:1707:5: '<-'
            {
            match("<-"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LEFT_SMALL_ARROW"

    // $ANTLR start "RIGHT_SMALL_ARROW"
    public final void mRIGHT_SMALL_ARROW() throws RecognitionException {
        try {
            int _type = RIGHT_SMALL_ARROW;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1710:2: ( '->' )
            // RuleSet.g:1710:5: '->'
            {
            match("->"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RIGHT_SMALL_ARROW"

    // $ANTLR start "GLOBAL"
    public final void mGLOBAL() throws RecognitionException {
        try {
            int _type = GLOBAL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1711:7: ( 'global' )
            // RuleSet.g:1711:9: 'global'
            {
            match("global"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "GLOBAL"

    // $ANTLR start "DTYPE"
    public final void mDTYPE() throws RecognitionException {
        try {
            int _type = DTYPE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1713:2: ( ( 'JSON' | 'XML' | 'RSS' | 'HTML' ) )
            // RuleSet.g:1713:3: ( 'JSON' | 'XML' | 'RSS' | 'HTML' )
            {
            // RuleSet.g:1713:3: ( 'JSON' | 'XML' | 'RSS' | 'HTML' )
            int alt4=4;
            switch ( input.LA(1) ) {
            case 'J':
                {
                alt4=1;
                }
                break;
            case 'X':
                {
                alt4=2;
                }
                break;
            case 'R':
                {
                alt4=3;
                }
                break;
            case 'H':
                {
                alt4=4;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 4, 0, input);

                throw nvae;
            }

            switch (alt4) {
                case 1 :
                    // RuleSet.g:1713:4: 'JSON'
                    {
                    match("JSON"); if (state.failed) return ;


                    }
                    break;
                case 2 :
                    // RuleSet.g:1713:11: 'XML'
                    {
                    match("XML"); if (state.failed) return ;


                    }
                    break;
                case 3 :
                    // RuleSet.g:1713:17: 'RSS'
                    {
                    match("RSS"); if (state.failed) return ;


                    }
                    break;
                case 4 :
                    // RuleSet.g:1713:23: 'HTML'
                    {
                    match("HTML"); if (state.failed) return ;


                    }
                    break;

            }


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DTYPE"

    // $ANTLR start "PREDOP"
    public final void mPREDOP() throws RecognitionException {
        try {
            int _type = PREDOP;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1715:7: ( '<=' | '>=' | '<' | '>' | '==' | '!=' | 'eq' | 'neq' | 'like' )
            int alt5=9;
            alt5 = dfa5.predict(input);
            switch (alt5) {
                case 1 :
                    // RuleSet.g:1715:9: '<='
                    {
                    match("<="); if (state.failed) return ;


                    }
                    break;
                case 2 :
                    // RuleSet.g:1715:16: '>='
                    {
                    match(">="); if (state.failed) return ;


                    }
                    break;
                case 3 :
                    // RuleSet.g:1715:23: '<'
                    {
                    match('<'); if (state.failed) return ;

                    }
                    break;
                case 4 :
                    // RuleSet.g:1715:29: '>'
                    {
                    match('>'); if (state.failed) return ;

                    }
                    break;
                case 5 :
                    // RuleSet.g:1715:35: '=='
                    {
                    match("=="); if (state.failed) return ;


                    }
                    break;
                case 6 :
                    // RuleSet.g:1715:42: '!='
                    {
                    match("!="); if (state.failed) return ;


                    }
                    break;
                case 7 :
                    // RuleSet.g:1715:49: 'eq'
                    {
                    match("eq"); if (state.failed) return ;


                    }
                    break;
                case 8 :
                    // RuleSet.g:1715:56: 'neq'
                    {
                    match("neq"); if (state.failed) return ;


                    }
                    break;
                case 9 :
                    // RuleSet.g:1715:64: 'like'
                    {
                    match("like"); if (state.failed) return ;


                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "PREDOP"

    // $ANTLR start "ADD_OP"
    public final void mADD_OP() throws RecognitionException {
        try {
            int _type = ADD_OP;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1717:7: ( '+' | '-' )
            // RuleSet.g:
            {
            if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ADD_OP"

    // $ANTLR start "CALLBACKS"
    public final void mCALLBACKS() throws RecognitionException {
        try {
            int _type = CALLBACKS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1719:11: ( 'callbacks' )
            // RuleSet.g:1719:13: 'callbacks'
            {
            match("callbacks"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "CALLBACKS"

    // $ANTLR start "SUCCESS"
    public final void mSUCCESS() throws RecognitionException {
        try {
            int _type = SUCCESS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1720:9: ( 'success' )
            // RuleSet.g:1720:11: 'success'
            {
            match("success"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SUCCESS"

    // $ANTLR start "FAILURE"
    public final void mFAILURE() throws RecognitionException {
        try {
            int _type = FAILURE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1722:2: ( 'failure' )
            // RuleSet.g:1722:5: 'failure'
            {
            match("failure"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FAILURE"

    // $ANTLR start "FORGET"
    public final void mFORGET() throws RecognitionException {
        try {
            int _type = FORGET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1724:7: ( 'forget' )
            // RuleSet.g:1724:9: 'forget'
            {
            match("forget"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FORGET"

    // $ANTLR start "MARK"
    public final void mMARK() throws RecognitionException {
        try {
            int _type = MARK;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1725:5: ( 'mark' )
            // RuleSet.g:1725:6: 'mark'
            {
            match("mark"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MARK"

    // $ANTLR start "COUNTER_OP"
    public final void mCOUNTER_OP() throws RecognitionException {
        try {
            int _type = COUNTER_OP;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1728:2: ( '+=' | '-=' )
            int alt6=2;
            int LA6_0 = input.LA(1);

            if ( (LA6_0=='+') ) {
                alt6=1;
            }
            else if ( (LA6_0=='-') ) {
                alt6=2;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 6, 0, input);

                throw nvae;
            }
            switch (alt6) {
                case 1 :
                    // RuleSet.g:1729:2: '+='
                    {
                    match("+="); if (state.failed) return ;


                    }
                    break;
                case 2 :
                    // RuleSet.g:1730:11: '-='
                    {
                    match("-="); if (state.failed) return ;


                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COUNTER_OP"

    // $ANTLR start "IF"
    public final void mIF() throws RecognitionException {
        try {
            int _type = IF;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1732:3: ( 'if' )
            // RuleSet.g:1732:4: 'if'
            {
            match("if"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "IF"

    // $ANTLR start "CHOOSE"
    public final void mCHOOSE() throws RecognitionException {
        try {
            int _type = CHOOSE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1733:9: ( 'choose' )
            // RuleSet.g:1733:11: 'choose'
            {
            match("choose"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "CHOOSE"

    // $ANTLR start "EVERY"
    public final void mEVERY() throws RecognitionException {
        try {
            int _type = EVERY;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1734:8: ( 'every' )
            // RuleSet.g:1734:10: 'every'
            {
            match("every"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "EVERY"

    // $ANTLR start "COMMENT"
    public final void mCOMMENT() throws RecognitionException {
        try {
            int _type = COMMENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1739:5: ( '//' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n' | '/*' ( options {greedy=false; } : . )* '*/' )
            int alt10=2;
            int LA10_0 = input.LA(1);

            if ( (LA10_0=='/') ) {
                int LA10_1 = input.LA(2);

                if ( (LA10_1=='/') ) {
                    alt10=1;
                }
                else if ( (LA10_1=='*') ) {
                    alt10=2;
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return ;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 10, 1, input);

                    throw nvae;
                }
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 10, 0, input);

                throw nvae;
            }
            switch (alt10) {
                case 1 :
                    // RuleSet.g:1739:9: '//' (~ ( '\\n' | '\\r' ) )* ( '\\r' )? '\\n'
                    {
                    match("//"); if (state.failed) return ;

                    // RuleSet.g:1739:14: (~ ( '\\n' | '\\r' ) )*
                    loop7:
                    do {
                        int alt7=2;
                        int LA7_0 = input.LA(1);

                        if ( ((LA7_0>='\u0000' && LA7_0<='\t')||(LA7_0>='\u000B' && LA7_0<='\f')||(LA7_0>='\u000E' && LA7_0<='\uFFFF')) ) {
                            alt7=1;
                        }


                        switch (alt7) {
                    	case 1 :
                    	    // RuleSet.g:1739:14: ~ ( '\\n' | '\\r' )
                    	    {
                    	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='\t')||(input.LA(1)>='\u000B' && input.LA(1)<='\f')||(input.LA(1)>='\u000E' && input.LA(1)<='\uFFFF') ) {
                    	        input.consume();
                    	    state.failed=false;
                    	    }
                    	    else {
                    	        if (state.backtracking>0) {state.failed=true; return ;}
                    	        MismatchedSetException mse = new MismatchedSetException(null,input);
                    	        recover(mse);
                    	        throw mse;}


                    	    }
                    	    break;

                    	default :
                    	    break loop7;
                        }
                    } while (true);

                    // RuleSet.g:1739:28: ( '\\r' )?
                    int alt8=2;
                    int LA8_0 = input.LA(1);

                    if ( (LA8_0=='\r') ) {
                        alt8=1;
                    }
                    switch (alt8) {
                        case 1 :
                            // RuleSet.g:1739:28: '\\r'
                            {
                            match('\r'); if (state.failed) return ;

                            }
                            break;

                    }

                    match('\n'); if (state.failed) return ;
                    if ( state.backtracking==0 ) {
                      _channel=HIDDEN;
                    }

                    }
                    break;
                case 2 :
                    // RuleSet.g:1740:9: '/*' ( options {greedy=false; } : . )* '*/'
                    {
                    match("/*"); if (state.failed) return ;

                    // RuleSet.g:1740:14: ( options {greedy=false; } : . )*
                    loop9:
                    do {
                        int alt9=2;
                        int LA9_0 = input.LA(1);

                        if ( (LA9_0=='*') ) {
                            int LA9_1 = input.LA(2);

                            if ( (LA9_1=='/') ) {
                                alt9=2;
                            }
                            else if ( ((LA9_1>='\u0000' && LA9_1<='.')||(LA9_1>='0' && LA9_1<='\uFFFF')) ) {
                                alt9=1;
                            }


                        }
                        else if ( ((LA9_0>='\u0000' && LA9_0<=')')||(LA9_0>='+' && LA9_0<='\uFFFF')) ) {
                            alt9=1;
                        }


                        switch (alt9) {
                    	case 1 :
                    	    // RuleSet.g:1740:42: .
                    	    {
                    	    matchAny(); if (state.failed) return ;

                    	    }
                    	    break;

                    	default :
                    	    break loop9;
                        }
                    } while (true);

                    match("*/"); if (state.failed) return ;

                    if ( state.backtracking==0 ) {
                      _channel=HIDDEN;
                    }

                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COMMENT"

    // $ANTLR start "WS"
    public final void mWS() throws RecognitionException {
        try {
            int _type = WS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1744:5: ( ( ' ' | '\\t' | '\\r' | '\\n' ) )
            // RuleSet.g:1744:9: ( ' ' | '\\t' | '\\r' | '\\n' )
            {
            if ( (input.LA(1)>='\t' && input.LA(1)<='\n')||input.LA(1)=='\r'||input.LA(1)==' ' ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}

            if ( state.backtracking==0 ) {
              _channel=HIDDEN;
            }

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WS"

    // $ANTLR start "STRING"
    public final void mSTRING() throws RecognitionException {
        try {
            int _type = STRING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1752:5: ( '\"' ( '\\\\\"' | ~ ( '\"' ) )* '\"' )
            // RuleSet.g:1752:8: '\"' ( '\\\\\"' | ~ ( '\"' ) )* '\"'
            {
            match('\"'); if (state.failed) return ;
            // RuleSet.g:1752:12: ( '\\\\\"' | ~ ( '\"' ) )*
            loop11:
            do {
                int alt11=3;
                int LA11_0 = input.LA(1);

                if ( (LA11_0=='\\') ) {
                    int LA11_2 = input.LA(2);

                    if ( (LA11_2=='\"') ) {
                        int LA11_4 = input.LA(3);

                        if ( ((LA11_4>='\u0000' && LA11_4<='\uFFFF')) ) {
                            alt11=1;
                        }

                        else {
                            alt11=2;
                        }

                    }
                    else if ( ((LA11_2>='\u0000' && LA11_2<='!')||(LA11_2>='#' && LA11_2<='\uFFFF')) ) {
                        alt11=2;
                    }


                }
                else if ( ((LA11_0>='\u0000' && LA11_0<='!')||(LA11_0>='#' && LA11_0<='[')||(LA11_0>=']' && LA11_0<='\uFFFF')) ) {
                    alt11=2;
                }


                switch (alt11) {
            	case 1 :
            	    // RuleSet.g:1752:14: '\\\\\"'
            	    {
            	    match("\\\""); if (state.failed) return ;


            	    }
            	    break;
            	case 2 :
            	    // RuleSet.g:1752:22: ~ ( '\"' )
            	    {
            	    if ( (input.LA(1)>='\u0000' && input.LA(1)<='!')||(input.LA(1)>='#' && input.LA(1)<='\uFFFF') ) {
            	        input.consume();
            	    state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return ;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop11;
                }
            } while (true);

            match('\"'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "STRING"

    // $ANTLR start "POUND"
    public final void mPOUND() throws RecognitionException {
        try {
            // RuleSet.g:1756:2: ( '#' )
            // RuleSet.g:1756:5: '#'
            {
            match('#'); if (state.failed) return ;

            }

        }
        finally {
        }
    }
    // $ANTLR end "POUND"

    // $ANTLR start "HTML"
    public final void mHTML() throws RecognitionException {
        try {
            int _type = HTML;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1761:2: ( '<<' ( options {greedy=false; } : . )* '>>' )
            // RuleSet.g:1761:4: '<<' ( options {greedy=false; } : . )* '>>'
            {
            match("<<"); if (state.failed) return ;

            // RuleSet.g:1761:9: ( options {greedy=false; } : . )*
            loop12:
            do {
                int alt12=2;
                int LA12_0 = input.LA(1);

                if ( (LA12_0=='>') ) {
                    int LA12_1 = input.LA(2);

                    if ( (LA12_1=='>') ) {
                        alt12=2;
                    }
                    else if ( ((LA12_1>='\u0000' && LA12_1<='=')||(LA12_1>='?' && LA12_1<='\uFFFF')) ) {
                        alt12=1;
                    }


                }
                else if ( ((LA12_0>='\u0000' && LA12_0<='=')||(LA12_0>='?' && LA12_0<='\uFFFF')) ) {
                    alt12=1;
                }


                switch (alt12) {
            	case 1 :
            	    // RuleSet.g:1761:37: .
            	    {
            	    matchAny(); if (state.failed) return ;

            	    }
            	    break;

            	default :
            	    break loop12;
                }
            } while (true);

            match(">>"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "HTML"

    // $ANTLR start "JS"
    public final void mJS() throws RecognitionException {
        try {
            int _type = JS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1765:2: ( '<|' ( options {greedy=false; } : . )* '|>' )
            // RuleSet.g:1765:4: '<|' ( options {greedy=false; } : . )* '|>'
            {
            match("<|"); if (state.failed) return ;

            // RuleSet.g:1765:9: ( options {greedy=false; } : . )*
            loop13:
            do {
                int alt13=2;
                int LA13_0 = input.LA(1);

                if ( (LA13_0=='|') ) {
                    int LA13_1 = input.LA(2);

                    if ( (LA13_1=='>') ) {
                        alt13=2;
                    }
                    else if ( ((LA13_1>='\u0000' && LA13_1<='=')||(LA13_1>='?' && LA13_1<='\uFFFF')) ) {
                        alt13=1;
                    }


                }
                else if ( ((LA13_0>='\u0000' && LA13_0<='{')||(LA13_0>='}' && LA13_0<='\uFFFF')) ) {
                    alt13=1;
                }


                switch (alt13) {
            	case 1 :
            	    // RuleSet.g:1765:37: .
            	    {
            	    matchAny(); if (state.failed) return ;

            	    }
            	    break;

            	default :
            	    break loop13;
                }
            } while (true);

            match("|>"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "JS"

    // $ANTLR start "EXPONENT"
    public final void mEXPONENT() throws RecognitionException {
        try {
            // RuleSet.g:1769:10: ( ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+ )
            // RuleSet.g:1769:12: ( 'e' | 'E' ) ( '+' | '-' )? ( '0' .. '9' )+
            {
            if ( input.LA(1)=='E'||input.LA(1)=='e' ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}

            // RuleSet.g:1769:22: ( '+' | '-' )?
            int alt14=2;
            int LA14_0 = input.LA(1);

            if ( (LA14_0=='+'||LA14_0=='-') ) {
                alt14=1;
            }
            switch (alt14) {
                case 1 :
                    // RuleSet.g:
                    {
                    if ( input.LA(1)=='+'||input.LA(1)=='-' ) {
                        input.consume();
                    state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return ;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        recover(mse);
                        throw mse;}


                    }
                    break;

            }

            // RuleSet.g:1769:33: ( '0' .. '9' )+
            int cnt15=0;
            loop15:
            do {
                int alt15=2;
                int LA15_0 = input.LA(1);

                if ( ((LA15_0>='0' && LA15_0<='9')) ) {
                    alt15=1;
                }


                switch (alt15) {
            	case 1 :
            	    // RuleSet.g:1769:34: '0' .. '9'
            	    {
            	    matchRange('0','9'); if (state.failed) return ;

            	    }
            	    break;

            	default :
            	    if ( cnt15 >= 1 ) break loop15;
            	    if (state.backtracking>0) {state.failed=true; return ;}
                        EarlyExitException eee =
                            new EarlyExitException(15, input);
                        throw eee;
                }
                cnt15++;
            } while (true);


            }

        }
        finally {
        }
    }
    // $ANTLR end "EXPONENT"

    // $ANTLR start "HEX_DIGIT"
    public final void mHEX_DIGIT() throws RecognitionException {
        try {
            // RuleSet.g:1772:11: ( ( '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' ) )
            // RuleSet.g:1772:13: ( '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' )
            {
            if ( (input.LA(1)>='0' && input.LA(1)<='9')||(input.LA(1)>='A' && input.LA(1)<='F')||(input.LA(1)>='a' && input.LA(1)<='f') ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

        }
        finally {
        }
    }
    // $ANTLR end "HEX_DIGIT"

    // $ANTLR start "ESC_SEQ"
    public final void mESC_SEQ() throws RecognitionException {
        try {
            int _type = ESC_SEQ;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1777:5: ( '\\\\' ( 'b' | 'd' | 't' | 'n' | 'f' | 'r' | '\\\"' | '\\'' | '\\\\' | '.' | 'w' | 's' | '?' | '(' | ')' | '-' ) | UNICODE_ESC | OCTAL_ESC )
            int alt16=3;
            int LA16_0 = input.LA(1);

            if ( (LA16_0=='\\') ) {
                switch ( input.LA(2) ) {
                case '\"':
                case '\'':
                case '(':
                case ')':
                case '-':
                case '.':
                case '?':
                case '\\':
                case 'b':
                case 'd':
                case 'f':
                case 'n':
                case 'r':
                case 's':
                case 't':
                case 'w':
                    {
                    alt16=1;
                    }
                    break;
                case 'u':
                    {
                    alt16=2;
                    }
                    break;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                    {
                    alt16=3;
                    }
                    break;
                default:
                    if (state.backtracking>0) {state.failed=true; return ;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 16, 1, input);

                    throw nvae;
                }

            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 16, 0, input);

                throw nvae;
            }
            switch (alt16) {
                case 1 :
                    // RuleSet.g:1777:9: '\\\\' ( 'b' | 'd' | 't' | 'n' | 'f' | 'r' | '\\\"' | '\\'' | '\\\\' | '.' | 'w' | 's' | '?' | '(' | ')' | '-' )
                    {
                    match('\\'); if (state.failed) return ;
                    if ( input.LA(1)=='\"'||(input.LA(1)>='\'' && input.LA(1)<=')')||(input.LA(1)>='-' && input.LA(1)<='.')||input.LA(1)=='?'||input.LA(1)=='\\'||input.LA(1)=='b'||input.LA(1)=='d'||input.LA(1)=='f'||input.LA(1)=='n'||(input.LA(1)>='r' && input.LA(1)<='t')||input.LA(1)=='w' ) {
                        input.consume();
                    state.failed=false;
                    }
                    else {
                        if (state.backtracking>0) {state.failed=true; return ;}
                        MismatchedSetException mse = new MismatchedSetException(null,input);
                        recover(mse);
                        throw mse;}


                    }
                    break;
                case 2 :
                    // RuleSet.g:1778:9: UNICODE_ESC
                    {
                    mUNICODE_ESC(); if (state.failed) return ;

                    }
                    break;
                case 3 :
                    // RuleSet.g:1779:9: OCTAL_ESC
                    {
                    mOCTAL_ESC(); if (state.failed) return ;

                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ESC_SEQ"

    // $ANTLR start "OCTAL_ESC"
    public final void mOCTAL_ESC() throws RecognitionException {
        try {
            // RuleSet.g:1792:5: ( '\\\\' ( '0' .. '3' ) ( '0' .. '7' ) ( '0' .. '7' ) | '\\\\' ( '0' .. '7' ) ( '0' .. '7' ) | '\\\\' ( '0' .. '7' ) )
            int alt17=3;
            int LA17_0 = input.LA(1);

            if ( (LA17_0=='\\') ) {
                int LA17_1 = input.LA(2);

                if ( ((LA17_1>='0' && LA17_1<='3')) ) {
                    int LA17_2 = input.LA(3);

                    if ( ((LA17_2>='0' && LA17_2<='7')) ) {
                        int LA17_4 = input.LA(4);

                        if ( ((LA17_4>='0' && LA17_4<='7')) ) {
                            alt17=1;
                        }
                        else {
                            alt17=2;}
                    }
                    else {
                        alt17=3;}
                }
                else if ( ((LA17_1>='4' && LA17_1<='7')) ) {
                    int LA17_3 = input.LA(3);

                    if ( ((LA17_3>='0' && LA17_3<='7')) ) {
                        alt17=2;
                    }
                    else {
                        alt17=3;}
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return ;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 17, 1, input);

                    throw nvae;
                }
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 17, 0, input);

                throw nvae;
            }
            switch (alt17) {
                case 1 :
                    // RuleSet.g:1792:9: '\\\\' ( '0' .. '3' ) ( '0' .. '7' ) ( '0' .. '7' )
                    {
                    match('\\'); if (state.failed) return ;
                    // RuleSet.g:1792:14: ( '0' .. '3' )
                    // RuleSet.g:1792:15: '0' .. '3'
                    {
                    matchRange('0','3'); if (state.failed) return ;

                    }

                    // RuleSet.g:1792:25: ( '0' .. '7' )
                    // RuleSet.g:1792:26: '0' .. '7'
                    {
                    matchRange('0','7'); if (state.failed) return ;

                    }

                    // RuleSet.g:1792:36: ( '0' .. '7' )
                    // RuleSet.g:1792:37: '0' .. '7'
                    {
                    matchRange('0','7'); if (state.failed) return ;

                    }


                    }
                    break;
                case 2 :
                    // RuleSet.g:1793:9: '\\\\' ( '0' .. '7' ) ( '0' .. '7' )
                    {
                    match('\\'); if (state.failed) return ;
                    // RuleSet.g:1793:14: ( '0' .. '7' )
                    // RuleSet.g:1793:15: '0' .. '7'
                    {
                    matchRange('0','7'); if (state.failed) return ;

                    }

                    // RuleSet.g:1793:25: ( '0' .. '7' )
                    // RuleSet.g:1793:26: '0' .. '7'
                    {
                    matchRange('0','7'); if (state.failed) return ;

                    }


                    }
                    break;
                case 3 :
                    // RuleSet.g:1794:9: '\\\\' ( '0' .. '7' )
                    {
                    match('\\'); if (state.failed) return ;
                    // RuleSet.g:1794:14: ( '0' .. '7' )
                    // RuleSet.g:1794:15: '0' .. '7'
                    {
                    matchRange('0','7'); if (state.failed) return ;

                    }


                    }
                    break;

            }
        }
        finally {
        }
    }
    // $ANTLR end "OCTAL_ESC"

    // $ANTLR start "UNICODE_ESC"
    public final void mUNICODE_ESC() throws RecognitionException {
        try {
            // RuleSet.g:1799:5: ( '\\\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT )
            // RuleSet.g:1799:9: '\\\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
            {
            match('\\'); if (state.failed) return ;
            match('u'); if (state.failed) return ;
            mHEX_DIGIT(); if (state.failed) return ;
            mHEX_DIGIT(); if (state.failed) return ;
            mHEX_DIGIT(); if (state.failed) return ;
            mHEX_DIGIT(); if (state.failed) return ;

            }

        }
        finally {
        }
    }
    // $ANTLR end "UNICODE_ESC"

    // $ANTLR start "RULE_SET"
    public final void mRULE_SET() throws RecognitionException {
        try {
            int _type = RULE_SET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1811:2: ( 'ruleset' )
            // RuleSet.g:1811:4: 'ruleset'
            {
            match("ruleset"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RULE_SET"

    // $ANTLR start "MULT_OP"
    public final void mMULT_OP() throws RecognitionException {
        try {
            int _type = MULT_OP;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1814:8: ( '*' | '/' | '%' )
            // RuleSet.g:
            {
            if ( input.LA(1)=='%'||input.LA(1)=='*'||input.LA(1)=='/' ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MULT_OP"

    // $ANTLR start "DOT"
    public final void mDOT() throws RecognitionException {
        try {
            int _type = DOT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1819:2: ( '.' )
            // RuleSet.g:1819:5: '.'
            {
            match('.'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "DOT"

    // $ANTLR start "MATCH"
    public final void mMATCH() throws RecognitionException {
        try {
            int _type = MATCH;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1822:2: ( 'match' )
            // RuleSet.g:1822:4: 'match'
            {
            match("match"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MATCH"

    // $ANTLR start "REPLACE"
    public final void mREPLACE() throws RecognitionException {
        try {
            int _type = REPLACE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1825:2: ( 'replace' )
            // RuleSet.g:1825:4: 'replace'
            {
            match("replace"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "REPLACE"

    // $ANTLR start "OTHER_OPERATORS"
    public final void mOTHER_OPERATORS() throws RecognitionException {
        try {
            int _type = OTHER_OPERATORS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1828:2: ( 'pick' | 'length' | 'as' | 'head' | 'tail' | 'sort' | 'filter' | 'map' | 'uc' | 'lc' | 'split' | 'join' | 'query' | 'has' | 'union' | 'difference' | 'intersection' | 'unique' | 'once' | 'duplicates' )
            int alt18=20;
            alt18 = dfa18.predict(input);
            switch (alt18) {
                case 1 :
                    // RuleSet.g:1828:5: 'pick'
                    {
                    match("pick"); if (state.failed) return ;


                    }
                    break;
                case 2 :
                    // RuleSet.g:1828:12: 'length'
                    {
                    match("length"); if (state.failed) return ;


                    }
                    break;
                case 3 :
                    // RuleSet.g:1828:21: 'as'
                    {
                    match("as"); if (state.failed) return ;


                    }
                    break;
                case 4 :
                    // RuleSet.g:1828:26: 'head'
                    {
                    match("head"); if (state.failed) return ;


                    }
                    break;
                case 5 :
                    // RuleSet.g:1828:33: 'tail'
                    {
                    match("tail"); if (state.failed) return ;


                    }
                    break;
                case 6 :
                    // RuleSet.g:1828:40: 'sort'
                    {
                    match("sort"); if (state.failed) return ;


                    }
                    break;
                case 7 :
                    // RuleSet.g:1829:9: 'filter'
                    {
                    match("filter"); if (state.failed) return ;


                    }
                    break;
                case 8 :
                    // RuleSet.g:1829:18: 'map'
                    {
                    match("map"); if (state.failed) return ;


                    }
                    break;
                case 9 :
                    // RuleSet.g:1829:24: 'uc'
                    {
                    match("uc"); if (state.failed) return ;


                    }
                    break;
                case 10 :
                    // RuleSet.g:1829:29: 'lc'
                    {
                    match("lc"); if (state.failed) return ;


                    }
                    break;
                case 11 :
                    // RuleSet.g:1829:35: 'split'
                    {
                    match("split"); if (state.failed) return ;


                    }
                    break;
                case 12 :
                    // RuleSet.g:1829:45: 'join'
                    {
                    match("join"); if (state.failed) return ;


                    }
                    break;
                case 13 :
                    // RuleSet.g:1829:54: 'query'
                    {
                    match("query"); if (state.failed) return ;


                    }
                    break;
                case 14 :
                    // RuleSet.g:1830:10: 'has'
                    {
                    match("has"); if (state.failed) return ;


                    }
                    break;
                case 15 :
                    // RuleSet.g:1830:18: 'union'
                    {
                    match("union"); if (state.failed) return ;


                    }
                    break;
                case 16 :
                    // RuleSet.g:1830:28: 'difference'
                    {
                    match("difference"); if (state.failed) return ;


                    }
                    break;
                case 17 :
                    // RuleSet.g:1830:43: 'intersection'
                    {
                    match("intersection"); if (state.failed) return ;


                    }
                    break;
                case 18 :
                    // RuleSet.g:1830:60: 'unique'
                    {
                    match("unique"); if (state.failed) return ;


                    }
                    break;
                case 19 :
                    // RuleSet.g:1830:71: 'once'
                    {
                    match("once"); if (state.failed) return ;


                    }
                    break;
                case 20 :
                    // RuleSet.g:1831:10: 'duplicates'
                    {
                    match("duplicates"); if (state.failed) return ;


                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OTHER_OPERATORS"

    // $ANTLR start "TRUE"
    public final void mTRUE() throws RecognitionException {
        try {
            int _type = TRUE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1834:6: ( 'true' )
            // RuleSet.g:1834:7: 'true'
            {
            match("true"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "TRUE"

    // $ANTLR start "FALSE"
    public final void mFALSE() throws RecognitionException {
        try {
            int _type = FALSE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1835:7: ( 'false' )
            // RuleSet.g:1835:8: 'false'
            {
            match("false"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FALSE"

    // $ANTLR start "CURRENT"
    public final void mCURRENT() throws RecognitionException {
        try {
            int _type = CURRENT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1836:8: ( 'current' )
            // RuleSet.g:1836:10: 'current'
            {
            match("current"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "CURRENT"

    // $ANTLR start "KEY"
    public final void mKEY() throws RecognitionException {
        try {
            int _type = KEY;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1839:2: ( 'key' )
            // RuleSet.g:1839:4: 'key'
            {
            match("key"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "KEY"

    // $ANTLR start "AUTHZ"
    public final void mAUTHZ() throws RecognitionException {
        try {
            int _type = AUTHZ;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1842:2: ( 'authz' )
            // RuleSet.g:1842:4: 'authz'
            {
            match("authz"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "AUTHZ"

    // $ANTLR start "REQUIRE"
    public final void mREQUIRE() throws RecognitionException {
        try {
            int _type = REQUIRE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1846:2: ( 'require' )
            // RuleSet.g:1847:3: 'require'
            {
            match("require"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "REQUIRE"

    // $ANTLR start "LOGGING"
    public final void mLOGGING() throws RecognitionException {
        try {
            int _type = LOGGING;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1850:2: ( 'logging' )
            // RuleSet.g:1850:3: 'logging'
            {
            match("logging"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LOGGING"

    // $ANTLR start "USE"
    public final void mUSE() throws RecognitionException {
        try {
            int _type = USE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1853:2: ( 'use' )
            // RuleSet.g:1853:4: 'use'
            {
            match("use"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "USE"

    // $ANTLR start "CSS"
    public final void mCSS() throws RecognitionException {
        try {
            int _type = CSS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1856:2: ( 'css' )
            // RuleSet.g:1856:3: 'css'
            {
            match("css"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "CSS"

    // $ANTLR start "JAVASCRIPT"
    public final void mJAVASCRIPT() throws RecognitionException {
        try {
            int _type = JAVASCRIPT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1859:2: ( 'javascript' )
            // RuleSet.g:1859:3: 'javascript'
            {
            match("javascript"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "JAVASCRIPT"

    // $ANTLR start "META"
    public final void mMETA() throws RecognitionException {
        try {
            int _type = META;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1862:2: ( 'meta' )
            // RuleSet.g:1862:4: 'meta'
            {
            match("meta"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "META"

    // $ANTLR start "ON"
    public final void mON() throws RecognitionException {
        try {
            int _type = ON;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1866:2: ( 'on' )
            // RuleSet.g:1866:5: 'on'
            {
            match("on"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ON"

    // $ANTLR start "OFF"
    public final void mOFF() throws RecognitionException {
        try {
            int _type = OFF;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1868:6: ( 'off' )
            // RuleSet.g:1868:8: 'off'
            {
            match("off"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "OFF"

    // $ANTLR start "MODULE"
    public final void mMODULE() throws RecognitionException {
        try {
            int _type = MODULE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1872:2: ( 'module' )
            // RuleSet.g:1872:4: 'module'
            {
            match("module"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "MODULE"

    // $ANTLR start "ALIAS"
    public final void mALIAS() throws RecognitionException {
        try {
            int _type = ALIAS;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1875:2: ( 'alias' )
            // RuleSet.g:1875:3: 'alias'
            {
            match("alias"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "ALIAS"

    // $ANTLR start "EMIT"
    public final void mEMIT() throws RecognitionException {
        try {
            int _type = EMIT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1880:2: ( 'emit' )
            // RuleSet.g:1880:4: 'emit'
            {
            match("emit"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "EMIT"

    // $ANTLR start "CACHABLE"
    public final void mCACHABLE() throws RecognitionException {
        try {
            int _type = CACHABLE;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1884:2: ( 'cachable' )
            // RuleSet.g:1884:3: 'cachable'
            {
            match("cachable"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "CACHABLE"

    // $ANTLR start "FOR"
    public final void mFOR() throws RecognitionException {
        try {
            int _type = FOR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1888:2: ( 'for' )
            // RuleSet.g:1888:4: 'for'
            {
            match("for"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FOR"

    // $ANTLR start "WITHIN"
    public final void mWITHIN() throws RecognitionException {
        try {
            int _type = WITHIN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1892:2: ( 'within' )
            // RuleSet.g:1892:4: 'within'
            {
            match("within"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "WITHIN"

    // $ANTLR start "COLON"
    public final void mCOLON() throws RecognitionException {
        try {
            int _type = COLON;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1896:2: ( ':' )
            // RuleSet.g:1896:5: ':'
            {
            match(':'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COLON"

    // $ANTLR start "HISTORY"
    public final void mHISTORY() throws RecognitionException {
        try {
            int _type = HISTORY;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1899:2: ( 'history' )
            // RuleSet.g:1900:2: 'history'
            {
            match("history"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "HISTORY"

    // $ANTLR start "RIGHT_PAREN"
    public final void mRIGHT_PAREN() throws RecognitionException {
        try {
            int _type = RIGHT_PAREN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1903:2: ( ')' )
            // RuleSet.g:1903:4: ')'
            {
            match(')'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RIGHT_PAREN"

    // $ANTLR start "LEFT_PAREN"
    public final void mLEFT_PAREN() throws RecognitionException {
        try {
            int _type = LEFT_PAREN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1906:2: ( '(' )
            // RuleSet.g:1906:4: '('
            {
            match('('); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LEFT_PAREN"

    // $ANTLR start "RIGHT_BRACKET"
    public final void mRIGHT_BRACKET() throws RecognitionException {
        try {
            int _type = RIGHT_BRACKET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1910:2: ( ']' )
            // RuleSet.g:1910:5: ']'
            {
            match(']'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RIGHT_BRACKET"

    // $ANTLR start "LEFT_BRACKET"
    public final void mLEFT_BRACKET() throws RecognitionException {
        try {
            int _type = LEFT_BRACKET;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1913:2: ( '[' )
            // RuleSet.g:1913:4: '['
            {
            match('['); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LEFT_BRACKET"

    // $ANTLR start "COMMA"
    public final void mCOMMA() throws RecognitionException {
        try {
            int _type = COMMA;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1917:2: ( ',' )
            // RuleSet.g:1917:4: ','
            {
            match(','); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "COMMA"

    // $ANTLR start "LEFT_CURL"
    public final void mLEFT_CURL() throws RecognitionException {
        try {
            int _type = LEFT_CURL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1920:2: ( '{' )
            // RuleSet.g:1920:5: '{'
            {
            match('{'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "LEFT_CURL"

    // $ANTLR start "RIGHT_CURL"
    public final void mRIGHT_CURL() throws RecognitionException {
        try {
            int _type = RIGHT_CURL;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1922:2: ( '}' )
            // RuleSet.g:1922:4: '}'
            {
            match('}'); if (state.failed) return ;

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "RIGHT_CURL"

    // $ANTLR start "NOT"
    public final void mNOT() throws RecognitionException {
        try {
            int _type = NOT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1924:5: ( 'not' )
            // RuleSet.g:1924:7: 'not'
            {
            match("not"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "NOT"

    // $ANTLR start "SEEN"
    public final void mSEEN() throws RecognitionException {
        try {
            int _type = SEEN;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1925:6: ( 'seen' )
            // RuleSet.g:1925:7: 'seen'
            {
            match("seen"); if (state.failed) return ;


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "SEEN"

    // $ANTLR start "VAR"
    public final void mVAR() throws RecognitionException {
        try {
            int _type = VAR;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1927:6: ( ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )* )
            // RuleSet.g:1927:8: ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
            {
            if ( (input.LA(1)>='A' && input.LA(1)<='Z')||input.LA(1)=='_'||(input.LA(1)>='a' && input.LA(1)<='z') ) {
                input.consume();
            state.failed=false;
            }
            else {
                if (state.backtracking>0) {state.failed=true; return ;}
                MismatchedSetException mse = new MismatchedSetException(null,input);
                recover(mse);
                throw mse;}

            // RuleSet.g:1927:32: ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
            loop19:
            do {
                int alt19=2;
                int LA19_0 = input.LA(1);

                if ( ((LA19_0>='0' && LA19_0<='9')||(LA19_0>='A' && LA19_0<='Z')||LA19_0=='_'||(LA19_0>='a' && LA19_0<='z')) ) {
                    alt19=1;
                }


                switch (alt19) {
            	case 1 :
            	    // RuleSet.g:
            	    {
            	    if ( (input.LA(1)>='0' && input.LA(1)<='9')||(input.LA(1)>='A' && input.LA(1)<='Z')||input.LA(1)=='_'||(input.LA(1)>='a' && input.LA(1)<='z') ) {
            	        input.consume();
            	    state.failed=false;
            	    }
            	    else {
            	        if (state.backtracking>0) {state.failed=true; return ;}
            	        MismatchedSetException mse = new MismatchedSetException(null,input);
            	        recover(mse);
            	        throw mse;}


            	    }
            	    break;

            	default :
            	    break loop19;
                }
            } while (true);


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "VAR"

    // $ANTLR start "INT"
    public final void mINT() throws RecognitionException {
        try {
            int _type = INT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1931:5: ( ( '-' )? ( '0' .. '9' )+ )
            // RuleSet.g:1931:7: ( '-' )? ( '0' .. '9' )+
            {
            // RuleSet.g:1931:7: ( '-' )?
            int alt20=2;
            int LA20_0 = input.LA(1);

            if ( (LA20_0=='-') ) {
                alt20=1;
            }
            switch (alt20) {
                case 1 :
                    // RuleSet.g:1931:7: '-'
                    {
                    match('-'); if (state.failed) return ;

                    }
                    break;

            }

            // RuleSet.g:1931:12: ( '0' .. '9' )+
            int cnt21=0;
            loop21:
            do {
                int alt21=2;
                int LA21_0 = input.LA(1);

                if ( ((LA21_0>='0' && LA21_0<='9')) ) {
                    alt21=1;
                }


                switch (alt21) {
            	case 1 :
            	    // RuleSet.g:1931:12: '0' .. '9'
            	    {
            	    matchRange('0','9'); if (state.failed) return ;

            	    }
            	    break;

            	default :
            	    if ( cnt21 >= 1 ) break loop21;
            	    if (state.backtracking>0) {state.failed=true; return ;}
                        EarlyExitException eee =
                            new EarlyExitException(21, input);
                        throw eee;
                }
                cnt21++;
            } while (true);


            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "INT"

    // $ANTLR start "FLOAT"
    public final void mFLOAT() throws RecognitionException {
        try {
            int _type = FLOAT;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // RuleSet.g:1935:5: ( ( '-' )? ( '0' .. '9' )+ '.' ( '0' .. '9' )* ( EXPONENT )? | ( '-' )? '.' ( '0' .. '9' )* ( EXPONENT )? )
            int alt29=2;
            switch ( input.LA(1) ) {
            case '-':
                {
                int LA29_1 = input.LA(2);

                if ( ((LA29_1>='0' && LA29_1<='9')) ) {
                    alt29=1;
                }
                else if ( (LA29_1=='.') ) {
                    alt29=2;
                }
                else {
                    if (state.backtracking>0) {state.failed=true; return ;}
                    NoViableAltException nvae =
                        new NoViableAltException("", 29, 1, input);

                    throw nvae;
                }
                }
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                {
                alt29=1;
                }
                break;
            case '.':
                {
                alt29=2;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return ;}
                NoViableAltException nvae =
                    new NoViableAltException("", 29, 0, input);

                throw nvae;
            }

            switch (alt29) {
                case 1 :
                    // RuleSet.g:1935:9: ( '-' )? ( '0' .. '9' )+ '.' ( '0' .. '9' )* ( EXPONENT )?
                    {
                    // RuleSet.g:1935:9: ( '-' )?
                    int alt22=2;
                    int LA22_0 = input.LA(1);

                    if ( (LA22_0=='-') ) {
                        alt22=1;
                    }
                    switch (alt22) {
                        case 1 :
                            // RuleSet.g:1935:9: '-'
                            {
                            match('-'); if (state.failed) return ;

                            }
                            break;

                    }

                    // RuleSet.g:1935:14: ( '0' .. '9' )+
                    int cnt23=0;
                    loop23:
                    do {
                        int alt23=2;
                        int LA23_0 = input.LA(1);

                        if ( ((LA23_0>='0' && LA23_0<='9')) ) {
                            alt23=1;
                        }


                        switch (alt23) {
                    	case 1 :
                    	    // RuleSet.g:1935:15: '0' .. '9'
                    	    {
                    	    matchRange('0','9'); if (state.failed) return ;

                    	    }
                    	    break;

                    	default :
                    	    if ( cnt23 >= 1 ) break loop23;
                    	    if (state.backtracking>0) {state.failed=true; return ;}
                                EarlyExitException eee =
                                    new EarlyExitException(23, input);
                                throw eee;
                        }
                        cnt23++;
                    } while (true);

                    match('.'); if (state.failed) return ;
                    // RuleSet.g:1935:30: ( '0' .. '9' )*
                    loop24:
                    do {
                        int alt24=2;
                        int LA24_0 = input.LA(1);

                        if ( ((LA24_0>='0' && LA24_0<='9')) ) {
                            alt24=1;
                        }


                        switch (alt24) {
                    	case 1 :
                    	    // RuleSet.g:1935:31: '0' .. '9'
                    	    {
                    	    matchRange('0','9'); if (state.failed) return ;

                    	    }
                    	    break;

                    	default :
                    	    break loop24;
                        }
                    } while (true);

                    // RuleSet.g:1935:42: ( EXPONENT )?
                    int alt25=2;
                    int LA25_0 = input.LA(1);

                    if ( (LA25_0=='E'||LA25_0=='e') ) {
                        alt25=1;
                    }
                    switch (alt25) {
                        case 1 :
                            // RuleSet.g:1935:42: EXPONENT
                            {
                            mEXPONENT(); if (state.failed) return ;

                            }
                            break;

                    }


                    }
                    break;
                case 2 :
                    // RuleSet.g:1936:9: ( '-' )? '.' ( '0' .. '9' )* ( EXPONENT )?
                    {
                    // RuleSet.g:1936:9: ( '-' )?
                    int alt26=2;
                    int LA26_0 = input.LA(1);

                    if ( (LA26_0=='-') ) {
                        alt26=1;
                    }
                    switch (alt26) {
                        case 1 :
                            // RuleSet.g:1936:9: '-'
                            {
                            match('-'); if (state.failed) return ;

                            }
                            break;

                    }

                    match('.'); if (state.failed) return ;
                    // RuleSet.g:1936:18: ( '0' .. '9' )*
                    loop27:
                    do {
                        int alt27=2;
                        int LA27_0 = input.LA(1);

                        if ( ((LA27_0>='0' && LA27_0<='9')) ) {
                            alt27=1;
                        }


                        switch (alt27) {
                    	case 1 :
                    	    // RuleSet.g:1936:19: '0' .. '9'
                    	    {
                    	    matchRange('0','9'); if (state.failed) return ;

                    	    }
                    	    break;

                    	default :
                    	    break loop27;
                        }
                    } while (true);

                    // RuleSet.g:1936:30: ( EXPONENT )?
                    int alt28=2;
                    int LA28_0 = input.LA(1);

                    if ( (LA28_0=='E'||LA28_0=='e') ) {
                        alt28=1;
                    }
                    switch (alt28) {
                        case 1 :
                            // RuleSet.g:1936:30: EXPONENT
                            {
                            mEXPONENT(); if (state.failed) return ;

                            }
                            break;

                    }


                    }
                    break;

            }
            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "FLOAT"

    public void mTokens() throws RecognitionException {
        // RuleSet.g:1:8: ( REX | ARROW_RIGHT | PIPE | SEMI | FUNCTION | EQUAL | OR | AND | VAR_DOMAIN | WITH | USING | SETTING | PRE | FOREACH | WHEN | OR_OR | AND_AND | BETWEEN | WEB | PAGEVIEW | LEFT_SMALL_ARROW | RIGHT_SMALL_ARROW | GLOBAL | DTYPE | PREDOP | ADD_OP | CALLBACKS | SUCCESS | FAILURE | FORGET | MARK | COUNTER_OP | IF | CHOOSE | EVERY | COMMENT | WS | STRING | HTML | JS | ESC_SEQ | RULE_SET | MULT_OP | DOT | MATCH | REPLACE | OTHER_OPERATORS | TRUE | FALSE | CURRENT | KEY | AUTHZ | REQUIRE | LOGGING | USE | CSS | JAVASCRIPT | META | ON | OFF | MODULE | ALIAS | EMIT | CACHABLE | FOR | WITHIN | COLON | HISTORY | RIGHT_PAREN | LEFT_PAREN | RIGHT_BRACKET | LEFT_BRACKET | COMMA | LEFT_CURL | RIGHT_CURL | NOT | SEEN | VAR | INT | FLOAT )
        int alt30=80;
        alt30 = dfa30.predict(input);
        switch (alt30) {
            case 1 :
                // RuleSet.g:1:10: REX
                {
                mREX(); if (state.failed) return ;

                }
                break;
            case 2 :
                // RuleSet.g:1:14: ARROW_RIGHT
                {
                mARROW_RIGHT(); if (state.failed) return ;

                }
                break;
            case 3 :
                // RuleSet.g:1:26: PIPE
                {
                mPIPE(); if (state.failed) return ;

                }
                break;
            case 4 :
                // RuleSet.g:1:31: SEMI
                {
                mSEMI(); if (state.failed) return ;

                }
                break;
            case 5 :
                // RuleSet.g:1:36: FUNCTION
                {
                mFUNCTION(); if (state.failed) return ;

                }
                break;
            case 6 :
                // RuleSet.g:1:45: EQUAL
                {
                mEQUAL(); if (state.failed) return ;

                }
                break;
            case 7 :
                // RuleSet.g:1:51: OR
                {
                mOR(); if (state.failed) return ;

                }
                break;
            case 8 :
                // RuleSet.g:1:54: AND
                {
                mAND(); if (state.failed) return ;

                }
                break;
            case 9 :
                // RuleSet.g:1:58: VAR_DOMAIN
                {
                mVAR_DOMAIN(); if (state.failed) return ;

                }
                break;
            case 10 :
                // RuleSet.g:1:69: WITH
                {
                mWITH(); if (state.failed) return ;

                }
                break;
            case 11 :
                // RuleSet.g:1:74: USING
                {
                mUSING(); if (state.failed) return ;

                }
                break;
            case 12 :
                // RuleSet.g:1:80: SETTING
                {
                mSETTING(); if (state.failed) return ;

                }
                break;
            case 13 :
                // RuleSet.g:1:88: PRE
                {
                mPRE(); if (state.failed) return ;

                }
                break;
            case 14 :
                // RuleSet.g:1:92: FOREACH
                {
                mFOREACH(); if (state.failed) return ;

                }
                break;
            case 15 :
                // RuleSet.g:1:100: WHEN
                {
                mWHEN(); if (state.failed) return ;

                }
                break;
            case 16 :
                // RuleSet.g:1:105: OR_OR
                {
                mOR_OR(); if (state.failed) return ;

                }
                break;
            case 17 :
                // RuleSet.g:1:111: AND_AND
                {
                mAND_AND(); if (state.failed) return ;

                }
                break;
            case 18 :
                // RuleSet.g:1:119: BETWEEN
                {
                mBETWEEN(); if (state.failed) return ;

                }
                break;
            case 19 :
                // RuleSet.g:1:127: WEB
                {
                mWEB(); if (state.failed) return ;

                }
                break;
            case 20 :
                // RuleSet.g:1:131: PAGEVIEW
                {
                mPAGEVIEW(); if (state.failed) return ;

                }
                break;
            case 21 :
                // RuleSet.g:1:140: LEFT_SMALL_ARROW
                {
                mLEFT_SMALL_ARROW(); if (state.failed) return ;

                }
                break;
            case 22 :
                // RuleSet.g:1:157: RIGHT_SMALL_ARROW
                {
                mRIGHT_SMALL_ARROW(); if (state.failed) return ;

                }
                break;
            case 23 :
                // RuleSet.g:1:175: GLOBAL
                {
                mGLOBAL(); if (state.failed) return ;

                }
                break;
            case 24 :
                // RuleSet.g:1:182: DTYPE
                {
                mDTYPE(); if (state.failed) return ;

                }
                break;
            case 25 :
                // RuleSet.g:1:188: PREDOP
                {
                mPREDOP(); if (state.failed) return ;

                }
                break;
            case 26 :
                // RuleSet.g:1:195: ADD_OP
                {
                mADD_OP(); if (state.failed) return ;

                }
                break;
            case 27 :
                // RuleSet.g:1:202: CALLBACKS
                {
                mCALLBACKS(); if (state.failed) return ;

                }
                break;
            case 28 :
                // RuleSet.g:1:212: SUCCESS
                {
                mSUCCESS(); if (state.failed) return ;

                }
                break;
            case 29 :
                // RuleSet.g:1:220: FAILURE
                {
                mFAILURE(); if (state.failed) return ;

                }
                break;
            case 30 :
                // RuleSet.g:1:228: FORGET
                {
                mFORGET(); if (state.failed) return ;

                }
                break;
            case 31 :
                // RuleSet.g:1:235: MARK
                {
                mMARK(); if (state.failed) return ;

                }
                break;
            case 32 :
                // RuleSet.g:1:240: COUNTER_OP
                {
                mCOUNTER_OP(); if (state.failed) return ;

                }
                break;
            case 33 :
                // RuleSet.g:1:251: IF
                {
                mIF(); if (state.failed) return ;

                }
                break;
            case 34 :
                // RuleSet.g:1:254: CHOOSE
                {
                mCHOOSE(); if (state.failed) return ;

                }
                break;
            case 35 :
                // RuleSet.g:1:261: EVERY
                {
                mEVERY(); if (state.failed) return ;

                }
                break;
            case 36 :
                // RuleSet.g:1:267: COMMENT
                {
                mCOMMENT(); if (state.failed) return ;

                }
                break;
            case 37 :
                // RuleSet.g:1:275: WS
                {
                mWS(); if (state.failed) return ;

                }
                break;
            case 38 :
                // RuleSet.g:1:278: STRING
                {
                mSTRING(); if (state.failed) return ;

                }
                break;
            case 39 :
                // RuleSet.g:1:285: HTML
                {
                mHTML(); if (state.failed) return ;

                }
                break;
            case 40 :
                // RuleSet.g:1:290: JS
                {
                mJS(); if (state.failed) return ;

                }
                break;
            case 41 :
                // RuleSet.g:1:293: ESC_SEQ
                {
                mESC_SEQ(); if (state.failed) return ;

                }
                break;
            case 42 :
                // RuleSet.g:1:301: RULE_SET
                {
                mRULE_SET(); if (state.failed) return ;

                }
                break;
            case 43 :
                // RuleSet.g:1:310: MULT_OP
                {
                mMULT_OP(); if (state.failed) return ;

                }
                break;
            case 44 :
                // RuleSet.g:1:318: DOT
                {
                mDOT(); if (state.failed) return ;

                }
                break;
            case 45 :
                // RuleSet.g:1:322: MATCH
                {
                mMATCH(); if (state.failed) return ;

                }
                break;
            case 46 :
                // RuleSet.g:1:328: REPLACE
                {
                mREPLACE(); if (state.failed) return ;

                }
                break;
            case 47 :
                // RuleSet.g:1:336: OTHER_OPERATORS
                {
                mOTHER_OPERATORS(); if (state.failed) return ;

                }
                break;
            case 48 :
                // RuleSet.g:1:352: TRUE
                {
                mTRUE(); if (state.failed) return ;

                }
                break;
            case 49 :
                // RuleSet.g:1:357: FALSE
                {
                mFALSE(); if (state.failed) return ;

                }
                break;
            case 50 :
                // RuleSet.g:1:363: CURRENT
                {
                mCURRENT(); if (state.failed) return ;

                }
                break;
            case 51 :
                // RuleSet.g:1:371: KEY
                {
                mKEY(); if (state.failed) return ;

                }
                break;
            case 52 :
                // RuleSet.g:1:375: AUTHZ
                {
                mAUTHZ(); if (state.failed) return ;

                }
                break;
            case 53 :
                // RuleSet.g:1:381: REQUIRE
                {
                mREQUIRE(); if (state.failed) return ;

                }
                break;
            case 54 :
                // RuleSet.g:1:389: LOGGING
                {
                mLOGGING(); if (state.failed) return ;

                }
                break;
            case 55 :
                // RuleSet.g:1:397: USE
                {
                mUSE(); if (state.failed) return ;

                }
                break;
            case 56 :
                // RuleSet.g:1:401: CSS
                {
                mCSS(); if (state.failed) return ;

                }
                break;
            case 57 :
                // RuleSet.g:1:405: JAVASCRIPT
                {
                mJAVASCRIPT(); if (state.failed) return ;

                }
                break;
            case 58 :
                // RuleSet.g:1:416: META
                {
                mMETA(); if (state.failed) return ;

                }
                break;
            case 59 :
                // RuleSet.g:1:421: ON
                {
                mON(); if (state.failed) return ;

                }
                break;
            case 60 :
                // RuleSet.g:1:424: OFF
                {
                mOFF(); if (state.failed) return ;

                }
                break;
            case 61 :
                // RuleSet.g:1:428: MODULE
                {
                mMODULE(); if (state.failed) return ;

                }
                break;
            case 62 :
                // RuleSet.g:1:435: ALIAS
                {
                mALIAS(); if (state.failed) return ;

                }
                break;
            case 63 :
                // RuleSet.g:1:441: EMIT
                {
                mEMIT(); if (state.failed) return ;

                }
                break;
            case 64 :
                // RuleSet.g:1:446: CACHABLE
                {
                mCACHABLE(); if (state.failed) return ;

                }
                break;
            case 65 :
                // RuleSet.g:1:455: FOR
                {
                mFOR(); if (state.failed) return ;

                }
                break;
            case 66 :
                // RuleSet.g:1:459: WITHIN
                {
                mWITHIN(); if (state.failed) return ;

                }
                break;
            case 67 :
                // RuleSet.g:1:466: COLON
                {
                mCOLON(); if (state.failed) return ;

                }
                break;
            case 68 :
                // RuleSet.g:1:472: HISTORY
                {
                mHISTORY(); if (state.failed) return ;

                }
                break;
            case 69 :
                // RuleSet.g:1:480: RIGHT_PAREN
                {
                mRIGHT_PAREN(); if (state.failed) return ;

                }
                break;
            case 70 :
                // RuleSet.g:1:492: LEFT_PAREN
                {
                mLEFT_PAREN(); if (state.failed) return ;

                }
                break;
            case 71 :
                // RuleSet.g:1:503: RIGHT_BRACKET
                {
                mRIGHT_BRACKET(); if (state.failed) return ;

                }
                break;
            case 72 :
                // RuleSet.g:1:517: LEFT_BRACKET
                {
                mLEFT_BRACKET(); if (state.failed) return ;

                }
                break;
            case 73 :
                // RuleSet.g:1:530: COMMA
                {
                mCOMMA(); if (state.failed) return ;

                }
                break;
            case 74 :
                // RuleSet.g:1:536: LEFT_CURL
                {
                mLEFT_CURL(); if (state.failed) return ;

                }
                break;
            case 75 :
                // RuleSet.g:1:546: RIGHT_CURL
                {
                mRIGHT_CURL(); if (state.failed) return ;

                }
                break;
            case 76 :
                // RuleSet.g:1:557: NOT
                {
                mNOT(); if (state.failed) return ;

                }
                break;
            case 77 :
                // RuleSet.g:1:561: SEEN
                {
                mSEEN(); if (state.failed) return ;

                }
                break;
            case 78 :
                // RuleSet.g:1:566: VAR
                {
                mVAR(); if (state.failed) return ;

                }
                break;
            case 79 :
                // RuleSet.g:1:570: INT
                {
                mINT(); if (state.failed) return ;

                }
                break;
            case 80 :
                // RuleSet.g:1:574: FLOAT
                {
                mFLOAT(); if (state.failed) return ;

                }
                break;

        }

    }

    // $ANTLR start synpred1_RuleSet
    public final void synpred1_RuleSet_fragment() throws RecognitionException {   
        // RuleSet.g:1652:15: ( ESC_SEQ )
        // RuleSet.g:1652:16: ESC_SEQ
        {
        mESC_SEQ(); if (state.failed) return ;

        }
    }
    // $ANTLR end synpred1_RuleSet

    public final boolean synpred1_RuleSet() {
        state.backtracking++;
        int start = input.mark();
        try {
            synpred1_RuleSet_fragment(); // can never throw exception
        } catch (RecognitionException re) {
            System.err.println("impossible: "+re);
        }
        boolean success = !state.failed;
        input.rewind(start);
        state.backtracking--;
        state.failed=false;
        return success;
    }


    protected DFA1 dfa1 = new DFA1(this);
    protected DFA5 dfa5 = new DFA5(this);
    protected DFA18 dfa18 = new DFA18(this);
    protected DFA30 dfa30 = new DFA30(this);
    static final String DFA1_eotS =
        "\6\uffff\1\3\6\uffff\1\3\3\uffff";
    static final String DFA1_eofS =
        "\21\uffff";
    static final String DFA1_minS =
        "\1\0\1\uffff\1\0\1\uffff\6\0\1\uffff\1\0\1\uffff\4\0";
    static final String DFA1_maxS =
        "\1\uffff\1\uffff\1\uffff\1\uffff\1\0\2\uffff\3\0\1\uffff\1\uffff"+
        "\1\uffff\3\uffff\1\0";
    static final String DFA1_acceptS =
        "\1\uffff\1\4\1\uffff\1\3\6\uffff\1\1\1\uffff\1\2\4\uffff";
    static final String DFA1_specialS =
        "\1\4\1\uffff\1\6\1\uffff\1\2\1\13\1\5\1\11\1\10\1\7\1\uffff\1\14"+
        "\1\uffff\1\3\1\12\1\1\1\0}>";
    static final String[] DFA1_transitionS = {
            "\57\3\1\1\54\3\1\2\uffa3\3",
            "",
            "\42\3\1\10\4\3\3\10\3\3\2\10\1\6\4\7\4\11\7\3\1\10\34\3\1\4"+
            "\5\3\1\10\1\3\1\10\1\3\1\10\7\3\1\10\3\3\3\10\1\5\1\3\1\10\uff88"+
            "\3",
            "",
            "\1\uffff",
            "\60\3\12\13\7\3\6\13\32\3\6\13\uff99\3",
            "\147\14\1\15\1\14\1\15\3\14\1\15\uff92\14",
            "\1\uffff",
            "\1\uffff",
            "\1\uffff",
            "",
            "\60\3\12\16\7\3\6\16\32\3\6\16\uff99\3",
            "",
            "\147\14\1\15\1\14\1\15\3\14\1\15\uff92\14",
            "\60\3\12\17\7\3\6\17\32\3\6\17\uff99\3",
            "\60\3\12\20\7\3\6\20\32\3\6\20\uff99\3",
            "\1\uffff"
    };

    static final short[] DFA1_eot = DFA.unpackEncodedString(DFA1_eotS);
    static final short[] DFA1_eof = DFA.unpackEncodedString(DFA1_eofS);
    static final char[] DFA1_min = DFA.unpackEncodedStringToUnsignedChars(DFA1_minS);
    static final char[] DFA1_max = DFA.unpackEncodedStringToUnsignedChars(DFA1_maxS);
    static final short[] DFA1_accept = DFA.unpackEncodedString(DFA1_acceptS);
    static final short[] DFA1_special = DFA.unpackEncodedString(DFA1_specialS);
    static final short[][] DFA1_transition;

    static {
        int numStates = DFA1_transitionS.length;
        DFA1_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA1_transition[i] = DFA.unpackEncodedString(DFA1_transitionS[i]);
        }
    }

    class DFA1 extends DFA {

        public DFA1(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 1;
            this.eot = DFA1_eot;
            this.eof = DFA1_eof;
            this.min = DFA1_min;
            this.max = DFA1_max;
            this.accept = DFA1_accept;
            this.special = DFA1_special;
            this.transition = DFA1_transition;
        }
        public String getDescription() {
            return "()* loopback of 1652:14: ( ( ESC_SEQ )=> ESC_SEQ | '\\\\/' | ~ ( '/' ) )*";
        }
        public int specialStateTransition(int s, IntStream _input) throws NoViableAltException {
            IntStream input = _input;
        	int _s = s;
            switch ( s ) {
                    case 0 : 
                        int LA1_16 = input.LA(1);

                         
                        int index1_16 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred1_RuleSet()) ) {s = 10;}

                        else if ( (true) ) {s = 3;}

                         
                        input.seek(index1_16);
                        if ( s>=0 ) return s;
                        break;
                    case 1 : 
                        int LA1_15 = input.LA(1);

                        s = -1;
                        if ( ((LA1_15>='\u0000' && LA1_15<='/')||(LA1_15>=':' && LA1_15<='@')||(LA1_15>='G' && LA1_15<='`')||(LA1_15>='g' && LA1_15<='\uFFFF')) ) {s = 3;}

                        else if ( ((LA1_15>='0' && LA1_15<='9')||(LA1_15>='A' && LA1_15<='F')||(LA1_15>='a' && LA1_15<='f')) ) {s = 16;}

                        if ( s>=0 ) return s;
                        break;
                    case 2 : 
                        int LA1_4 = input.LA(1);

                         
                        int index1_4 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred1_RuleSet()) ) {s = 10;}

                        else if ( (true) ) {s = 3;}

                         
                        input.seek(index1_4);
                        if ( s>=0 ) return s;
                        break;
                    case 3 : 
                        int LA1_13 = input.LA(1);

                        s = -1;
                        if ( ((LA1_13>='\u0000' && LA1_13<='f')||LA1_13=='h'||(LA1_13>='j' && LA1_13<='l')||(LA1_13>='n' && LA1_13<='\uFFFF')) ) {s = 12;}

                        else if ( (LA1_13=='g'||LA1_13=='i'||LA1_13=='m') ) {s = 13;}

                        else s = 3;

                        if ( s>=0 ) return s;
                        break;
                    case 4 : 
                        int LA1_0 = input.LA(1);

                        s = -1;
                        if ( (LA1_0=='/') ) {s = 1;}

                        else if ( (LA1_0=='\\') ) {s = 2;}

                        else if ( ((LA1_0>='\u0000' && LA1_0<='.')||(LA1_0>='0' && LA1_0<='[')||(LA1_0>=']' && LA1_0<='\uFFFF')) ) {s = 3;}

                        if ( s>=0 ) return s;
                        break;
                    case 5 : 
                        int LA1_6 = input.LA(1);

                        s = -1;
                        if ( ((LA1_6>='\u0000' && LA1_6<='f')||LA1_6=='h'||(LA1_6>='j' && LA1_6<='l')||(LA1_6>='n' && LA1_6<='\uFFFF')) ) {s = 12;}

                        else if ( (LA1_6=='g'||LA1_6=='i'||LA1_6=='m') ) {s = 13;}

                        else s = 3;

                        if ( s>=0 ) return s;
                        break;
                    case 6 : 
                        int LA1_2 = input.LA(1);

                        s = -1;
                        if ( (LA1_2=='\\') ) {s = 4;}

                        else if ( (LA1_2=='u') ) {s = 5;}

                        else if ( (LA1_2=='/') ) {s = 6;}

                        else if ( ((LA1_2>='0' && LA1_2<='3')) ) {s = 7;}

                        else if ( (LA1_2=='\"'||(LA1_2>='\'' && LA1_2<=')')||(LA1_2>='-' && LA1_2<='.')||LA1_2=='?'||LA1_2=='b'||LA1_2=='d'||LA1_2=='f'||LA1_2=='n'||(LA1_2>='r' && LA1_2<='t')||LA1_2=='w') ) {s = 8;}

                        else if ( ((LA1_2>='4' && LA1_2<='7')) ) {s = 9;}

                        else if ( ((LA1_2>='\u0000' && LA1_2<='!')||(LA1_2>='#' && LA1_2<='&')||(LA1_2>='*' && LA1_2<=',')||(LA1_2>='8' && LA1_2<='>')||(LA1_2>='@' && LA1_2<='[')||(LA1_2>=']' && LA1_2<='a')||LA1_2=='c'||LA1_2=='e'||(LA1_2>='g' && LA1_2<='m')||(LA1_2>='o' && LA1_2<='q')||LA1_2=='v'||(LA1_2>='x' && LA1_2<='\uFFFF')) ) {s = 3;}

                        if ( s>=0 ) return s;
                        break;
                    case 7 : 
                        int LA1_9 = input.LA(1);

                         
                        int index1_9 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred1_RuleSet()) ) {s = 10;}

                        else if ( (true) ) {s = 3;}

                         
                        input.seek(index1_9);
                        if ( s>=0 ) return s;
                        break;
                    case 8 : 
                        int LA1_8 = input.LA(1);

                         
                        int index1_8 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred1_RuleSet()) ) {s = 10;}

                        else if ( (true) ) {s = 3;}

                         
                        input.seek(index1_8);
                        if ( s>=0 ) return s;
                        break;
                    case 9 : 
                        int LA1_7 = input.LA(1);

                         
                        int index1_7 = input.index();
                        input.rewind();
                        s = -1;
                        if ( (synpred1_RuleSet()) ) {s = 10;}

                        else if ( (true) ) {s = 3;}

                         
                        input.seek(index1_7);
                        if ( s>=0 ) return s;
                        break;
                    case 10 : 
                        int LA1_14 = input.LA(1);

                        s = -1;
                        if ( ((LA1_14>='\u0000' && LA1_14<='/')||(LA1_14>=':' && LA1_14<='@')||(LA1_14>='G' && LA1_14<='`')||(LA1_14>='g' && LA1_14<='\uFFFF')) ) {s = 3;}

                        else if ( ((LA1_14>='0' && LA1_14<='9')||(LA1_14>='A' && LA1_14<='F')||(LA1_14>='a' && LA1_14<='f')) ) {s = 15;}

                        if ( s>=0 ) return s;
                        break;
                    case 11 : 
                        int LA1_5 = input.LA(1);

                        s = -1;
                        if ( ((LA1_5>='\u0000' && LA1_5<='/')||(LA1_5>=':' && LA1_5<='@')||(LA1_5>='G' && LA1_5<='`')||(LA1_5>='g' && LA1_5<='\uFFFF')) ) {s = 3;}

                        else if ( ((LA1_5>='0' && LA1_5<='9')||(LA1_5>='A' && LA1_5<='F')||(LA1_5>='a' && LA1_5<='f')) ) {s = 11;}

                        if ( s>=0 ) return s;
                        break;
                    case 12 : 
                        int LA1_11 = input.LA(1);

                        s = -1;
                        if ( ((LA1_11>='\u0000' && LA1_11<='/')||(LA1_11>=':' && LA1_11<='@')||(LA1_11>='G' && LA1_11<='`')||(LA1_11>='g' && LA1_11<='\uFFFF')) ) {s = 3;}

                        else if ( ((LA1_11>='0' && LA1_11<='9')||(LA1_11>='A' && LA1_11<='F')||(LA1_11>='a' && LA1_11<='f')) ) {s = 14;}

                        if ( s>=0 ) return s;
                        break;
            }
            if (state.backtracking>0) {state.failed=true; return -1;}
            NoViableAltException nvae =
                new NoViableAltException(getDescription(), 1, _s, input);
            error(nvae);
            throw nvae;
        }
    }
    static final String DFA5_eotS =
        "\1\uffff\1\11\1\13\11\uffff";
    static final String DFA5_eofS =
        "\14\uffff";
    static final String DFA5_minS =
        "\1\41\2\75\11\uffff";
    static final String DFA5_maxS =
        "\1\156\2\75\11\uffff";
    static final String DFA5_acceptS =
        "\3\uffff\1\5\1\6\1\7\1\10\1\11\1\1\1\3\1\2\1\4";
    static final String DFA5_specialS =
        "\14\uffff}>";
    static final String[] DFA5_transitionS = {
            "\1\4\32\uffff\1\1\1\3\1\2\46\uffff\1\5\6\uffff\1\7\1\uffff\1"+
            "\6",
            "\1\10",
            "\1\12",
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

    static final short[] DFA5_eot = DFA.unpackEncodedString(DFA5_eotS);
    static final short[] DFA5_eof = DFA.unpackEncodedString(DFA5_eofS);
    static final char[] DFA5_min = DFA.unpackEncodedStringToUnsignedChars(DFA5_minS);
    static final char[] DFA5_max = DFA.unpackEncodedStringToUnsignedChars(DFA5_maxS);
    static final short[] DFA5_accept = DFA.unpackEncodedString(DFA5_acceptS);
    static final short[] DFA5_special = DFA.unpackEncodedString(DFA5_specialS);
    static final short[][] DFA5_transition;

    static {
        int numStates = DFA5_transitionS.length;
        DFA5_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA5_transition[i] = DFA.unpackEncodedString(DFA5_transitionS[i]);
        }
    }

    class DFA5 extends DFA {

        public DFA5(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 5;
            this.eot = DFA5_eot;
            this.eof = DFA5_eof;
            this.min = DFA5_min;
            this.max = DFA5_max;
            this.accept = DFA5_accept;
            this.special = DFA5_special;
            this.transition = DFA5_transition;
        }
        public String getDescription() {
            return "1715:1: PREDOP : ( '<=' | '>=' | '<' | '>' | '==' | '!=' | 'eq' | 'neq' | 'like' );";
        }
    }
    static final String DFA18_eotS =
        "\34\uffff";
    static final String DFA18_eofS =
        "\34\uffff";
    static final String DFA18_minS =
        "\1\141\1\uffff\1\143\1\uffff\1\141\1\uffff\1\157\2\uffff\1\143\2"+
        "\uffff\1\151\11\uffff\1\151\2\uffff\1\157\2\uffff";
    static final String DFA18_maxS =
        "\1\165\1\uffff\1\145\1\uffff\1\145\1\uffff\1\160\2\uffff\1\156\2"+
        "\uffff\1\165\11\uffff\1\151\2\uffff\1\161\2\uffff";
    static final String DFA18_acceptS =
        "\1\uffff\1\1\1\uffff\1\3\1\uffff\1\5\1\uffff\1\7\1\10\1\uffff\1"+
        "\14\1\15\1\uffff\1\21\1\23\1\2\1\12\1\4\1\16\1\6\1\13\1\11\1\uffff"+
        "\1\20\1\24\1\uffff\1\17\1\22";
    static final String DFA18_specialS =
        "\34\uffff}>";
    static final String[] DFA18_transitionS = {
            "\1\3\2\uffff\1\14\1\uffff\1\7\1\uffff\1\4\1\15\1\12\1\uffff"+
            "\1\2\1\10\1\uffff\1\16\1\1\1\13\1\uffff\1\6\1\5\1\11",
            "",
            "\1\20\1\uffff\1\17",
            "",
            "\1\22\3\uffff\1\21",
            "",
            "\1\23\1\24",
            "",
            "",
            "\1\25\12\uffff\1\26",
            "",
            "",
            "\1\27\13\uffff\1\30",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\31",
            "",
            "",
            "\1\32\1\uffff\1\33",
            "",
            ""
    };

    static final short[] DFA18_eot = DFA.unpackEncodedString(DFA18_eotS);
    static final short[] DFA18_eof = DFA.unpackEncodedString(DFA18_eofS);
    static final char[] DFA18_min = DFA.unpackEncodedStringToUnsignedChars(DFA18_minS);
    static final char[] DFA18_max = DFA.unpackEncodedStringToUnsignedChars(DFA18_maxS);
    static final short[] DFA18_accept = DFA.unpackEncodedString(DFA18_acceptS);
    static final short[] DFA18_special = DFA.unpackEncodedString(DFA18_specialS);
    static final short[][] DFA18_transition;

    static {
        int numStates = DFA18_transitionS.length;
        DFA18_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA18_transition[i] = DFA.unpackEncodedString(DFA18_transitionS[i]);
        }
    }

    class DFA18 extends DFA {

        public DFA18(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 18;
            this.eot = DFA18_eot;
            this.eof = DFA18_eof;
            this.min = DFA18_min;
            this.max = DFA18_max;
            this.accept = DFA18_accept;
            this.special = DFA18_special;
            this.transition = DFA18_transition;
        }
        public String getDescription() {
            return "1827:1: OTHER_OPERATORS : ( 'pick' | 'length' | 'as' | 'head' | 'tail' | 'sort' | 'filter' | 'map' | 'uc' | 'lc' | 'split' | 'join' | 'query' | 'has' | 'union' | 'difference' | 'intersection' | 'unique' | 'once' | 'duplicates' );";
        }
    }
    static final String DFA30_eotS =
        "\1\uffff\1\61\1\66\1\70\1\uffff\1\61\1\uffff\10\61\1\26\1\135\5"+
        "\61\1\uffff\2\61\1\135\3\61\1\41\4\uffff\1\163\6\61\11\uffff\1\177"+
        "\2\61\4\uffff\5\61\1\26\4\61\1\u008e\6\61\1\u008e\10\61\1\u009f"+
        "\1\u00a1\2\61\7\uffff\11\61\1\u008e\10\61\1\u00b8\1\61\2\uffff\13"+
        "\61\2\uffff\4\61\1\u00cb\3\61\1\u00cf\2\61\1\u00cf\1\u00d2\1\uffff"+
        "\4\61\1\u00d7\1\61\1\u00d9\6\61\1\u00e1\2\61\1\uffff\1\61\1\uffff"+
        "\1\u00e5\3\61\2\u00e9\1\61\1\26\1\u00eb\7\61\1\u00f3\2\61\1\u008e"+
        "\2\61\1\uffff\2\61\1\u008e\10\61\1\u0102\6\61\1\uffff\3\61\1\uffff"+
        "\1\61\1\u010d\1\uffff\2\61\1\u0111\1\u0112\1\uffff\1\61\1\uffff"+
        "\3\61\1\u0117\1\61\1\u008e\1\61\1\uffff\1\61\2\u008e\1\uffff\2\61"+
        "\1\u00e9\1\uffff\1\u00e9\1\uffff\1\26\6\61\1\uffff\1\u0123\1\61"+
        "\1\u0125\2\61\1\u008e\1\61\1\u008e\1\u0129\1\u008e\4\61\1\uffff"+
        "\7\61\1\u0135\1\61\1\u0137\1\uffff\1\u0138\1\u0139\1\61\2\uffff"+
        "\1\u013b\1\u008e\2\61\1\uffff\1\61\1\u008e\11\61\1\uffff\1\u0148"+
        "\1\uffff\3\61\1\uffff\1\61\1\u008e\7\61\1\u0154\1\61\1\uffff\1\u008e"+
        "\3\uffff\1\u0156\1\uffff\1\u008e\4\61\1\u015b\1\u008e\3\61\1\u015f"+
        "\1\61\1\uffff\1\u0161\5\61\1\u0167\1\u0168\1\u0169\1\61\1\u016b"+
        "\1\uffff\1\u016c\1\uffff\1\u016d\1\u016e\1\61\1\u0170\1\uffff\1"+
        "\u0171\2\61\1\uffff\1\u0174\1\uffff\1\61\1\u0176\3\61\3\uffff\1"+
        "\u017a\4\uffff\1\u017b\2\uffff\1\61\1\u017d\1\uffff\1\61\1\uffff"+
        "\3\61\2\uffff\1\u0182\1\uffff\4\61\1\uffff\1\61\1\u0188\2\u008e"+
        "\1\61\1\uffff\1\u008e";
    static final String DFA30_eofS =
        "\u018a\uffff";
    static final String DFA30_minS =
        "\1\11\1\145\1\75\1\174\1\uffff\1\141\1\uffff\1\155\1\154\1\145\1"+
        "\143\1\145\1\141\1\146\1\145\1\55\1\56\1\154\1\123\1\115\1\123\1"+
        "\124\1\uffff\1\145\1\143\1\75\2\141\1\146\1\52\4\uffff\1\60\3\141"+
        "\1\165\1\151\1\145\11\uffff\1\56\1\57\1\154\4\uffff\1\156\1\162"+
        "\1\151\1\154\1\164\1\60\1\145\1\151\1\160\1\144\1\60\1\164\1\151"+
        "\1\164\1\145\1\142\1\145\1\60\1\151\1\145\1\143\1\162\1\154\1\145"+
        "\1\147\1\143\2\60\1\146\1\164\7\uffff\1\157\1\117\1\114\1\123\1"+
        "\115\1\161\1\164\1\153\1\156\1\60\1\147\1\143\1\157\1\162\1\163"+
        "\1\160\1\164\1\144\1\60\1\164\2\uffff\1\141\2\163\1\151\1\165\1"+
        "\151\1\166\1\145\1\146\1\160\1\171\2\uffff\1\154\1\165\1\145\1\143"+
        "\1\60\1\154\1\163\1\164\1\60\1\162\1\164\2\60\1\uffff\1\150\1\141"+
        "\1\150\1\156\1\60\1\156\1\60\1\157\1\164\1\156\1\143\1\164\1\151"+
        "\1\60\1\145\1\153\1\uffff\1\145\1\uffff\1\60\1\167\1\142\1\116\2"+
        "\60\1\114\2\60\1\145\2\147\1\154\1\150\1\157\1\162\1\60\1\153\1"+
        "\143\1\60\1\141\1\165\1\uffff\1\145\1\144\1\60\1\164\1\154\1\145"+
        "\1\156\1\141\1\162\1\146\1\154\1\60\1\141\1\151\1\163\1\164\1\141"+
        "\1\145\1\uffff\1\165\2\145\1\uffff\1\171\1\60\1\uffff\1\172\1\163"+
        "\2\60\1\uffff\1\147\1\uffff\1\156\1\165\1\151\1\60\1\145\1\60\1"+
        "\164\1\uffff\1\166\2\60\1\uffff\1\145\1\141\1\60\1\uffff\1\60\1"+
        "\uffff\1\60\1\164\1\151\1\142\1\141\1\163\1\145\1\uffff\1\60\1\150"+
        "\1\60\1\154\1\162\1\60\1\157\3\60\1\163\1\171\1\145\1\151\1\uffff"+
        "\1\143\1\162\1\145\1\151\1\143\1\164\1\162\1\60\1\162\1\60\1\uffff"+
        "\2\60\1\156\2\uffff\2\60\1\145\1\156\1\uffff\1\163\1\60\1\151\1"+
        "\145\1\154\1\150\1\156\1\141\1\142\1\145\1\156\1\uffff\1\60\1\uffff"+
        "\1\145\1\163\1\162\1\uffff\1\143\1\60\1\162\1\143\2\145\1\164\1"+
        "\157\1\150\1\60\1\145\1\uffff\1\60\3\uffff\1\60\1\uffff\1\60\1\147"+
        "\1\163\1\145\1\156\2\60\1\147\1\143\1\154\1\60\1\164\1\uffff\1\60"+
        "\1\145\1\171\1\162\1\145\1\141\3\60\1\156\1\60\1\uffff\1\60\1\uffff"+
        "\2\60\1\167\1\60\1\uffff\1\60\1\153\1\145\1\uffff\1\60\1\uffff\1"+
        "\143\1\60\1\151\1\156\1\164\3\uffff\1\60\4\uffff\1\60\2\uffff\1"+
        "\163\1\60\1\uffff\1\164\1\uffff\1\160\1\143\1\145\2\uffff\1\60\1"+
        "\uffff\1\151\1\164\1\145\1\163\1\uffff\1\157\3\60\1\156\1\uffff"+
        "\1\60";
    static final String DFA30_maxS =
        "\1\175\1\165\1\76\1\174\1\uffff\1\165\1\uffff\1\166\1\165\1\151"+
        "\1\163\1\165\2\162\1\145\1\174\1\76\1\154\1\123\1\115\1\123\1\124"+
        "\1\uffff\2\157\1\75\1\165\1\157\1\156\1\57\4\uffff\1\145\1\151\1"+
        "\162\1\157\2\165\1\145\11\uffff\1\71\1\161\1\154\4\uffff\1\156\1"+
        "\162\2\154\1\164\1\172\1\145\1\151\1\160\1\144\1\172\1\164\1\151"+
        "\1\164\1\145\1\142\1\151\1\172\1\151\1\164\1\143\1\162\1\154\1\145"+
        "\1\147\1\143\2\172\1\146\1\164\7\uffff\1\157\1\117\1\114\1\123\1"+
        "\115\1\161\1\164\1\153\1\156\1\172\1\147\1\154\1\157\1\162\1\163"+
        "\2\164\1\144\1\172\1\164\2\uffff\1\141\2\163\1\151\1\165\1\151\1"+
        "\166\1\145\1\146\1\160\1\171\2\uffff\1\154\1\165\1\145\1\143\1\172"+
        "\1\154\1\163\1\164\1\172\1\162\1\164\2\172\1\uffff\1\150\1\141\1"+
        "\150\1\156\1\172\1\156\1\172\1\161\1\164\1\156\1\143\1\164\1\151"+
        "\1\172\1\145\1\153\1\uffff\1\145\1\uffff\1\172\1\167\1\142\1\116"+
        "\2\172\1\114\2\172\1\145\2\147\1\154\1\150\1\157\1\162\1\172\1\153"+
        "\1\143\1\172\1\141\1\165\1\uffff\1\145\1\144\1\172\1\164\1\154\1"+
        "\145\1\156\1\141\1\162\1\146\1\154\1\172\1\141\1\151\1\163\1\164"+
        "\1\141\1\145\1\uffff\1\165\2\145\1\uffff\1\171\1\172\1\uffff\1\172"+
        "\1\163\2\172\1\uffff\1\147\1\uffff\1\156\1\165\1\151\1\172\1\145"+
        "\1\172\1\164\1\uffff\1\166\2\172\1\uffff\1\145\1\141\1\172\1\uffff"+
        "\1\172\1\uffff\1\172\1\164\1\151\1\142\1\141\1\163\1\145\1\uffff"+
        "\1\172\1\150\1\172\1\154\1\162\1\172\1\157\3\172\1\163\1\171\1\145"+
        "\1\151\1\uffff\1\143\1\162\1\145\1\151\1\143\1\164\1\162\1\172\1"+
        "\162\1\172\1\uffff\2\172\1\156\2\uffff\2\172\1\145\1\156\1\uffff"+
        "\1\163\1\172\1\151\1\145\1\154\1\150\1\156\1\141\1\142\1\145\1\156"+
        "\1\uffff\1\172\1\uffff\1\145\1\163\1\162\1\uffff\1\143\1\172\1\162"+
        "\1\143\2\145\1\164\1\157\1\150\1\172\1\145\1\uffff\1\172\3\uffff"+
        "\1\172\1\uffff\1\172\1\147\1\163\1\145\1\156\2\172\1\147\1\143\1"+
        "\154\1\172\1\164\1\uffff\1\172\1\145\1\171\1\162\1\145\1\141\3\172"+
        "\1\156\1\172\1\uffff\1\172\1\uffff\2\172\1\167\1\172\1\uffff\1\172"+
        "\1\153\1\145\1\uffff\1\172\1\uffff\1\143\1\172\1\151\1\156\1\164"+
        "\3\uffff\1\172\4\uffff\1\172\2\uffff\1\163\1\172\1\uffff\1\164\1"+
        "\uffff\1\160\1\143\1\145\2\uffff\1\172\1\uffff\1\151\1\164\1\145"+
        "\1\163\1\uffff\1\157\3\172\1\156\1\uffff\1\172";
    static final String DFA30_acceptS =
        "\4\uffff\1\4\1\uffff\1\10\17\uffff\1\31\7\uffff\1\45\1\46\1\51\1"+
        "\53\7\uffff\1\103\1\105\1\106\1\107\1\110\1\111\1\112\1\113\1\116"+
        "\3\uffff\1\2\1\6\1\7\1\3\36\uffff\1\25\1\47\1\50\1\26\1\40\1\120"+
        "\1\32\24\uffff\1\44\1\54\13\uffff\1\117\1\1\15\uffff\1\57\20\uffff"+
        "\1\20\1\uffff\1\73\26\uffff\1\41\22\uffff\1\101\3\uffff\1\11\2\uffff"+
        "\1\21\4\uffff\1\23\1\uffff\1\67\7\uffff\1\15\3\uffff\1\74\3\uffff"+
        "\1\30\1\uffff\1\114\7\uffff\1\70\16\uffff\1\63\12\uffff\1\77\3\uffff"+
        "\1\12\1\17\4\uffff\1\115\13\uffff\1\37\1\uffff\1\72\3\uffff\1\60"+
        "\13\uffff\1\61\1\uffff\1\43\1\64\1\76\1\uffff\1\13\14\uffff\1\55"+
        "\13\uffff\1\36\1\uffff\1\102\4\uffff\1\27\3\uffff\1\42\1\uffff\1"+
        "\75\5\uffff\1\56\1\65\1\52\1\uffff\1\16\1\35\1\14\1\34\1\uffff\1"+
        "\22\1\66\2\uffff\1\62\1\uffff\1\104\3\uffff\1\5\1\24\1\uffff\1\100"+
        "\4\uffff\1\33\5\uffff\1\71\1\uffff";
    static final String DFA30_specialS =
        "\u018a\uffff}>";
    static final String[] DFA30_transitionS = {
            "\2\36\2\uffff\1\36\22\uffff\1\36\1\26\1\37\2\uffff\1\41\1\6"+
            "\1\uffff\1\53\1\52\1\41\1\31\1\56\1\20\1\42\1\35\12\62\1\51"+
            "\1\4\1\17\1\2\1\26\2\uffff\7\61\1\25\1\61\1\22\7\61\1\24\5\61"+
            "\1\23\2\61\1\55\1\40\1\54\1\uffff\1\61\1\uffff\1\10\1\16\1\32"+
            "\1\47\1\7\1\5\1\21\1\43\1\34\1\45\1\50\1\30\1\33\1\27\1\15\1"+
            "\14\1\46\1\1\1\13\1\44\1\12\1\61\1\11\3\61\1\57\1\3\1\60",
            "\1\63\17\uffff\1\64",
            "\1\26\1\65",
            "\1\67",
            "",
            "\1\73\7\uffff\1\74\5\uffff\1\72\5\uffff\1\71",
            "",
            "\1\100\1\75\2\uffff\1\76\4\uffff\1\77",
            "\1\105\1\uffff\1\102\1\uffff\1\101\2\uffff\1\103\1\uffff\1"+
            "\104",
            "\1\110\2\uffff\1\107\1\106",
            "\1\112\12\uffff\1\113\4\uffff\1\111",
            "\1\114\11\uffff\1\116\1\117\4\uffff\1\115",
            "\1\121\7\uffff\1\122\10\uffff\1\120",
            "\1\125\7\uffff\1\124\3\uffff\1\123",
            "\1\126",
            "\1\127\16\uffff\1\130\77\uffff\1\131",
            "\1\134\1\uffff\12\62\3\uffff\1\133\1\132",
            "\1\136",
            "\1\137",
            "\1\140",
            "\1\141",
            "\1\142",
            "",
            "\1\143\11\uffff\1\144",
            "\1\147\1\uffff\1\146\3\uffff\1\145\5\uffff\1\150",
            "\1\133",
            "\1\151\6\uffff\1\152\12\uffff\1\154\1\uffff\1\153",
            "\1\155\3\uffff\1\156\11\uffff\1\157",
            "\1\160\7\uffff\1\161",
            "\1\162\4\uffff\1\162",
            "",
            "",
            "",
            "",
            "\12\134\13\uffff\1\134\37\uffff\1\134",
            "\1\165\3\uffff\1\164\3\uffff\1\166",
            "\1\167\20\uffff\1\170",
            "\1\172\15\uffff\1\171",
            "\1\173",
            "\1\174\13\uffff\1\175",
            "\1\176",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\134\1\uffff\12\62",
            "\1\u0080\100\uffff\1\u0081\1\u0082",
            "\1\u0083",
            "",
            "",
            "",
            "",
            "\1\u0084",
            "\1\u0085",
            "\1\u0086\2\uffff\1\u0087",
            "\1\u0088",
            "\1\u0089",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u008a",
            "\1\u008b",
            "\1\u008c",
            "\1\u008d",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u008f",
            "\1\u0090",
            "\1\u0091",
            "\1\u0092",
            "\1\u0093",
            "\1\u0095\3\uffff\1\u0094",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0096",
            "\1\u0098\16\uffff\1\u0097",
            "\1\u0099",
            "\1\u009a",
            "\1\u009b",
            "\1\u009c",
            "\1\u009d",
            "\1\u009e",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\2\61\1\u00a0\27\61",
            "\1\u00a2",
            "\1\u00a3",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "\1\u00a4",
            "\1\u00a5",
            "\1\u00a6",
            "\1\u00a7",
            "\1\u00a8",
            "\1\u00a9",
            "\1\u00aa",
            "\1\u00ab",
            "\1\u00ac",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00ad",
            "\1\u00af\10\uffff\1\u00ae",
            "\1\u00b0",
            "\1\u00b1",
            "\1\u00b2",
            "\1\u00b5\1\uffff\1\u00b3\1\uffff\1\u00b4",
            "\1\u00b6",
            "\1\u00b7",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00b9",
            "",
            "",
            "\1\u00ba",
            "\1\u00bb",
            "\1\u00bc",
            "\1\u00bd",
            "\1\u00be",
            "\1\u00bf",
            "\1\u00c0",
            "\1\u00c1",
            "\1\u00c2",
            "\1\u00c3",
            "\1\u00c4",
            "",
            "",
            "\1\u00c5",
            "\1\u00c6",
            "\1\u00c7",
            "\1\u00c8",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\4\61\1\u00c9\1\61"+
            "\1\u00ca\23\61",
            "\1\u00cc",
            "\1\u00cd",
            "\1\u00ce",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00d0",
            "\1\u00d1",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u00d3",
            "\1\u00d4",
            "\1\u00d5",
            "\1\u00d6",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00d8",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00da\1\uffff\1\u00db",
            "\1\u00dc",
            "\1\u00dd",
            "\1\u00de",
            "\1\u00df",
            "\1\u00e0",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00e2",
            "\1\u00e3",
            "",
            "\1\u00e4",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00e6",
            "\1\u00e7",
            "\1\u00e8",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00ea",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00ec",
            "\1\u00ed",
            "\1\u00ee",
            "\1\u00ef",
            "\1\u00f0",
            "\1\u00f1",
            "\1\u00f2",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00f4",
            "\1\u00f5",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00f6",
            "\1\u00f7",
            "",
            "\1\u00f8",
            "\1\u00f9",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u00fa",
            "\1\u00fb",
            "\1\u00fc",
            "\1\u00fd",
            "\1\u00fe",
            "\1\u00ff",
            "\1\u0100",
            "\1\u0101",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0103",
            "\1\u0104",
            "\1\u0105",
            "\1\u0106",
            "\1\u0107",
            "\1\u0108",
            "",
            "\1\u0109",
            "\1\u010a",
            "\1\u010b",
            "",
            "\1\u010c",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u010e",
            "\1\u010f",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\10\61\1\u0110\21"+
            "\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u0113",
            "",
            "\1\u0114",
            "\1\u0115",
            "\1\u0116",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0118",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0119",
            "",
            "\1\u011a",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u011b",
            "\1\u011c",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u011d",
            "\1\u011e",
            "\1\u011f",
            "\1\u0120",
            "\1\u0121",
            "\1\u0122",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0124",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0126",
            "\1\u0127",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0128",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u012a",
            "\1\u012b",
            "\1\u012c",
            "\1\u012d",
            "",
            "\1\u012e",
            "\1\u012f",
            "\1\u0130",
            "\1\u0131",
            "\1\u0132",
            "\1\u0133",
            "\1\u0134",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0136",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u013a",
            "",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u013c",
            "\1\u013d",
            "",
            "\1\u013e",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u013f",
            "\1\u0140",
            "\1\u0141",
            "\1\u0142",
            "\1\u0143",
            "\1\u0144",
            "\1\u0145",
            "\1\u0146",
            "\1\u0147",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u0149",
            "\1\u014a",
            "\1\u014b",
            "",
            "\1\u014c",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u014d",
            "\1\u014e",
            "\1\u014f",
            "\1\u0150",
            "\1\u0151",
            "\1\u0152",
            "\1\u0153",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0155",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0157",
            "\1\u0158",
            "\1\u0159",
            "\1\u015a",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u015c",
            "\1\u015d",
            "\1\u015e",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0160",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0162",
            "\1\u0163",
            "\1\u0164",
            "\1\u0165",
            "\1\u0166",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u016a",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u016f",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0172",
            "\1\u0173",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u0175",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0177",
            "\1\u0178",
            "\1\u0179",
            "",
            "",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "",
            "",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "",
            "\1\u017c",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u017e",
            "",
            "\1\u017f",
            "\1\u0180",
            "\1\u0181",
            "",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "",
            "\1\u0183",
            "\1\u0184",
            "\1\u0185",
            "\1\u0186",
            "",
            "\1\u0187",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61",
            "\1\u0189",
            "",
            "\12\61\7\uffff\32\61\4\uffff\1\61\1\uffff\32\61"
    };

    static final short[] DFA30_eot = DFA.unpackEncodedString(DFA30_eotS);
    static final short[] DFA30_eof = DFA.unpackEncodedString(DFA30_eofS);
    static final char[] DFA30_min = DFA.unpackEncodedStringToUnsignedChars(DFA30_minS);
    static final char[] DFA30_max = DFA.unpackEncodedStringToUnsignedChars(DFA30_maxS);
    static final short[] DFA30_accept = DFA.unpackEncodedString(DFA30_acceptS);
    static final short[] DFA30_special = DFA.unpackEncodedString(DFA30_specialS);
    static final short[][] DFA30_transition;

    static {
        int numStates = DFA30_transitionS.length;
        DFA30_transition = new short[numStates][];
        for (int i=0; i<numStates; i++) {
            DFA30_transition[i] = DFA.unpackEncodedString(DFA30_transitionS[i]);
        }
    }

    class DFA30 extends DFA {

        public DFA30(BaseRecognizer recognizer) {
            this.recognizer = recognizer;
            this.decisionNumber = 30;
            this.eot = DFA30_eot;
            this.eof = DFA30_eof;
            this.min = DFA30_min;
            this.max = DFA30_max;
            this.accept = DFA30_accept;
            this.special = DFA30_special;
            this.transition = DFA30_transition;
        }
        public String getDescription() {
            return "1:1: Tokens : ( REX | ARROW_RIGHT | PIPE | SEMI | FUNCTION | EQUAL | OR | AND | VAR_DOMAIN | WITH | USING | SETTING | PRE | FOREACH | WHEN | OR_OR | AND_AND | BETWEEN | WEB | PAGEVIEW | LEFT_SMALL_ARROW | RIGHT_SMALL_ARROW | GLOBAL | DTYPE | PREDOP | ADD_OP | CALLBACKS | SUCCESS | FAILURE | FORGET | MARK | COUNTER_OP | IF | CHOOSE | EVERY | COMMENT | WS | STRING | HTML | JS | ESC_SEQ | RULE_SET | MULT_OP | DOT | MATCH | REPLACE | OTHER_OPERATORS | TRUE | FALSE | CURRENT | KEY | AUTHZ | REQUIRE | LOGGING | USE | CSS | JAVASCRIPT | META | ON | OFF | MODULE | ALIAS | EMIT | CACHABLE | FOR | WITHIN | COLON | HISTORY | RIGHT_PAREN | LEFT_PAREN | RIGHT_BRACKET | LEFT_BRACKET | COMMA | LEFT_CURL | RIGHT_CURL | NOT | SEEN | VAR | INT | FLOAT );";
        }
    }
 

}