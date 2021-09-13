use crate::ident;
use crate::lex;

pub struct IdentFunc {
    args: Vec<crate::ident::Ident>,
    return_lex: crate::lex::Lex,
    return_var: i32,
    ident: crate::ident::Ident,
}

impl IdentFunc {
    pub fn new() -> IdentFunc {
        IdentFunc::from_ident(&ident::Ident::new(String::new()))
    }

    pub fn from_ident(ident: &ident::Ident) -> IdentFunc {
        IdentFunc {
            args: Vec::new(),
            return_lex: lex::Lex::new(lex::Kind::NULL, 0, String::new()),
            return_var: 0,
            ident: ident.clone(),
        }
    }
    pub fn push_arg(&mut self, ident: ident::Ident) {
        self.args.push(ident.clone());
    }
    pub fn set_return_lex(&mut self, lex: lex::Lex) {
        self.return_lex = lex;
    }
    pub fn set_return_var(&mut self, i: i32) {
        self.return_var = i;
    }
    pub fn get_return_lex(&self) -> lex::Lex {
        self.return_lex.clone()
    }
    pub fn name(&self) -> &str {
        self.ident.name()
    }
}
