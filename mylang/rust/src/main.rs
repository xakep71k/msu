mod executer;
mod ident;
mod ident_func;
mod lex;
mod parser;
mod scanner;
mod tid;

fn main() -> std::io::Result<()> {
    let mut args = std::env::args();
    if args.len() != 2 {
        eprintln!("Usage: {} <source file>", args.nth(0).unwrap());
        std::process::exit(1);
    }

    let tid = crate::tid::TIDType::new();
    let mut parser = match crate::parser::Parser::new(&args.nth(1).unwrap(), tid) {
        Ok(parser) => parser,
        Err(err) => return Err(err),
    };

    parser.analyze();
    let poliz = parser.poliz();
    let tid = parser.tid();
    crate::executer::execute_poliz(poliz, tid);
    Ok(())
}
