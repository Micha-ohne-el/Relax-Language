﻿class Tokens extends Enum {
	static Options := "
	(
		IDENTIFIER
		KEYWORD
		
		INTEGER
		DOUBLE
		STRING
		
		LEFT_PAREN
		RIGHT_PAREN
		
		LEFT_BRACE
		RIGHT_BRACE
		
		LEFT_BRACKET
		RIGHT_BRACKET
		
		COMMA
		POUND
		NEWLINE
		EOF
		
		
		OPERATOR
		
		FIRST_PREFIX
			BANG
			BITWISE_NOT
		
			FIRST_POSTFIX
				; The overlap here is since ++/-- are both pre/postfix
				PLUS_PLUS
				MINUS_MINUS
		LAST_PREFIX
			LAST_POSTFIX
		
		; Operator varients so they can be told apart
		
		PLUS_PLUS_L
		PLUS_PLUS_R
		
		MINUS_MINUS_L
		MINUS_MINUS_R
		
		BANG_EQUAL
		
		EQUAL
		EQUAL_EQUAL
		
		GREATER
		GREATER_EQUAL
		
		LESS
		LESS_EQUAL
	
		COLON
		COLON_EQUAL
		
		PLUS
		PLUS_EQUALS
		
		MINUS
		MINUS_EQUALS
		
		DOT
		DOT_EQUALS
		
		TIMES
		TIMES_EQUALS
		
		BITWISE_OR
		LOGICAL_OR
		
		BITWISE_AND
		LOGICAL_AND
		
		BITWISE_XOR
		XOR_EQUALS
		
	)"
}

class CharacterTokens {
	static Operators := {"!": {"NONE": Tokens.BANG, "=": Tokens.BANG_EQUAL}
						,"=": {"NONE": Tokens.EQUAL, "=": Tokens.EQUAL_EQUAL}
						,"<": {"NONE": Tokens.LESS, "=": Tokens.LESS_EQUAL}
						,">": {"NONE": Tokens.GREATER, "=": Tokens.GREATER_EQUAL, "<": Tokens.CONCAT}
						,":": {"NONE": Tokens.COLON, "=": Tokens.COLON_EQUALS}
						,"+": {"NONE": Tokens.PLUS, "+": Tokens.PLUS_PLUS, "=": Tokens.PLUS_EQUALS}
						,"-": {"NONE": Tokens.MINUS, "-": Tokens.MINUS_MINUS, "=": Tokens.MINUS_EQUALS}
						,".": {"NONE": Tokens.DOT, "=": Tokens.DOT_EQUALS}
						,"*": {"NONE": Tokens.TIMES, "=": Tokens.TIMES_EQUALS}
						,"|": {"NONE": Tokens.BITWISE_OR, "|": Tokens.LOGICAL_OR}
						,"&": {"NONE": Tokens.BITWISE_AND, "&": Tokens.LOGICAL_AND}
						,"^": {"NONE": Tokens.BITWISE_XOR, "=": Tokens.XOR_EQUALS}
						,"~": {"NONE": Tokens.BITWISE_NOT}}
				
				
	static Misc := { "(": Tokens.LEFT_PAREN
					,")": Tokens.RIGHT_PAREN
					,"{": Tokens.LEFT_BRACE
					,"}": Tokens.RIGHT_BRACE
					,"[": Tokens.LEFT_BRACKET
					,"]": Tokens.RIGHT_BRACKET
					,",": Tokens.COMMA
					,"#": Tokens.POUND}
}

class OperatorClasses {
	static Prefix	  := {"Precedence": -1
						, "Associative": "Right"
						, "Tokens": [Tokens.PLUS_PLUS, Tokens.MINUS_MINUS, Tokens.BANG, Tokens.BITWISE_NOT]}

	static Assignment := {"Precedence": 0
						, "Associative": "Right"
						, "Tokens": [Tokens.COLON_EQUAL, Tokens.PLUS_EQUALS, Tokens.MINUS_EQUALS, Tokens.DOT_EQUALS, Tokens.TIMES_EQUALS]}
	
	static Equality   := {"Precedence": 1
						, "Associative": "Left"
						, "Tokens": [Tokens.BANG_EQUAL, Tokens.EQUAL, Tokens.EQUAL_EQUAL]}
						
	static Comparison := {"Precedence": 2
						, "Associative": "Right"
						, "Tokens": [Tokens.LESS, Tokens.LESS_EQUAL, Tokens.GREATER, Tokens.GREATER_EQUAL]}
						
	static Concat	  := {"Precedence": 3
						, "Associative": "Left"
						, "Tokens": [Tokens.CONCAT]}
						
	static Addition	  := {"Precedence": 4
						, "Associative": "Left"
						, "Tokens": [Tokens.PLUS, Tokens.MINUS]}
}

class Operators {
	Precedence(Operator) {
		for k, v in OperatorClasses {
			for k, FoundOperator in v.Tokens {
				if (Operator.Value = FoundOperator) {
					return v
				}
			}
		}
	
		MsgBox, % "Fuck off"
	}

	CheckPrecedence(FirstOperator, SecondOperator) {
		OperatorOne := this.Precedence(FirstOperator)
		OperatorTwo := this.Precedence(SecondOperator)
	
		if (OperatorOne.Associative = "Left" && (OperatorOne.Precedence = OperatorTwo.Precedence)) {
			return 1
		}
		else if (OperatorOne.Precedence < OperatorTwo.Precedence) {
			return 1
		}
		else {
			return 0
		}
	}
	OperandCount(Operator) {
		if (this.IsPostfix(Operator) || this.IsPrefix(Operator)) {
			return 1
		}
		else {
			return 2
		}
	}
	
	EnsurePrefix(Operator) {
		return this.EnsureXXXfix(Operator, "_L")
	}
	EnsurePostfix(Operator) {
		return this.EnsureXXXfix(Operator, "_R")
	}
	EnsureXXXfix(Operator, Form) {
		if (this.IsPrefix(Operator) && this.IsPostfix(Operator)) {
			return new Token(Tokens.OPERATOR, Tokens[Tokens[Operator.Value] Form], Operator.Context)
		}
		
		return Operator
	}
	
	IsPostfix(Operator) {
		return Tokens.FIRST_POSTFIX < Operator.Value && Operator.Value < Tokens.LAST_POSTFIX
	}
	IsPrefix(Operator) {
		return Tokens.FIRST_PREFIX < Operator.Value && Operator.Value < Tokens.LAST_PREFIX
	}
}


class Keywords extends Enum {
	static Options := "
	(
		define
	)"
}



class ASTNode {
	__New(Params*) {
		if (Params.Count() != this.Parameters.Count()) {
			Msgbox, % "Not enough parameters passed to " this.__Class ".__New, " Params.Count() " != " this.Parameters.Count()
		}
	
		for k, v in this.Parameters {
			this[v] := Params[k]
		}
		
		this.Type := ASTNodeTypes[StrSplit(this.__Class, ".")[3]] ; Translates ASTNode.Expressions.Identifier into 
		;  just 'Identifier', and then gets the enum value for 'Identifier'
	}
}

class ASTNodeTypes extends Enum {
	static Options := "
	(
		DEFINE
		EXPRESSION
		
		IDENTIFER
		GROUPING
		CALL
		UNARY
		BINARY
	)"
}

class ASTNodes {
	class Statements {
		class Define extends ASTNode {
			static Parameters := ["Name", "ReturnType", "Params", "Body"]
		}
	}
	
	class Expressions {
		class Identifier extends ASTNode {
			static Parameters := ["Name"]
		}
		
		class Grouping extends ASTNode {
			static Parameters := ["Expressions"]
		}
		
		class Unary extends ASTNode {
			static Parameters := ["Operand", "Operator"]
		}
		
		class Binary extends ASTNode {
			static Parameters := ["Left", "Operator", "Right"]
		}
		
		class IntegerLiteral extends ASTNode {
			static Parameters := ["Value"]
		}
		
		class DoubleLiteral extends ASTNode {
			static Parameters := ["Value"]
		}
		
		class Call extends ASTNode {
			static Parameters := ["Target", "Params"]
		}
	}
}