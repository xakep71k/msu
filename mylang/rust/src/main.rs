mod executer;
mod ident;
mod lex;
mod tid;

fn main() {
    let mut args = std::env::args();
    if args.len() != 2 {
        eprintln!("Usage: {} <source file>", args.nth(0).unwrap());
        std::process::exit(1);
    }

    let mut poliz: Vec<crate::lex::Lex> = vec![];
    crate::executer::execute_poliz(poliz);
}
