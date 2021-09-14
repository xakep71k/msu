use crate::lex::{Kind, Lex};
use std::collections::HashSet;
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
    deep_S: i32,
}

impl Parser {
    pub fn new(filename: &str, tid: crate::tid::TIDType) -> io::Result<Parser> {
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
            deep_S: 0,
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
        let index_main_label = self.poliz.len();
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
        self.poliz[index_main_label] = Lex::new(
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

        let mut ident_func = self.tid.pop_back();
        if self
            .tid
            .declare_func(&mut ident_func, self.poliz.len() as i32)
        {
            eprintln!("function already exists");
            std::process::exit(1);
        }

        self.tid.push_func(ident_func.name());

        self.next_lex();
        if self.c_type != Kind::LPAREN {
            eprintln!("expected {{ but found {}", self.c_str_val);
            std::process::exit(1);
        }

        // параметры функции
        self.next_lex();
        let mut vars_count: usize = 0;
        if self.c_type != Kind::RPAREN {
            vars_count = self.var_declaration();
            if self.c_type != Kind::RPAREN {
                eprintln!("expected {{ but found {}", self.c_str_val);
                std::process::exit(1);
            }
        }

        let mut i = self.tid.len() - 1;
        loop {
            if i < self.tid.len() - vars_count {
                break;
            }
            let ident = self.tid[i].clone();
            self.tid.top_func().push_arg(ident);
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

        self.tid.top_func().set_return_lex(self.curr_lex.clone());
        self.declare_ret_var_for_top_func();

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
    fn var_extract(&mut self) -> usize {
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

    fn declare_ret_var_for_top_func(&mut self) {
        let top_func = self.tid.top_func();
        let name = String::from(top_func.name());
        let kind = top_func.get_return_lex().kind();
        let index = self.tid.put(&name);
        self.tid[index].set_ret();
        self.st_int.push(index as i32);
        self.dec(kind);
        let top_func = self.tid.top_func();
        top_func.set_return_var(index as i32);
        self.poliz.push(Lex::new(
            Kind::POLIZ_ADDRESS,
            index as i32,
            String::from(""),
        ));
    }
    fn b(&mut self) {
        if self.c_type == Kind::BEGIN {
            self.next_lex();
            self.deep_S = 0;
            self.s();
            while self.c_type == Kind::SEMICOLON {
                self.deep_S = 0;
                self.next_lex();
                self.s();
            }
            if self.c_type == Kind::END {
                self.next_lex();
            } else {
                eprintln!("expected end found {}", self.c_str_val);
                std::process::exit(1);
            }
        } else {
            eprintln!("expected begin found {}", self.c_str_val);
            std::process::exit(1);
        }
    }

    fn s(&mut self) {
        let pl0;
        let pl1;
        let pl2;
        let pl3;

        if self.c_type == Kind::IF {
            self.next_lex();
            self.e();
            self.eq_bool();
            pl2 = self.poliz.len();
            self.poliz.push(Lex::default());
            self.poliz
                .push(Lex::new(Kind::POLIZ_FGO, 0, String::from("POLIZ_FGO")));
            if self.c_type != Kind::THEN {
                eprintln!("expected then found {}", self.c_str_val);
                std::process::exit(1);
            }

            self.next_lex();
            self.s();

            pl3 = self.poliz.len();
            self.poliz.push(Lex::default());
            self.poliz
                .push(Lex::new(Kind::POLIZ_FGO, 0, String::from("POLIZ_FGO")));

            self.poliz[pl2] = Lex::new(
                Kind::POLIZ_LABEL,
                self.poliz.len() as i32,
                String::from("POLIZ_LABEL"),
            );
            if self.c_type == Kind::ELSE {
                self.next_lex();
                self.s();
            }

            self.poliz[pl3] = Lex::new(
                Kind::POLIZ_LABEL,
                self.poliz.len() as i32,
                String::from("POLIZ_LABEL"),
            );
        } else if self.c_type == Kind::CASE {
            self.case_of();
        } else if self.c_type == Kind::WHILE {
            pl0 = self.poliz.len();
            self.next_lex();
            self.e();
            self.eq_bool();
            pl1 = self.poliz.len();
            self.poliz.push(Lex::default());
            self.poliz
                .push(Lex::new(Kind::POLIZ_FGO, 0, String::from("POLIZ_FGO")));
            if self.c_type != Kind::DO {
                eprintln!("expected do found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
            self.s();
            self.poliz.push(Lex::new(
                Kind::POLIZ_LABEL,
                pl0 as i32,
                String::from("POLIZ_LABEL"),
            ));
            self.poliz
                .push(Lex::new(Kind::POLIZ_GO, 0, String::from("POLIZ_GO")));
            self.poliz[pl1] = Lex::new(
                Kind::POLIZ_LABEL,
                self.poliz.len() as i32,
                String::from("POLIZ_LABEL"),
            );
        } else if self.c_type == Kind::READ {
            self.next_lex();
            if self.c_type != Kind::LPAREN {
                eprintln!("expected {{ but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
            if self.c_type != Kind::ID {
                eprintln!("expected identificator but found {}", self.c_str_val);
                std::process::exit(1);
            }

            self.check_id_in_read();
            self.poliz.push(Lex::new(
                Kind::POLIZ_ADDRESS,
                self.c_val,
                String::from("POLIZ_ADDRESS"),
            ));
            self.next_lex();

            if self.c_type != Kind::LPAREN {
                eprintln!("expected }} but found {}", self.c_str_val);
                std::process::exit(1);
            }
        } else if self.c_type == Kind::WRITE || self.c_type == Kind::WRITELN {
            let lex_write = self.c_type;
            self.next_lex();
            if self.c_type != Kind::LPAREN {
                eprintln!("expected {{ but found {}", self.c_str_val);
                std::process::exit(1);
            }

            self.next_lex();
            self.e();
            if self.c_type != Kind::LPAREN {
                eprintln!("expected }} but found {}", self.c_str_val);
                std::process::exit(1);
            }

            self.next_lex();
            self.poliz
                .push(Lex::new(lex_write, 0, String::from("WRITE/WRITELN")));
        } else if self.c_type == Kind::ID {
            let old_c_val = self.c_val;
            let old_c_str_val = self.c_str_val.clone();
            self.next_lex();
            let func = self.tid.find_func(&old_c_str_val);
            if func.is_some()
                && func.unwrap().kind() == Kind::FUNCTION
                && self.c_type == Kind::LPAREN
            {
                self.call_func(&old_c_str_val);
            } else {
                self.check_id(old_c_val as usize);
                self.poliz.push(Lex::new(
                    Kind::POLIZ_ADDRESS,
                    old_c_val,
                    String::from("POLIZ_ADDRESS"),
                ));

                if self.c_type != Kind::ASSIGN {
                    eprintln!("expected = but found {}", self.c_str_val);
                    std::process::exit(1);
                }

                self.next_lex();
                self.e();
                self.eq_type();
                self.poliz
                    .push(Lex::new(Kind::ASSIGN, 0, String::from("ASSIGN")));
            }
        } else {
            self.b();
        }
    }

    fn e(&mut self) {
        self.deep_S += 1;
        self.e1();
        match self.c_type {
            Kind::EQ | Kind::LSS | Kind::GTR | Kind::LEQ | Kind::GEQ | Kind::NEQ => {
                self.st_lex.push(self.c_type);
                self.next_lex();
                self.e1();
                self.check_op();
            }
            _ => {}
        }
    }

    fn e1(&mut self) {
        self.t();
        let c_type = self.c_type;
        while c_type == Kind::PLUS || c_type == Kind::MINUS || c_type == Kind::OR {
            self.st_lex.push(c_type);
            self.next_lex();
            self.t();
            self.check_op();
        }
    }

    fn t(&mut self) {
        self.f();
        let c_type = self.c_type;
        while c_type == Kind::PLUS || c_type == Kind::MINUS || c_type == Kind::OR {
            self.st_lex.push(c_type);
            self.next_lex();
            self.f();
            self.check_op();
        }
    }

    fn f(&mut self) {
        if self.c_type == Kind::ID {
            if self.tid.find_func(&self.c_str_val).is_some() {
                let func_name = self.c_str_val.clone();
                self.next_lex();
                if self.c_type != Kind::LPAREN {
                    eprintln!("expected {{ but found {}", self.c_str_val);
                    std::process::exit(1);
                }
                self.call_func(&func_name);
                let return_lex_kind = self
                    .tid
                    .find_func(&self.c_str_val)
                    .unwrap()
                    .get_return_lex()
                    .kind();
                self.st_lex.push(return_lex_kind);
            } else {
                self.check_id(self.c_val as usize);
                self.poliz
                    .push(Lex::new(Kind::ID, self.c_val, String::from("LEX_ID F()")));
                self.next_lex();
            }
        } else if self.c_type == Kind::NUM {
            self.st_lex.push(Kind::INT);
            self.poliz.push(self.curr_lex.clone());
            self.next_lex();
        } else if self.c_type == Kind::TRUE {
            self.st_lex.push(Kind::BOOL);
            self.poliz
                .push(Lex::new(self.c_type, 0, String::from("true")));
            self.next_lex();
        } else if self.c_type == Kind::FALSE {
            self.st_lex.push(Kind::BOOL);
            self.poliz
                .push(Lex::new(self.c_type, 0, String::from("false")));
            self.next_lex();
        } else if self.c_type == Kind::NOT {
            self.next_lex();
            self.f();
            self.check_not();
        } else if self.c_type == Kind::LPAREN {
            self.next_lex();
            self.e();
            if self.c_type == Kind::RPAREN {
                self.next_lex();
            } else {
                eprintln!("expected identificator, }} but found {}", self.c_str_val);
                std::process::exit(1);
            }
        } else {
            eprintln!(
                "expected identificator, number, true, false, not or {{ but found {}",
                self.c_str_val
            );
            std::process::exit(1);
        }
    }

    fn eq_bool(&mut self) {
        if self.c_type != Kind::BOOL {
            eprintln!("expression not boolean");
            std::process::exit(1);
        }
        self.st_lex.pop();
    }

    fn case_of(&mut self) {
        let mut pl1;
        let mut labels: Vec<usize> = Vec::new();
        let mut consts: HashSet<i32> = HashSet::new();

        // забираем выражение внутри скобок case(<выражение>)
        self.next_lex();
        self.e();
        if self.c_type != Kind::CASE {
            eprintln!("expected case but found {}", self.c_str_val);
            std::process::exit(1);
        }

        // все константы дожны быть одного типа с выражением case(<выражение>)
        let case_type = self.st_lex[self.st_lex.len() - 1];
        self.next_lex();
        loop {
            let mut const_lexes: Vec<Lex> = Vec::new();
            // забираем все константы, разделённые запятой, одной ветки до знака :
            loop {
                self.check_const_case_type(case_type);

                // проверяем была ли константа уже упомянута
                if consts.insert(self.c_val) {
                    eprintln!("case/of has duplicate branch");
                    std::process::exit(1);
                }

                const_lexes.push(Lex::new(
                    self.c_type,
                    self.get_case_val(),
                    self.c_str_val.clone(),
                ));
                self.next_lex();
                if self.c_type != Kind::COMMA {
                    break;
                }

                // забираем следующую константу
                self.next_lex();
            }
            // формируем условия для выполенния ветки: добавляем сравнение с каждой константой
            for clex in const_lexes.iter() {
                self.poliz
                    .push(Lex::new(Kind::POLIZ_DUP, 0, String::from("dup")));
                self.poliz.push(clex.clone());
                self.poliz
                    .push(Lex::new(Kind::NEQ, 0, String::from("case NEQ")));
                labels.push(self.poliz.len());
                self.poliz.push(Lex::default()); // адрес тела ветки
                self.poliz
                    .push(Lex::new(Kind::POLIZ_FGO, 0, String::from("FGO")));
            }

            if const_lexes.len() == 0 {
                eprintln!("no constants specified");
                std::process::exit(1);
            }

            // ни одно из условий не выполнено, идём к следующей ветки
            pl1 = self.poliz.len();
            self.poliz.push(Lex::default());
            self.poliz
                .push(Lex::new(Kind::POLIZ_GO, 0, String::from("GO")));

            // заполняем пропущенные адреса на тело ветки case of
            let mut i = 0;
            loop {
                if i >= const_lexes.len() {
                    break;
                }
                let ilabel = labels.pop().unwrap();
                self.poliz[ilabel] = Lex::new(
                    Kind::POLIZ_LABEL,
                    self.poliz.len() as i32,
                    String::from("POLIZ_LABEL to case branch"),
                );
                i += 1;
            }

            // пропускаем символ :
            if self.c_type != Kind::COLON {
                eprintln!("expected : but found {}", self.c_str_val);
                std::process::exit(1);
            }

            // тело ветки case/of
            self.poliz.push(Lex::new(
                Kind::POLIZ_DEL_ARG,
                0,
                String::from("pop value of dup"),
            ));
            self.next_lex();
            self.s();

            // сюда запишется адрес выхода из ветки
            labels.push(self.poliz.len());
            self.poliz
                .push(Lex::new(Kind::POLIZ_LABEL, 0, String::from("BREAK CASE")));
            self.poliz
                .push(Lex::new(Kind::POLIZ_GO, 0, String::from("GO")));
            self.poliz[pl1] = Lex::new(
                Kind::POLIZ_LABEL,
                self.poliz.len() as i32,
                String::from("NEXT BRANCH"),
            );

            if self.c_type == Kind::END {
                break;
            }
        }

        if consts.len() == 0 {
            eprintln!("case/of must have at least one const");
            std::process::exit(1);
        }

        // помечаем последнюю метку, если мы на неё попали, значит ни одна ветка не сработала
        self.poliz.push(Lex::new(
            Kind::POLIZ_FAIL,
            0,
            String::from("branch of case not found"),
        ));

        // заполняем LABEL'ы верными адресами для выхода из тела веток case'а
        while labels.len() != 0 {
            let ilabel = labels.pop().unwrap();
            self.poliz[ilabel] = Lex::new(
                Kind::POLIZ_LABEL,
                self.poliz.len() as i32,
                String::from("BREAK CASE"),
            )
        }

        self.next_lex();
    }

    fn check_id_in_read(&mut self) {
        if !self.tid[self.c_val as usize].declare() {
            let item = &self.tid[self.c_val as usize];
            let name = item.name();
            let id = item.id();
            eprintln!("check_id_in_read: not declared {} {}", name, id);
            std::process::exit(1);
        }
    }

    fn call_func(&mut self, func_name: &str) {
        if self.deep_S == 1 {
            eprintln!("return value of function '{}' not used", func_name);
            std::process::exit(1);
        }

        let func = self.tid.find_func(func_name);
        if func.is_none() {
            eprintln!("unction not declared: '{}'", func_name);
            std::process::exit(1);
        }
        let func = func.unwrap();
        let func_args = func.clone_args();
        let func_name = String::from(func.name());
        let func_value = func.value();
        self.next_lex();
        let mut rparent_found = false;
        let mut end = false;
        let return_index_label = self.poliz.len();
        self.poliz.push(Lex::default());
        if func_args.len() != 0 {
            let mut i = func_args.len() - 1;
            while !rparent_found {
                let t: Kind;
                self.e();
                t = self.st_lex.pop().unwrap();
                if func_args[i].kind() != t {
                    eprintln!("wrong type of arg");
                    std::process::exit(1);
                }
                rparent_found = self.c_type == Kind::RPAREN;
                self.next_lex();
                if i == 0 {
                    end = true;
                    break;
                }
                i -= 1;
            }
            if !end || !rparent_found {
                eprintln!("wrong number of args in function {}", func_name);
                std::process::exit(1);
            }
        } else {
            if self.c_type != Kind::RPAREN {
                eprintln!("exepcted }} but found {}", self.c_str_val);
                std::process::exit(1);
            }
            self.next_lex();
        }

        self.poliz
            .push(Lex::new(Kind::POLIZ_CALL_FUNC, func_value, func_name));
        self.poliz[return_index_label] = Lex::new(
            Kind::POLIZ_LABEL,
            self.poliz.len() as i32,
            String::from("return label"),
        );
    }

    fn check_id(&mut self, addr: usize) {
        if self.tid[addr].declare() {
            self.st_lex.push(self.tid[addr].kind());
        } else {
            let name = self.tid[addr].name();
            let id = self.tid[addr].id();
            eprintln!("check_id: not declared {} {}", name, id);
            std::process::exit(1);
        }
    }

    fn eq_type(&mut self) {
        let t = self.st_lex.pop().unwrap();
        let top = self.st_lex[self.st_lex.len() - 1];
        if t != top {
            eprintln!("wrong types are in :=");
            std::process::exit(1);
        }
    }

    fn check_op(&mut self) {
        let t2 = self.st_lex.pop().unwrap();
        let op = self.st_lex.pop().unwrap();
        let t1 = self.st_lex.pop().unwrap();
        let mut t = Kind::INT;
        let mut r = Kind::BOOL;

        if op == Kind::PLUS || op == Kind::MINUS || op == Kind::TIMES || op == Kind::SLASH {
            r = Kind::INT;
        }
        if op == Kind::OR || op == Kind::AND {
            t = Kind::BOOL;
        }
        if t1 == t2 && t1 == t {
            self.st_lex.push(r);
        } else {
            eprintln!("wrong types are in operation");
            std::process::exit(1);
        }
        self.poliz.push(Lex::new(op, 0, String::from("op")));
    }

    fn check_not(&mut self) {
        let top = self.st_lex[self.st_lex.len() - 1];
        if top != Kind::BOOL {
            eprintln!("wrong type is in not");
            std::process::exit(1);
        }
    }

    fn check_const_case_type(&self, case_type: Kind) {
        if case_type == Kind::BOOL {
            match self.c_type {
                Kind::FALSE => {}
                Kind::TRUE => {}
                _ => {
                    eprintln!(
                        "wrong const type of case: must be true/false: {}",
                        self.c_type as i32
                    );
                    std::process::exit(1);
                }
            }
        } else if case_type == Kind::INT {
            match self.c_type {
                Kind::INT => {}
                _ => {
                    eprintln!(
                        "wrong const type of case: must be num: {}",
                        self.c_type as i32
                    );
                    std::process::exit(1);
                }
            }
        } else {
            eprintln!("wrong case type");
            std::process::exit(1);
        }
    }

    fn get_case_val(&self) -> i32 {
        match self.c_type {
            Kind::FALSE => return 1,
            Kind::TRUE => return 0,
            _ => return self.c_val,
        }
    }
}
