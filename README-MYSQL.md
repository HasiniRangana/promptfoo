# Promptfoo with MySQL Integration

This is a fork of the original [Promptfoo](https://github.com/promptfoo/promptfoo) toolkit with added MySQL database support for storing evaluation results and test data.

## 🆕 **MySQL Integration Features**

- **Full MySQL Support**: Store evaluation results in MySQL instead of SQLite
- **Connection Pooling**: Efficient MySQL connection management
- **Migration Support**: Automatic database schema migration
- **Environment Configuration**: Easy MySQL setup via environment variables
- **Fallback Support**: Maintains SQLite compatibility for testing

## 📦 **Installation**

```bash
npm install @hasinirangana/promptfoo-mysql
```

Or globally:

```bash
npm install -g @hasinirangana/promptfoo-mysql
```

## ⚙️ **MySQL Configuration**

Set these environment variables to configure MySQL:

```bash
# MySQL Connection Settings
PROMPTFOO_MYSQL_HOST=localhost          # Default: localhost
PROMPTFOO_MYSQL_PORT=3306               # Default: 3306
PROMPTFOO_MYSQL_USER=root               # Default: root
PROMPTFOO_MYSQL_PASSWORD=your_password  # Default: root
PROMPTFOO_MYSQL_DATABASE=promptfoo      # Default: promptfoo

# Optional SSL Support
PROMPTFOO_MYSQL_SSL=true                # Enable SSL connections

# Logging (optional)
PROMPTFOO_ENABLE_DATABASE_LOGS=true     # Enable database query logging
```

## 🚀 **Quick Start with MySQL**

1. **Set up MySQL database**:
```sql
CREATE DATABASE promptfoo;
```

2. **Configure environment variables**:
```bash
export PROMPTFOO_MYSQL_HOST=localhost
export PROMPTFOO_MYSQL_USER=root
export PROMPTFOO_MYSQL_PASSWORD=yourpassword
export PROMPTFOO_MYSQL_DATABASE=promptfoo
```

3. **Run migrations** (creates tables automatically):
```bash
npx promptfoo-mysql db:mysql:migrate
```

4. **Use like regular Promptfoo**:
```bash
npx promptfoo-mysql eval
```

## 🗄️ **Database Operations**

### **Run MySQL Migrations**
```bash
# Generate new migrations
npm run db:mysql:generate

# Apply migrations
npm run db:mysql:migrate

# Open MySQL studio
npm run db:mysql:studio
```

### **Migrate from SQLite to MySQL**
```bash
# Migrate existing SQLite data to MySQL
npm run migrate:to-mysql
```

## 🔄 **Usage Examples**

### **Basic Usage**
All standard Promptfoo commands work with MySQL backend:

```bash
# Initialize a new test
npx promptfoo-mysql init

# Run evaluations (results stored in MySQL)
npx promptfoo-mysql eval

# View results
npx promptfoo-mysql view
```

### **Programmatic Usage**
```javascript
const { getDb } = require('@hasinirangana/promptfoo-mysql/dist/src/database/mysql-index');

async function main() {
  const db = await getDb();
  // Use Drizzle ORM with MySQL
  const results = await db.select().from(evaluationResults);
}
```

## 🔧 **Configuration**

### **Environment Variables**
Create a `.env` file:

```env
# MySQL Configuration
PROMPTFOO_MYSQL_HOST=your-mysql-host
PROMPTFOO_MYSQL_PORT=3306
PROMPTFOO_MYSQL_USER=your-username
PROMPTFOO_MYSQL_PASSWORD=your-password
PROMPTFOO_MYSQL_DATABASE=promptfoo

# Optional Settings
PROMPTFOO_MYSQL_SSL=false
PROMPTFOO_ENABLE_DATABASE_LOGS=false
```

### **Docker Compose Example**
```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: promptfoo
    ports:
      - "3306:3306"
      
  promptfoo:
    image: node:20
    environment:
      PROMPTFOO_MYSQL_HOST: mysql
      PROMPTFOO_MYSQL_USER: root
      PROMPTFOO_MYSQL_PASSWORD: rootpass
      PROMPTFOO_MYSQL_DATABASE: promptfoo
    depends_on:
      - mysql
```

## 🆚 **Differences from Original Promptfoo**

| Feature | Original Promptfoo | This Fork |
|---------|-------------------|-----------|
| Database | SQLite only | SQLite + MySQL |
| Storage | Local files | Local files + MySQL server |
| Scalability | Single machine | Multi-machine with shared MySQL |
| Data Sharing | File-based | Network-accessible database |
| Migrations | SQLite migrations | Dual migration system |

## 🤝 **Compatibility**

- **API Compatible**: All original Promptfoo APIs work unchanged
- **Config Compatible**: Existing promptfooconfig.yaml files work as-is
- **CLI Compatible**: All CLI commands have the same interface
- **Testing Fallback**: Uses SQLite in-memory for tests

## 📚 **Documentation**

For general Promptfoo usage, see the [original documentation](https://promptfoo.dev).

### **MySQL-Specific Docs**
- [MySQL Migration Guide](./MYSQL_MIGRATION.md)
- [Database Schema](./src/database/mysql-tables.ts)
- [Environment Configuration](./src/database/mysql-index.ts)

## 🐛 **Troubleshooting**

### **Connection Issues**
```bash
# Test MySQL connection
node -e "require('./dist/src/database/mysql-index').testMysqlConnection().then(console.log)"
```

### **Migration Issues**
```bash
# Check migration status
npx drizzle-kit studio --config=drizzle-mysql.config.ts
```

### **Fallback to SQLite**
Set `IS_TESTING=true` to use SQLite in-memory mode.

## 📄 **License**

MIT License - same as original Promptfoo

## 🙏 **Credits**

Based on [Promptfoo](https://github.com/promptfoo/promptfoo) by Ian Webster and contributors.

MySQL integration added by Hasini Rangana.