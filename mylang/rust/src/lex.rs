#[derive(Copy, Clone, Debug, PartialEq)]
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

#[derive(Default, Clone)]
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

    pub fn value_str(&self) -> String {
        self.value_str.clone()
    }

    pub fn kind(&self) -> Kind {
        self.kind
    }
}

impl Kind {
    pub fn from_i32(value: i32) -> Kind {
        match value {
            0 => Kind::NULL,
            1 => Kind::AND,
            2 => Kind::BEGIN,
            3 => Kind::BOOL,
            4 => Kind::DO,
            5 => Kind::ELSE,
            6 => Kind::END,
            7 => Kind::IF,
            8 => Kind::FALSE,
            9 => Kind::INT,
            10 => Kind::NOT,
            11 => Kind::OR,
            12 => Kind::PROGRAM,
            13 => Kind::READ,
            14 => Kind::THEN,
            15 => Kind::TRUE,
            16 => Kind::VAR,
            17 => Kind::WHILE,
            18 => Kind::WRITE,
            19 => Kind::WRITELN,
            20 => Kind::CASE,
            21 => Kind::OF,
            22 => Kind::FUNCTION,
            23 => Kind::FIN,
            24 => Kind::SEMICOLON,
            25 => Kind::COMMA,
            26 => Kind::COLON,
            27 => Kind::ASSIGN,
            28 => Kind::LPAREN,
            29 => Kind::RPAREN,
            30 => Kind::EQ,
            31 => Kind::LSS,
            32 => Kind::GTR,
            33 => Kind::PLUS,
            34 => Kind::MINUS,
            35 => Kind::TIMES,
            36 => Kind::SLASH,
            37 => Kind::LEQ,
            38 => Kind::NEQ,
            39 => Kind::GEQ,
            40 => Kind::NUM,
            41 => Kind::ID,
            42 => Kind::POLIZ_LABEL,
            43 => Kind::POLIZ_FAIL,
            44 => Kind::POLIZ_ADDRESS,
            45 => Kind::POLIZ_GO,
            46 => Kind::POLIZ_FGO,
            47 => Kind::POLIZ_DUP,
            48 => Kind::POLIZ_DEL_ARG,
            49 => Kind::POLIZ_CALL_FUNC,
            50 => Kind::POLIZ_RETURN_FUNC,
            51 => Kind::POLIZ_INIT_FUNC_ARG,
            _ => panic!("not covered kind"),
        }
    }
}
