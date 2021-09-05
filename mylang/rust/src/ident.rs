#[derive(Default)]
pub struct Ident {
    name: String,
    declare: bool,
    kind: crate::lex::Kind,
    assign: bool,
    id: String,
    ret: bool,
    value: i32,
}

impl Ident {
    pub fn new(name: String) -> Ident {
        let mut ident = Ident::default();
        ident.name = name;
        return ident;
    }

    pub fn set_id(&mut self, id: String) {
        self.id = id
    }

    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn declare(&self) -> bool {
        self.declare
    }

    pub fn put_declare(&mut self) {
        self.declare = true
    }

    pub fn assign(&self) -> bool {
        self.assign
    }

    pub fn value(&self) -> i32 {
        self.value
    }

    pub fn kind(&self) -> crate::lex::Kind {
        self.kind
    }

    pub fn put_value(&mut self, v: i32) {
        self.value = v
    }

    pub fn put_kind(&mut self, k: crate::lex::Kind) {
        self.kind = k
    }

    pub fn ret(&self) -> bool {
        self.ret
    }

    pub fn set_ret(&mut self) {
        self.ret = true
    }
}
