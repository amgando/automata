require "sqlite3"

# Open a database
db = SQLite3::Database.new "test.db"

# Create a database
rows = db.execute <<-SQL
  create table numbers (
    name varchar(30),
    val int
  );
SQL