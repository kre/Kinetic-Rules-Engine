. ./myclasspath.sh
java org.antlr.Tool RuleSet.g -o output
mkdir output/classes
javac -d output/classes  output/RuleSet*.java json_java/*.java ParseRuleset.java FullParserReport.java SimpleMethod.java RubyRulesetParser.java
cd output/classes
jar -xf ../../lib/antlr-3.3-complete.jar
jar -cf ../../krl_parser.jar *
cd ../..
