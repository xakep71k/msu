use crate::ident;
use crate::lex;

pub struct IdentFunc {
    args: Vec<crate::ident::Ident>,
    return_lex: crate::lex::Lex,
    return_val: i32,
    ident: crate::ident::Ident,
}

impl IdentFunc {
    pub fn new() -> IdentFunc {
        IdentFunc::from_ident(ident::Ident::new(String::new()))
    }

    pub fn from_ident(ident: ident::Ident) -> IdentFunc {
        IdentFunc {
            args: Vec::new(),
            return_lex: lex::Lex::new(lex::Kind::NULL, 0, String::new()),
            return_val: 0,
            ident: ident,
        }
    }
}
