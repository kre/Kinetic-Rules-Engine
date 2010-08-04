package com.kynetx;
import org.antlr.runtime.*;
import java.io.*;
import org.json.*;

public class ParseRuleset 
	{ 
		public static String[] ignore = {"a143x3","a97x1","a93x16","a93x12","a90x3","a66x1","a60x58","a60x52","a60x181",
		"a60x179","a60x175","a60x174","a60x166","a60x163","a60x162","a60x16","a60x149","a58x9","a58x6","a58x4",
		"a58x19","a58x17","a58x10","a50x3","a50x1","a32x1","a314x3","a278x7","a25x3","996337883","996337898",
		"996337917","996337924","996337973","a22x5","a22x1","a16x3","a166x8","a143x3","996338076","996338051",
		"996338044","996338036","996338035","996338020","996338012","996338001","996338000","996337991","996337987",
		"996337986","996337985","996337985","996337982","996337981","996337980","996337979","996337978","996337977",
		"996337976","996337975","996337974","996337973","996337972","996337970","996337969","996337964","996337951",
		"996337950","996337947","996337926","996337925","996337924","996337917","996337898","996337883","1024dev" };
		
		public static void main(String[] args) throws Exception 
		{
			File f = new File(args[0]);
			int notparsed = 0;
			int parsed = 0;
			
			File[] files = null;
			if(f.isDirectory())
			{
				files = f.listFiles();
			}
			else
			{
				files = new File[1];
				files[0] = new File(args[0]);
			}
			for(int i =0;i< files.length;i++)
			{	
				File thefile = files[i];
				long start = System.currentTimeMillis();
				boolean  skipfile = false;
				for(int ii = 0;ii<ignore.length;ii++)
				{
					if(thefile.getCanonicalPath().indexOf(ignore[ii]+".krl") > 0)
					{
						skipfile = true;
						break;
					}
				}
				if(thefile.length() == 0 || thefile.length() == 31 ||  thefile.length() == 162 || skipfile)
				{
					notparsed = notparsed + 1;
//					System.out.println("Skipping: " + thefile + " in " + (System.currentTimeMillis() - start) + "ms." );
//					System.out.println("Skipping " + thefile);
					continue;
				}
				parsed = parsed + 1;
				try
				{
					ANTLRFileStream input = new ANTLRFileStream(thefile.getCanonicalPath() );
					com.kynetx.RuleSetLexer lexer = new com.kynetx.RuleSetLexer(input); 
					CommonTokenStream tokens = new CommonTokenStream(lexer); 
					com.kynetx.RuleSetParser parser = new com.kynetx.RuleSetParser(tokens);
					parser.ruleset();			
					JSONObject js = new JSONObject(parser.rule_json);
//					System.out.println("Parsed: " + thefile + " in " + (System.currentTimeMillis() - start) + "ms." );
					System.out.println(js.toString(3));
				}
				catch(Exception e)
				{
//					System.out.println("Error: " + thefile + " in " + (System.currentTimeMillis() - start) + "ms." );
//					System.out.println("Error "  + thefile +  " " + e.getMessage());
				}
			}
//			System.out.println("Not Parsed " + notparsed);
//			System.out.println("Parsed " + parsed);
			
		}
}
