use crate::lex;
use crate::tid;
use std::fs::File;
use std::io::{self, Read};

pub fn look(buf: &str, list: &[&str]) -> i32 {
    for (i, v) in list.iter().enumerate() {
        if *v == buf {
            return i as i32;
        }
    }
    return 0;
}

pub struct Scanner {
    reader: io::BufReader<File>,
    unget: Vec<char>,
}

impl Scanner {
    pub fn new(filename: &str) -> io::Result<Scanner> {
        let f = File::open(filename)?;
        let scanner = Scanner {
            reader: io::BufReader::with_capacity(4096, f),
            unget: Vec::new(),
        };
        return Ok(scanner);
    }

    pub fn gc(&mut self) -> io::Result<char> {
        if self.unget.len() != 0 {
            return Ok(self.unget.pop().unwrap());
        }
        let mut buf: [u8; 1] = [0];
        self.reader.read(&mut buf[..])?;
        return Ok(buf[0] as char);
    }

    pub fn ungc(&mut self, ch: char) {
        self.unget.push(ch);
    }

    pub fn get_lex(&mut self, tid: &mut tid::TIDType) -> lex::Lex {
        #[derive(Copy, Clone)]
        enum State {
            H,
            IDENT,
            NUMB,
            COM,
            ALE,
            NEQ,
        }

        let mut CS = State::H;
        let mut buf: Vec<char> = Vec::new();
        let (mut d, mut j): (i32, i32) = (0, 0);
        loop {
            let c: char;
            match self.gc() {
                Ok(next) => {
                    if next == 0 as char {
                        eprintln!("unexpected EOF");
                        std::process::exit(1);
                    }
                    c = next;
                }
                Err(r) => {
                    eprintln!("error during reading file: {}", r);
                    std::process::exit(1);
                }
            }

            match CS {
                State::H => {
                    if c.is_whitespace() {
                        continue;
                    } else if c.is_alphabetic() {
                        buf.push(c);
                        CS = State::IDENT;
                    } else if c.is_ascii_digit() {
                        d = c.to_digit(10).unwrap() as i32;
                        CS = State::NUMB;
                    } else if c == '{' {
                        CS = State::COM;
                    } else if c == ':' || c == '<' || c == '>' {
                        buf.push(c);
                        CS = State::ALE;
                    } else if c == '@' {
                        return lex::Lex::new(lex::Kind::FIN, 0, String::from(""));
                    } else if c == '!' {
                        buf.push(c);
                        CS = State::NEQ;
                    } else {
                        buf.push(c);
                        let strBuf: String = buf.into_iter().collect();
                        j = look(&strBuf, &TD);
                        if j != 0 {
                            let kind = lex::Kind::from_i32(j + lex::Kind::FIN as i32);
                            return lex::Lex::new(kind, j, strBuf);
                        }
                        eprintln!("identificator not found: {}", strBuf);
                        std::process::exit(1);
                    }
                }
                State::IDENT => {
                    if c.is_ascii_alphanumeric() {
                        buf.push(c);
                    } else {
                        self.ungc(c);
                        let strBuf: String = buf.into_iter().collect();
                        j = look(&strBuf, &TW);
                        if j != 0 {
                            return lex::Lex::new(lex::Kind::from_i32(j), j, strBuf);
                        }
                        j = tid.put(&strBuf) as i32;
                        return lex::Lex::new(lex::Kind::ID, j, strBuf);
                    }
                }
                State::NUMB => {
                    if c.is_ascii_digit() {
                        d = d * 10 + c.to_digit(10).unwrap() as i32;
                    } else {
                        self.ungc(c);
                        return lex::Lex::new(lex::Kind::NUM, d, d.to_string());
                    }
                }
                State::COM => {
                    if c == '}' {
                        CS = State::H;
                    } else if c == '@' || c == '{' {
                        eprintln!("unexepcted @ or {{");
                        std::process::exit(1);
                    }
                }
                State::ALE => {
                    if c == '=' {
                        buf.push(c);
                        let strBuf: String = buf.into_iter().collect();
                        j = look(&strBuf, &TD);
                        let kind = lex::Kind::from_i32(j + lex::Kind::FIN as i32);
                        return lex::Lex::new(kind, j, strBuf);
                    }
                    self.ungc(c);
                    let strBuf: String = buf.into_iter().collect();
                    j = look(&strBuf, &TD);
                    let kind = lex::Kind::from_i32(j + lex::Kind::FIN as i32);
                    return lex::Lex::new(kind, j, strBuf);
                }
                State::NEQ => {
                    if c == '=' {
                        buf.push(c);
                        let strBuf: String = buf.into_iter().collect();
                        j = look(&strBuf, &TD);
                        return lex::Lex::new(lex::Kind::NEQ, j, strBuf);
                    }
                    eprintln!("expected '=' but found {}", c);
                }
            }
        }
    }
}

static TW: [&str; 23] = [
    "", "and", "begin", "bool", "do", "else", "end", "if", "false", "int", "not", "or", "program",
    "read", "then", "true", "var", "while", "write", "writeln", "case", "of", "function",
];

static TD: [&str; 17] = [
    "@", ";", ",", ":", ":=", "(", ")", "=", "<", ">", "+", "-", "*", "/", "<=", "!=", ">=",
];
