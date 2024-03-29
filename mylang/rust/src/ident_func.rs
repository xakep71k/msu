use crate::ident;
use crate::lex;
use std::ops::{Index, IndexMut};

pub struct IdentFunc {
    args: Vec<crate::ident::Ident>,
    return_lex: crate::lex::Lex,
    return_var: i32,
    ident: crate::ident::Ident,
}

impl IdentFunc {
    pub fn from_ident(ident: ident::Ident) -> IdentFunc {
        IdentFunc {
            args: Vec::new(),
            return_lex: lex::Lex::new(lex::Kind::NULL, 0, String::new()),
            return_var: 0,
            ident: ident,
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
    pub fn value(&self) -> i32 {
        self.ident.value()
    }
    pub fn kind(&self) -> crate::lex::Kind {
        self.ident.kind()
    }
    pub fn clone_args(&self) -> Vec<crate::ident::Ident> {
        self.args.clone()
    }
}

impl Index<usize> for IdentFunc {
    type Output = crate::ident::Ident;

    fn index(&self, index: usize) -> &Self::Output {
        &self.args[index]
    }
}

impl IndexMut<usize> for IdentFunc {
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.args[index]
    }
}
