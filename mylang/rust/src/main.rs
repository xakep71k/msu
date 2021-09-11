mod executer;
mod ident;
mod ident_func;
mod lex;
mod parser;
mod scanner;
mod tid;

fn main() {
    let mut args = std::env::args();
    if args.len() != 2 {
        eprintln!("Usage: {} <source file>", args.nth(0).unwrap());
        std::process::exit(1);
    }

    let mut tid = crate::tid::TIDType::new();
    let mut poliz: Vec<crate::lex::Lex> = vec![];
    crate::executer::execute_poliz(poliz, &tid);
}
