#[derive(Copy, Clone, Debug)]
pub enum Kind {
    NULL, //0
    AND,
    BEGIN, //2
    BOOL,
    DO, //4
    ELSE,
    END, //6
    IF,
    FALSE, //8
    INT,
    NOT, //10
    OR,
    PROGRAM, //12
    READ,
    THEN, // 14
    TRUE,
    VAR, // 16
    WHILE,
    WRITE, //18
    WRITELN,
    CASE, //20
    OF,
    FUNCTION, //22
    FIN,
    SEMICOLON, //24
    COMMA,
    COLON, //26
    ASSIGN,
    LPAREN, //28
    RPAREN,
    EQ, //30
    LSS,
    GTR, //32
    PLUS,
    MINUS, //34
    TIMES,
    SLASH, //36
    LEQ,
    NEQ, //38
    GEQ,
    NUM, //40
    ID,
    POLIZ_LABEL, //42
    POLIZ_FAIL,
    POLIZ_ADDRESS, //44
    POLIZ_GO,
    POLIZ_FGO, //46
    POLIZ_DUP,
    POLIZ_DEL_ARG, //48
    POLIZ_CALL_FUNC,
    POLIZ_RETURN_FUNC, //50
    POLIZ_INIT_FUNC_ARG,
}

#[derive(Default)]
pub struct Lex {
    kind: Kind,
    value: i32,
    value_str: String,
}

impl std::default::Default for Kind {
    fn default() -> Kind {
        Kind::NULL
    }
}

impl Lex {
    pub fn new(kind: Kind, value: i32, value_str: String) -> Lex {
        return Lex {
            kind,
            value,
            value_str,
        };
    }

    pub fn value(&self) -> i32 {
        self.value
    }

    pub fn value_str(&self) -> i32 {
        self.value
    }

    pub fn kind(&self) -> Kind {
        self.kind
    }
}
