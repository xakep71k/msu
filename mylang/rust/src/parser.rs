use crate::lex::Kind;
use std::io;

pub struct Parser {
    tid: crate::tid::TIDType,
    scan: crate::scanner::Scanner,
    curr_lex: crate::lex::Lex,
    c_type: Kind,
    c_val: i32,
    c_str_val: String,
    st_int: Vec<i32>,
    st_lex: Vec<crate::lex::Lex>,
}

impl Parser {
    pub fn new<'a>(filename: &str, tid: crate::tid::TIDType) -> io::Result<Parser> {
        let scan = crate::scanner::Scanner::new(filename)?;
        let parser = Parser {
            tid,
            scan,
            curr_lex: crate::lex::Lex::default(),
            c_type: Kind::default(),
            c_val: 0,
            c_str_val: String::new(),
            st_int: Vec::new(),
            st_lex: Vec::new(),
        };
        Ok(parser)
    }
    pub fn poliz(&self) -> Vec<crate::lex::Lex> {
        vec![]
    }
    pub fn tid(self) -> crate::tid::TIDType {
        self.tid
    }
    pub fn analyze(&mut self) {
        self.next_lex();
        self.Program();
        if self.c_type != Kind::FIN {
            eprintln!("expected @ but found {}", self.c_str_val);
            std::process::exit(1);
        }
    }
    fn Program(&mut self) {
        if self.c_type != Kind::PROGRAM {
            eprintln!("expected program but found {}", self.c_str_val);
            std::process::exit(1);
        }
    }
    fn next_lex(&mut self) {
        self.curr_lex = self.scan.get_lex(&mut self.tid);
        self.c_type = self.curr_lex.kind();
        self.c_val = self.curr_lex.value();
        self.c_str_val = self.curr_lex.value_str();
    }
}
