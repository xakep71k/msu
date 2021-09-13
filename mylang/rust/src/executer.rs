use crate::lex;
use crate::tid;
use std::collections::HashMap;
use std::io::BufRead;

pub fn execute_poliz(poliz: Vec<crate::lex::Lex>, tid: tid::TIDType) {
    let mut args: Vec<i32> = Vec::new();
    let mut idents_stack: Vec<HashMap<i32, crate::ident::Ident>> = Vec::new();
    idents_stack.push(HashMap::new());

    let mut index = 0;
    let mut j;
    let mut i;
    let size = poliz.len();

    while index < size {
        let mut idents = idents_stack.last().unwrap().clone();
        let pc_el = &poliz[index];
        match pc_el.kind() {
            lex::Kind::TRUE
            | lex::Kind::FALSE
            | lex::Kind::NUM
            | lex::Kind::POLIZ_ADDRESS
            | lex::Kind::POLIZ_LABEL => {
                args.push(pc_el.value());
            }
            lex::Kind::ID => {
                i = pc_el.value();
                let ident = idents.get(&i).unwrap();
                if !ident.assign() {
                    eprintln!("POLIZ: not assigned: name '{}'", ident.id());
                    std::process::exit(1);
                }

                args.push(ident.value());
            }
            lex::Kind::NOT => {
                let i = args.pop().unwrap();
                let v = if i == 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::OR => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                let v = if i != 0 || j != 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::AND => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                let v = if i != 0 && j != 0 { 1 } else { 0 };
                args.push(v);
            }
            lex::Kind::POLIZ_CALL_FUNC => {
                index = (pc_el.value() - 1) as usize;
                idents_stack.push(HashMap::new());
            }
            lex::Kind::POLIZ_GO => {
                i = args.pop().unwrap();
                index = (i - 1) as usize;
            }
            lex::Kind::POLIZ_RETURN_FUNC => {
                j = args.pop().unwrap();
                let ident = idents.get(&j).unwrap();
                if !ident.assign() {
                    eprintln!("return value not assigned: {}", tid[j as usize].name());
                    std::process::exit(1);
                }
                i = args.pop().unwrap();
                index = (i - 1) as usize;
                args.push(ident.value());
                idents_stack.pop();
            }
            lex::Kind::POLIZ_DUP => {
                args.push(*args.last().unwrap());
            }
            lex::Kind::POLIZ_FGO => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                if j == 0 {
                    index = (i - 1) as usize;
                }
            }
            lex::Kind::WRITE => {
                j = args.pop().unwrap();
                print!("{}", j);
            }
            lex::Kind::WRITELN => {
                j = args.pop().unwrap();
                println!("{}", j);
            }
            lex::Kind::READ => {
                let k: i32;
                i = args.pop().unwrap();
                match tid[i as usize].kind() {
                    lex::Kind::INT => loop {
                        let res = std::io::stdin()
                            .lock()
                            .lines()
                            .next()
                            .expect("stdin should be available")
                            .expect("couldn't read from stdin")
                            .trim()
                            .parse::<i32>();
                        match res {
                            Ok(i) => {
                                k = i;
                                break;
                            }
                            _ => {
                                println!("please input int32");
                            }
                        }
                    },
                    lex::Kind::BOOL => loop {
                        let res = std::io::stdin()
                            .lock()
                            .lines()
                            .next()
                            .expect("stdin should be available")
                            .expect("couldn't read from stdin")
                            .trim()
                            .parse::<bool>();
                        match res {
                            Ok(b) => {
                                k = b as i32;
                                break;
                            }
                            _ => {
                                println!("please input true or false");
                            }
                        }
                    },
                    _ => {
                        println!(
                            "unknown type {} {:?}",
                            tid[i as usize].value(),
                            tid[i as usize].kind()
                        );
                        std::process::exit(1);
                    }
                }

                if !idents.get(&i).unwrap().assign() {
                    *idents.get_mut(&i).unwrap() = tid[i as usize].clone();
                }
                idents.get_mut(&i).unwrap().put_value(k);
            }
            lex::Kind::PLUS => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push(i + j);
            }
            lex::Kind::TIMES => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push(i * j);
            }
            lex::Kind::MINUS => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push(j - i);
            }
            lex::Kind::SLASH => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                if i == 0 {
                    eprintln!("POLIZ:divide by zero");
                    std::process::exit(1);
                }
                args.push(j / i);
            }
            lex::Kind::EQ => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((i == j) as i32);
            }
            lex::Kind::LSS => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((j < i) as i32);
            }
            lex::Kind::GTR => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((j > i) as i32);
            }
            lex::Kind::LEQ => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((j <= i) as i32);
            }
            lex::Kind::GEQ => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((j >= i) as i32);
            }
            lex::Kind::NEQ => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                args.push((j != i) as i32);
            }
            lex::Kind::ASSIGN => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                idents.get_mut(&j).unwrap().put_value(i);
            }
            lex::Kind::POLIZ_INIT_FUNC_ARG => {
                j = args.pop().unwrap();
                i = args.pop().unwrap();
                idents.get_mut(&j).unwrap().put_value(i);
            }
            lex::Kind::POLIZ_FAIL => {
                eprintln!("{}", pc_el.value_str());
                std::process::exit(1);
            }
            lex::Kind::POLIZ_DEL_ARG => {
                args.pop();
            }
            default => {
                eprintln!("POLIZ: unexpected elem: {:?}", default);
                std::process::exit(1);
            }
        }
        index += 1;
    }

    if args.len() != 0 {
        eprintln!("executer: args stack not empty");
        std::process::exit(1);
    }
}
