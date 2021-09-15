use crate::lex;
use crate::tid;
use std::collections::HashMap;
use std::io::BufRead;

pub fn execute_poliz(poliz: Vec<crate::lex::Lex>, tid: tid::TIDType) {
    let mut args: Vec<i32> = Vec::new();
    let mut idents_stack: Vec<HashMap<i32, crate::ident::Ident>> = Vec::new();
    idents_stack.push(HashMap::new());

    let mut index: i32 = 0;
    let mut j;
    let mut i;
    let size = poliz.len() as i32;

    while index < size {
        let idents = idents_stack.last_mut().unwrap();
        let pc_el = &poliz[index as usize];
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
                let ident = idents.get(&i);
                if ident.is_none() {
                    eprintln!("POLIZ: unknown address {}", i);
                    std::process::exit(1);
                }
                if !ident.unwrap().assign() {
                    eprintln!("POLIZ: not assigned: name '{}' {}", ident.unwrap().id(), i);
                    std::process::exit(1);
                }

                args.push(ident.unwrap().value());
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
                index = pc_el.value() - 1;
                idents_stack.push(HashMap::new());
            }
            lex::Kind::POLIZ_GO => {
                i = args.pop().unwrap();
                index = i - 1;
            }
            lex::Kind::POLIZ_RETURN_FUNC => {
                j = args.pop().unwrap();
                let ident = idents.get(&j);
                if ident.is_none() {
                    eprintln!("return value not assigned: {}", tid[j as usize].name());
                    std::process::exit(1);
                }
                i = args.pop().unwrap();
                index = i - 1;
                args.push(ident.unwrap().value());
                idents_stack.pop();
            }
            lex::Kind::POLIZ_DUP => {
                args.push(*args.last().unwrap());
            }
            lex::Kind::POLIZ_FGO => {
                i = args.pop().unwrap();
                j = args.pop().unwrap();
                if j == 0 {
                    index = i - 1;
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
                let index = i as usize;
                match tid[index].kind() {
                    lex::Kind::INT => loop {
                        println!("Input int value for {} ", tid[index].name());
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

                let ident = idents.get(&i);
                if ident.is_none() || !ident.unwrap().assign() {
                    idents.insert(i, tid[i as usize].clone());
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
                if idents.get(&j).is_none() {
                    let mut ident = crate::ident::Ident::new(String::new());
                    ident.put_value(i);
                    idents.insert(j, ident);
                } else {
                    idents.get_mut(&j).unwrap().put_value(i);
                }
            }
            lex::Kind::POLIZ_INIT_FUNC_ARG => {
                j = args.pop().unwrap();
                i = args.pop().unwrap();
                let mut ident = crate::ident::Ident::new(String::new());
                ident.put_value(i);
                idents.insert(j, ident);
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
