package com.kynetx;

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
                    if(parser.parse_errors.size() >0)
                    {
                        for(int ii = 0;ii < parser.parse_errors.size() ;ii++)
                        {
                            System.err.println("ERROR FOUND " + parser.parse_errors.get(ii) + " - " + thefile.toString());
                        }
                    }
//					System.out.println("Parsed: " + thefile + " in " + (System.currentTimeMillis() - start) + "ms." );
					//System.out.println(unescapeUnicode(js.toString()));
					System.out.println(js.toString());
					//System.out.println("=============");
					//System.out.println(js.toString());
				}
				catch(Exception e)
				{
//					System.out.println("Error: " + thefile + " in " + (System.currentTimeMillis() - start) + "ms." );
					System.out.println("Error "  + thefile +  " " + e.getMessage());
					e.printStackTrace();
				}
			}
//			System.out.println("Not Parsed " + notparsed);
//			System.out.println("Parsed " + parsed);

		}

        /**
           * Given the input string with escaped unicode characters convert them
           * to their native unicode characters and return the result. This is quite
           * similar to the functionality found in property file handling. White space
           * escapes are not processed (as they are consumed by the template library).
           * Any bogus escape codes will remain in place.
           * <p>
           * When files are provided in another encoding, they can be converted to ascii using
           * the native2ascii tool (a java sdk binary). This tool will escape all the
           * non Latin1 ASCII characters and convert the file into Latin1 with unicode escapes.
           *
           * @param source
           *      string with unicode escapes
           * @return
           *      string with all unicode characters, all unicode escapes expanded.
           *
           * @author Caleb Lyness
           */
        private static String unescapeUnicode(String source) {
             /* could use regular expression, but not this time... */
             final int srcLen = source.length();
             char c;

             StringBuffer buffer = new StringBuffer(srcLen);

             // Must have format \\uXXXX where XXXX is a hexadecimal number
             int i=0;
             while (i <srcLen-5) {

                    c = source.charAt(i++);

                    if (c=='\\') {
                        char nc = source.charAt(i);
                        if (nc == 'u') {

                            // Now we found the u we need to find another 4 hex digits
                            // Note: shifting left by 4 is the same as multiplying by 16
                            int v = 0; // Accumulator
                            for (int j=1; j < 5; j++) {
                                nc = source.charAt(i+j);
                                switch(nc)
                                {
                                    case 48: // '0'
                                    case 49: // '1'
                                    case 50: // '2'
                                    case 51: // '3'
                                    case 52: // '4'
                                    case 53: // '5'
                                    case 54: // '6'
                                    case 55: // '7'
                                    case 56: // '8'
                                    case 57: // '9'
                                        v = ((v << 4) + nc) - 48;
                                        break;

                                    case 97: // 'a'
                                    case 98: // 'b'
                                    case 99: // 'c'
                                    case 100: // 'd'
                                    case 101: // 'e'
                                    case 102: // 'f'
                                        v = ((v << 4)+10+nc)-97;
                                        break;

                                    case 65: // 'A'
                                    case 66: // 'B'
                                    case 67: // 'C'
                                    case 68: // 'D'
                                    case 69: // 'E'
                                    case 70: // 'F'
                                        v = ((v << 4)+10+nc)-65;
                                        break;
                                    default:
                                        // almost but no go
                                        j = 6;  // terminate the loop
                                        v = 0;  // clear the accumulator
                                        break;
                                }
                            } // for each of the 4 digits

                            if (v > 0) {      // We got a full conversion
                                c = (char)v;  // Use the converted char
                                i += 5;       // skip the numeric values
                            }
                        }
                    }
                    buffer.append(c);
                }

        	// Fill in the remaining characters from the buffer
        	while (i <srcLen) {
        		buffer.append(source.charAt(i++));
        	}
        	return buffer.toString();
        }

}
