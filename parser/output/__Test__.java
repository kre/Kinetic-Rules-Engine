import java.io.*;
import org.antlr.runtime.*;
import org.antlr.runtime.debug.DebugEventSocketProxy;

import com.kynetx.*;


public class __Test__ {

    public static void main(String args[]) throws Exception {
        RuleSetLexer lex = new RuleSetLexer(new ANTLRFileStream("/Users/ciddennis/Development/krl_engine/parser/output/__Test___input.txt", "UTF8"));
        CommonTokenStream tokens = new CommonTokenStream(lex);

        RuleSetParser g = new RuleSetParser(tokens, 49100, null);
        try {
            g.ruleset();
        } catch (RecognitionException e) {
            e.printStackTrace();
        }
    }
}