use crate::lex;
use crate::tid;
use std::collections::HashMap;
use std::io::BufRead;

pub fn execute_poliz(poliz: Vec<crate::lex::Lex>, tid: &tid::TIDType) {
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

/*
pub fn execute_poliz(poliz: Vec<crate::lex::Lex>, tid: &tid::TIDType) {
    let mut args: Vec<i32> = Vec::new();
    let mut idents_stack: Vec<HashMap<i32, Ident>> = Vec::new();
    idents_stack.push(HashMap::new());

    let mut index: i32 = 0;
    let mut j;
    let mut i;
    let size = poliz.len() as i32;
    let handlers: Vec<
        &dyn Fn(
            &mut i32,
            &mut i32,
            &mut Vec<i32>,
            &mut Vec<HashMap<i32, Ident>>,
            &lex::Lex,
            &mut i32,
            &tid::TIDType,
        ),
    > = vec![
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {}, // 0
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // AND
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            let v = if *i != 0 && *j != 0 { 1 } else { 0 };
            args.push(v);
        },
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* BEGIN */ }, // 2
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* BOOL */ },
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* DO */ }, // 4
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* ELSE */ },
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* END */ }, // 6
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* IF */ },
        &|_: &mut i32,
          _: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // FALSE
            args.push(pc_el.value());
        }, // 8
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* INT */ },
        &|i: &mut i32,
          _: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // NOT
            *i = args.pop().unwrap();
            let v = if *i == 0 { 1 } else { 0 };
            args.push(v);
        }, // 10
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // OR
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            let v = if *i != 0 || *j != 0 { 1 } else { 0 };
            args.push(v);
        },
        &|_: &mut i32,
          _: &mut i32,
          _: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* PROGRAM */ }, // 12
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // READ
            let idents = idents_stack.last_mut().unwrap();
            let mut k: i32 = 0;
            *i = args.pop().unwrap();
            match tid[*i as usize].kind() {
                lex::Kind::INT => loop {
                    println!("Input int value for {} ", tid[*i as usize].name());
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
                        tid[*i as usize].value(),
                        tid[*i as usize].kind()
                    );
                    std::process::exit(1);
                }
            }

            let ident = idents.get(&i);
            if ident.is_none() || !ident.unwrap().assign() {
                idents.insert(*i, tid[*i as usize].clone());
            }
            idents.get_mut(i).unwrap().put_value(k);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| { /* THEN */ }, // 14
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // TRUE
            args.push(pc_el.value());
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // VAR
        }, // 16
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // WHILE
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // WRITE
            *j = args.pop().unwrap();
            print!("{}", *j);
        }, // 18
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // WRITELN
            *j = args.pop().unwrap();
            println!("{}", *j);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // CASE
        }, // 20
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // OF
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // FUNCTION
        }, // 22
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // FIN
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // SEMICOLON
        }, // 24
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // COMMA
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // COLON
        }, // 26
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // ASSIGN
            let idents = idents_stack.last_mut().unwrap();
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            if idents.get(j).is_none() {
                let mut ident = crate::ident::Ident::new(String::new());
                ident.put_value(*i);
                idents.insert(*j, ident);
            } else {
                idents.get_mut(j).unwrap().put_value(*i);
            }
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // LPAREN
        }, // 28
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // RPAREN
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // EQ
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*i == *j) as i32);
        }, // 30
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // LSS
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*j < *i) as i32);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // GTR
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*j > *i) as i32);
        }, // 32
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // PLUS
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push(*i + *j);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // MINUS
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push(*j - *i);
        }, // 34
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // TIMES
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push(*i * *j);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // SLASH
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            if *i == 0 {
                eprintln!("POLIZ:divide by zero");
                std::process::exit(1);
            }
            args.push(*j / *i);
        }, // 36
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // LEQ
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*j <= *i) as i32);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // NEQ
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*j != *i) as i32);
        }, // 38
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // GEQ
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            args.push((*j >= *i) as i32);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // NUM
            args.push(pc_el.value());
        }, // 40
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // ID
            let idents = idents_stack.last_mut().unwrap();
            *i = pc_el.value();
            let ident = idents.get(i);
            if ident.is_none() {
                eprintln!("POLIZ: unknown address {}", *i);
                std::process::exit(1);
            }
            if !ident.unwrap().assign() {
                eprintln!("POLIZ: not assigned: name '{}' {}", ident.unwrap().id(), *i);
                std::process::exit(1);
            }

            args.push(ident.unwrap().value());
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_LABEL
            args.push(pc_el.value());
        }, // 42
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_FAIL
            eprintln!("{}", pc_el.value_str());
            std::process::exit(1);
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_ADDRESS
            args.push(pc_el.value());
        }, // 44
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_GO
            *i = args.pop().unwrap();
            *index = *i - 1;
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_FGO
            *i = args.pop().unwrap();
            *j = args.pop().unwrap();
            if *j == 0 {
                *index = *i - 1;
            }
        }, // 46
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_DUP
            args.push(*args.last().unwrap());
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_DEL_ARG
            args.pop();
        }, // 48
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_CALL_FUNC
            *index = pc_el.value() - 1;
            idents_stack.push(HashMap::new());
        },
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_RETURN_FUNC
            let idents = idents_stack.last_mut().unwrap();
            *j = args.pop().unwrap();
            let ident = idents.get(j);
            if ident.is_none() {
                eprintln!("return value not assigned: {}", tid[*j as usize].name());
                std::process::exit(1);
            }
            *i = args.pop().unwrap();
            *index = *i - 1;
            args.push(ident.unwrap().value());
            idents_stack.pop();
        }, // 50
        &|i: &mut i32,
          j: &mut i32,
          args: &mut Vec<i32>,
          idents_stack: &mut Vec<HashMap<i32, Ident>>,
          pc_el: &lex::Lex,
          index: &mut i32,
          tid: &tid::TIDType| {
            // POLIZ_INIT_FUNC_ARG
            let idents = idents_stack.last_mut().unwrap();
            *j = args.pop().unwrap();
            *i = args.pop().unwrap();
            let mut ident = crate::ident::Ident::new(String::new());
            ident.put_value(*i);
            idents.insert(*j, ident);
        },
    ];
    i = 0;
    j = 0;
    while index < size {
        // let idents = idents_stack.last_mut().unwrap();
        let pc_el = &poliz[index as usize];
        let ikind = pc_el.kind() as usize;
        handlers[ikind](
            &mut i,
            &mut j,
            &mut args,
            &mut idents_stack,
            &pc_el,
            &mut index,
            tid,
        );
        index += 1;
    }

    if args.len() != 0 {
        eprintln!("executer: args stack not empty");
        std::process::exit(1);
    }
}
*/
