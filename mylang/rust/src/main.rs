mod executer;
mod ident;
mod ident_func;
mod lex;
mod parser;
mod scanner;
mod tid;
use std::time::Instant;

fn main() -> std::io::Result<()> {
    let mut args = std::env::args();
    if args.len() != 2 {
        eprintln!("Usage: {} <source file>", args.nth(0).unwrap());
        std::process::exit(1);
    }

    let parser = match crate::parser::Parser::new(&args.nth(1).unwrap()) {
        Ok(parser) => parser,
        Err(err) => return Err(err),
    };

    let now = Instant::now();
    let (poliz, tid) = parser.analyze();
    let elapsed = now.elapsed();
    println!("Analyzed: time difference = {:?}", elapsed);
    let now = Instant::now();
    crate::executer::execute_poliz(poliz, &tid);
    let elapsed = now.elapsed();
    println!("Executed: time difference = {:?}", elapsed);
    Ok(())
}
