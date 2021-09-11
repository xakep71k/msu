use crate::ident::Ident;
use std::collections::HashMap;
use std::ops::{Index, IndexMut};

pub struct TIDType {
	cur: Vec<Ident>,
	func_table: HashMap<String, crate::ident_func::IdentFunc>,
	func_stack: Vec<String>,
}

impl Index<i32> for TIDType {
	type Output = crate::ident::Ident;

	fn index(&self, index: i32) -> &Self::Output {
		&self.cur[index as usize]
	}
}

impl IndexMut<i32> for TIDType {
	fn index_mut(&mut self, index: i32) -> &mut Self::Output {
		&mut self.cur[index as usize]
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

	pub fn top_func_name(&self) -> &str {
		&self.func_stack[self.func_stack.len() - 1]
	}

	pub fn cur(&mut self) -> &mut Vec<Ident> {
		&mut self.cur
	}

	pub fn put(&mut self, buf: &String) -> i32 {
		let top_func_name = String::from(self.top_func_name());
		let idents = self.cur();
		let mut id = String::from(top_func_name);
		id.push_str(buf);

		if let Some(index) = idents.iter().position(|r| r.id() == id) {
			return index as i32;
		}

		let mut ident = Ident::new(String::from(buf));
		ident.set_id(id);
		idents.push(ident);
		return (idents.len() - 1) as i32;
	}
}
