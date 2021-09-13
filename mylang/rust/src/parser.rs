use crate::lex::{Kind, Lex};
use std::io;

pub struct Parser {
    tid: crate::tid::TIDType,
    scan: crate::scanner::Scanner,
    curr_lex: Lex,
    c_type: Kind,
    c_val: i32,
    c_str_val: String,
    st_int: Vec<i32>,
    st_lex: Vec<Kind>,
    poliz: Vec<Lex>,
}

impl Parser {
    pub fn new<'a>(filename: &str, tid: crate::tid::TIDType) -> io::Result<Parser> {
        let scan = crate::scanner::Scanner::new(filename)?;
        let parser = Parser {
            tid,
            scan,
            curr_lex: Lex::default(),
            c_type: Kind::default(),
            c_val: 0,
            c_str_val: String::new(),
            st_int: Vec::new(),
            st_lex: Vec::new(),
            poliz: Vec::new(),
        };
        Ok(parser)
    }
    pub fn analyze(mut self) -> (Vec<crate::lex::Lex>, crate::tid::TIDType) {
        self.next_lex();
        self.program();
        if self.c_type != Kind::FIN {
            eprintln!("expected @ but found {}", self.c_str_val);
            std::process::exit(1);
        }
        (self.poliz, self.tid)
    }
    fn program(&mut self) {
        if self.c_type != Kind::PROGRAM {
            eprintln!("expected program but found {}", self.c_str_val);
            std::process::exit(1);
        }
        let indexMainLabel = self.poliz.len();
        self.poliz.push(Lex::default());
        self.poliz
            .push(Lex::new(Kind::POLIZ_GO, 0, String::from("go to main")));

        self.next_lex();

        while self.c_type == Kind::FUNCTION {
            self.func_extract();
            if self.c_type != Kind::SEMICOLON {
                eprintln!("expected ; but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
        }
        // тут объявления переменных
        /*
        program
        var <имя>: int|bool[, <имя>: int|bool];
        */
        self.poliz[indexMainLabel] = Lex::new(
            Kind::POLIZ_LABEL,
            self.poliz.len() as i32,
            String::from("main label"),
        );

        if self.c_type == Kind::VAR {
            self.var_declaration();
            if self.c_type != Kind::SEMICOLON {
                eprintln!("expected ; but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
        }
        // логика программы
        self.b();
    }
    // FuncExtract = W
    // W -> function (var D, {D}): [int | bool] B
    fn func_extract(&mut self) {
        self.next_lex();
        if self.c_type != Kind::ID {
            eprintln!("expected identificator but found {}", self.c_str_val);
            std::process::exit(1);
        }

        let ident_func = self.tid.pop_back();
        if self.tid.declare_func(&ident_func, self.poliz.len() as i32) {
            eprintln!("function already exists");
            std::process::exit(1);
        }

        self.tid.push_func(ident_func.name());
        let func = self.tid.top_func();

        self.next_lex();
        if self.c_type != Kind::LPAREN {
            eprintln!("expected {{ but found {}", self.c_str_val);
            std::process::exit(1);
        }

        // параметры функции
        self.next_lex();
        let mut varsCount: usize = 0;
        if self.c_type != Kind::RPAREN {
            varsCount = self.var_declaration();
            if self.c_type != Kind::RPAREN {
                eprintln!("expected {{ but found {}", self.c_str_val);
                std::process::exit(1);
            }
        }

        let mut i = self.tid.len() - 1;
        loop {
            if i < self.tid.len() - varsCount {
                break;
            }
            func.push_arg(self.tid[i]);
            self.poliz.push(Lex::new(
                Kind::POLIZ_ADDRESS,
                i as i32,
                String::from("addr func arg"),
            ));
            self.poliz.push(Lex::new(
                Kind::POLIZ_INIT_FUNC_ARG,
                0,
                String::from("init func arg"),
            ));
            i -= 1;
        }

        self.next_lex();
        if self.c_type != Kind::COLON {
            eprintln!("expected : but found {}", self.c_str_val);
            std::process::exit(1);
        }

        self.next_lex();
        if self.c_type != Kind::BOOL && self.c_type != Kind::INT {
            eprintln!("expected bool or int but found {}", self.c_str_val);
            std::process::exit(1);
        }

        func.set_return_lex(self.curr_lex);
        self.func_declare_ret_var(func);

        self.next_lex();
        if self.c_type == Kind::VAR {
            self.var_declaration();
            if self.c_type != Kind::SEMICOLON {
                eprintln!("expected ; but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
        }

        self.b();
        self.poliz.push(Lex::new(
            Kind::POLIZ_RETURN_FUNC,
            0,
            String::from("return from function"),
        ));
        self.tid.pop_func();
    }
    fn next_lex(&mut self) {
        self.curr_lex = self.scan.get_lex(&mut self.tid);
        self.c_type = self.curr_lex.kind();
        self.c_val = self.curr_lex.value();
        self.c_str_val = self.curr_lex.value_str();
    }
    fn var_declaration(&mut self) -> usize {
        let mut count_vars: usize = 0;
        if self.c_type != Kind::VAR {
            eprintln!("expected var but found {}", self.c_str_val);
            std::process::exit(1);
        }

        self.next_lex();
        count_vars += self.var_extract();
        while self.c_type == Kind::COMMA {
            self.next_lex();
            count_vars += self.var_extract();
        }
        count_vars
    }
    fn var_extract(&self) -> usize {
        let mut count_vars: usize = 0;
        if self.c_type != Kind::ID {
            eprintln!("expected identificator but found {}", self.c_str_val);
            std::process::exit(1);
        }

        self.st_int.push(self.c_val);
        self.next_lex();
        while self.c_type == Kind::COMMA {
            count_vars += 1;
            self.next_lex();
            if self.c_type != Kind::ID {
                eprintln!("expected identificator but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.st_int.push(self.c_val);
            self.next_lex();
        }

        if self.c_type != Kind::COLON {
            eprintln!("expected : but found {}", self.c_str_val);
            std::process::exit(1);
        }

        self.next_lex();
        if self.c_type == Kind::BOOL {
            self.dec(Kind::INT);
            self.next_lex();
        } else if self.c_type == Kind::BOOL {
            self.dec(Kind::BOOL);
            self.next_lex();
        } else {
            eprintln!("expected bool or int but found {}", self.c_str_val);
            std::process::exit(1);
        }

        return count_vars;
    }
    fn dec(&mut self, kind: Kind) {
        let mut i: usize;
        while self.st_int.len() != 0 {
            i = self.st_int.pop().unwrap() as usize;
            if self.tid[i].declare() {
                eprintln!("declated twice {}", self.tid[i].name());
                std::process::exit(1);
            }
            self.tid[i].put_declare();
            self.tid[i].put_kind(kind);
        }
    }
    fn func_declare_ret_var(&mut self, func: &mut crate::ident_func::IdentFunc) {
        let index = self.tid.put(func.name());
        self.tid[index].set_ret();
        self.st_int.push(index as i32);
        self.dec(func.get_return_lex().kind());
        func.set_return_var(index as i32);
        self.poliz.push(Lex::new(
            Kind::POLIZ_ADDRESS,
            index as i32,
            String::from(""),
        ));
    }
    fn b(&mut self) {}
}
