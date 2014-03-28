module dvorm.unittests;
import dvorm;
import std.stdio;

version(unittest) {
	void unittest1(DbConnection[] cons...) {
		assert(cons.length >= 1);
		Book = cons;
		
		assert(getDbType!Book() == cons[0].type);
		
		Book book = newValueOfType!Book;
		book.isbn = "978-0-300-14424-6";
		book.edition = 5;
		book.save();
		
		Book book2 = newValueOfType!Book;
		book2.isbn = "978-0-300-14424-7";
		book2.edition = 15;
		book2.save();
		
		assert(Book.find(book.isbn).length == 1);
		assert(Book.find(book.isbn)[0].isbn == book.isbn);
		
		assert(Book.findOne(book.isbn) !is null);
		assert(Book.findOne(book.isbn).isbn == book.isbn);
		
		assert(Book.findAll().length == 2);
		
		bool hasFirst = false;
		bool hasSecond = false;
		foreach(b; Book.findAll()) {
			if (b.isbn == book.isbn) hasFirst = true;
			if (b.isbn == book2.isbn) hasSecond = true;
		}
		assert(hasFirst && hasSecond);
		
		writeln(Book.query().isbn_eq(book.isbn).maxAmount(1).find());
		
		assert(Book.query().isbn_eq(book.isbn).maxAmount(1).find().length == 1);
		assert(Book.query().isbn_eq(book.isbn).maxAmount(1).find()[0].isbn == book.isbn);
		
		assert(Book.query().isbn_neq(book.isbn).startAt(1).maxAmount(1).find().length == 0);
		assert(Book.query().isbn_neq(book.isbn).maxAmount(1).find()[0].isbn == book2.isbn);
		assert(Book.query().isbn_neq(book.isbn).count() == 1);
		
		assert(Book.query().isbn_like(book.isbn[$-7 .. $]).find().length == 1);
		assert(Book.query().isbn_like(book.isbn[$-7 .. $]).find()[0].isbn == book.isbn);
		
		assert(Book.query().edition_lt(10).find().length == 1);
		assert(Book.query().edition_mt(10).find().length == 1);
		assert(Book.query().edition_lt(10).find()[0].isbn == book.isbn);
		assert(Book.query().edition_mt(10).find()[0].isbn == book2.isbn);
		
		book.remove();
		assert(Book.findAll().length == 1);
		book2.remove();
		assert(Book.findAll().length == 0);
	}
	
	unittest {
		Book.logMe();
		Page.logMe();
		Book2.logMe();
		Page2.logMe();
		
		assert(getTableName!Book() == "Books");
		assert(getNameValue!(Book, "isbn") == "_id");
		assert(getDefaultValue!(Book, "edition") == "0");
		assert(shouldBeIgnored!(Book, "something"));
	}
	
	@dbName("Books")
	class Book {
		@dbId
		@dbName("_id")
		string isbn;
		
		@dbDefaultValue("0")
		ubyte edition;
		
		void t() {}
		
		@dbIgnore
		string something;
		
		mixin OrmModel!Book;
	}
	
	class Page {
		@dbId
		@dbName("_id")
		string id;
		
		@dbName("book_id")
		@dbActualModel!(Book, "isbn")
		string isbn;
		
		mixin OrmModel!Page;
	}
	
	@dbName("Books2")
	class Book2 {
		@dbId
		@dbName("_")
		Book2Id key;
		
		@dbDefaultValue("0")
		ubyte edition;
		
		void t() {}
		
		@dbIgnore
		string something;
		
		mixin OrmModel!Book2;
	}
	
	struct Book2Id {
		@dbId {
			@dbName("id")
			string isbn;
		}
	}
	
	class Page2 {
		@dbId
		@dbName("_id")
		string id;
		
		@dbName("book")
		@dbActualModel!(Book2, "key")
		Book2Id book;
		
		mixin OrmModel!Page2;
	}
}