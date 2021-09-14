use crate::ident::Ident;
use crate::ident_func::IdentFunc;
use crate::lex::Kind;
use std::collections::HashMap;
use std::ops::{Index, IndexMut};

pub struct TIDType {
	cur: Vec<Ident>,
	func_table: HashMap<String, crate::ident_func::IdentFunc>,
	func_stack: Vec<String>,
}

impl Index<usize> for TIDType {
	type Output = crate::ident::Ident;

	fn index(&self, index: usize) -> &Self::Output {
		&self.cur[index]
	}
}

impl IndexMut<usize> for TIDType {
	fn index_mut(&mut self, index: usize) -> &mut Self::Output {
		&mut self.cur[index]
	}
}

impl TIDType {
	pub fn new() -> TIDType {
		TIDType {
			cur: Vec::new(),
			func_table: HashMap::new(),
			func_stack: vec![String::from("global")],
		}
	}
	pub fn pop_back(&mut self) -> crate::ident::Ident {
		self.cur.pop().unwrap()
	}
	pub fn top_func_name(&self) -> &str {
		&self.func_stack[self.func_stack.len() - 1]
	}

	pub fn cur_mt(&mut self) -> &mut Vec<Ident> {
		&mut self.cur
	}

	pub fn cur(&self) -> &Vec<Ident> {
		&self.cur
	}

	pub fn put(&mut self, buf: &str) -> usize {
		let top_func_name = String::from(self.top_func_name());
		let idents = self.cur_mt();
		let mut id = String::from(top_func_name);
		id.push_str(buf);

		if let Some(index) = idents.iter().position(|r| r.id() == id) {
			return index;
		}

		let mut ident = Ident::new(String::from(buf));
		ident.set_id(id);
		idents.push(ident);
		return idents.len() - 1;
	}

	pub fn declare_func(&mut self, ident: &mut Ident, address: i32) -> bool {
		let name = ident.name();
		if self.func_table.contains_key(name) {
			return true;
		}
		let clone = ident.clone();
		let ident_func = IdentFunc::from_ident(&clone);
		ident.put_value(address);
		ident.put_kind(Kind::FUNCTION);
		let name = ident.name();
		self.func_table.insert(String::from(name), ident_func);
		return false;
	}

	pub fn push_func(&mut self, name: &str) {
		self.func_stack.push(String::from(name));
	}

	pub fn top_func(&mut self) -> &mut IdentFunc {
		let func: &str = &self.func_stack[self.func_stack.len() - 1];
		self.func_table.get_mut(func).unwrap()
	}

	pub fn len(&self) -> usize {
		self.cur().len()
	}

	pub fn pop_func(&mut self) {
		self.func_stack.pop();
	}

	pub fn find_func(&self, name: &str) -> std::option::Option<&IdentFunc> {
		self.func_table.get(name)
	}
}
