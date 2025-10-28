# MySQL Migration Guide for Promptfoo

This guide walks you through migrating from SQLite to MySQL for the Promptfoo database.

## Prerequisites

1. **MySQL Server**: Ensure you have a MySQL server running (MySQL 5.7+ or MySQL 8.0+)
2. **Database Access**: Create a MySQL database and user with appropriate permissions
3. **Node.js Dependencies**: The `mysql2` package should already be installed

## Step 1: Set Up MySQL Database

### Create Database and User

```sql
-- Connect to MySQL as root or admin user
CREATE DATABASE promptfoo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create a user for promptfoo
CREATE USER 'promptfoo'@'localhost' IDENTIFIED BY 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON promptfoo.* TO 'promptfoo'@'localhost';
FLUSH PRIVILEGES;
```

### Configure Connection

Create a `.env` file in your project root with your MySQL connection details:

```bash
# Copy from .env.mysql.example and configure
cp .env.mysql.example .env
```

Edit the `.env` file:

```bash
# MySQL Database Configuration
PROMPTFOO_MYSQL_HOST=localhost
PROMPTFOO_MYSQL_PORT=3306
PROMPTFOO_MYSQL_USER=promptfoo
PROMPTFOO_MYSQL_PASSWORD=your_secure_password
PROMPTFOO_MYSQL_DATABASE=promptfoo
PROMPTFOO_MYSQL_SSL=false

# Enable MySQL usage
PROMPTFOO_USE_MYSQL=true

# Optional: Enable database query logging
PROMPTFOO_ENABLE_DATABASE_LOGS=false
```

## Step 2: Generate MySQL Schema

Generate the initial MySQL database schema:

```bash
npm run db:mysql:generate
```

This creates migration files in the `drizzle-mysql/` directory.

## Step 3: Apply MySQL Migrations

Run the migrations to create tables in MySQL:

```bash
npm run db:mysql:migrate
```

## Step 4: Migrate Existing Data (Optional)

If you have existing data in SQLite that you want to migrate to MySQL:

```bash
npm run migrate:to-mysql
```

This script will:
- Connect to your existing SQLite database
- Export all data from SQLite
- Import the data into MySQL
- Provide a migration summary

## Step 5: Switch to MySQL

Update your environment to use MySQL:

```bash
# In your .env file
PROMPTFOO_USE_MYSQL=true
```

## Step 6: Test the Migration

Verify that the application works with MySQL:

```bash
# Build the application
npm run build

# Test basic functionality
npm run test
```

## Verification Commands

### Check Database Connection
```bash
# Test MySQL connection
npm run db:mysql:studio
```

### View Database Schema
Access the Drizzle Studio interface to inspect your MySQL database:
```bash
npm run db:mysql:studio
```

This opens a web interface at `http://localhost:4983` where you can browse your MySQL database.

## Configuration Reference

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROMPTFOO_USE_MYSQL` | Enable MySQL instead of SQLite | `false` |
| `PROMPTFOO_MYSQL_HOST` | MySQL server hostname | `localhost` |
| `PROMPTFOO_MYSQL_PORT` | MySQL server port | `3306` |
| `PROMPTFOO_MYSQL_USER` | MySQL username | `promptfoo` |
| `PROMPTFOO_MYSQL_PASSWORD` | MySQL password | `promptfoo` |
| `PROMPTFOO_MYSQL_DATABASE` | MySQL database name | `promptfoo` |
| `PROMPTFOO_MYSQL_SSL` | Enable SSL connection | `false` |
| `PROMPTFOO_ENABLE_DATABASE_LOGS` | Enable query logging | `false` |

### NPM Scripts

| Script | Description |
|--------|-------------|
| `npm run db:mysql:generate` | Generate MySQL migrations |
| `npm run db:mysql:migrate` | Apply MySQL migrations |
| `npm run db:mysql:studio` | Open MySQL database studio |
| `npm run migrate:to-mysql` | Migrate data from SQLite to MySQL |

## Key Differences: SQLite vs MySQL

### Data Types
- SQLite `INTEGER` → MySQL `INT` or `BIGINT`
- SQLite `TEXT` → MySQL `VARCHAR` or `TEXT`
- SQLite `REAL` → MySQL `DECIMAL` or `FLOAT`
- SQLite `BLOB` → MySQL `BLOB` or `LONGBLOB`

### JSON Support
- Both support JSON columns
- MySQL uses `JSON_EXTRACT()` instead of SQLite's `json_extract()`
- Index syntax differs for JSON fields

### Timestamps
- MySQL has native `TIMESTAMP` and `DATETIME` types
- Automatic `ON UPDATE CURRENT_TIMESTAMP` support
- Better timezone handling

## Troubleshooting

### Connection Issues

1. **"Can't connect to MySQL server"**
   - Check if MySQL is running: `sudo systemctl status mysql`
   - Verify connection details in `.env`
   - Test connection: `mysql -h localhost -u promptfoo -p`

2. **"Access denied for user"**
   - Verify username/password
   - Check user privileges: `SHOW GRANTS FOR 'promptfoo'@'localhost';`

3. **"Unknown database"**
   - Create the database: `CREATE DATABASE promptfoo;`

### Migration Issues

1. **"Table doesn't exist"**
   - Run migrations: `npm run db:mysql:migrate`
   - Check migration files in `drizzle-mysql/`

2. **"Duplicate entry"**
   - The migration script uses `INSERT IGNORE` to handle duplicates
   - Check for data conflicts manually if needed

3. **"JSON syntax error"**
   - Some SQLite JSON may need formatting for MySQL
   - Check migration logs for specific issues

### Performance Optimization

1. **Connection Pooling**
   - The MySQL connection uses pooling automatically
   - Default pool size: 10 connections
   - Configure via `connectionLimit` in mysql-index.ts

2. **Indexes**
   - All SQLite indexes are converted to MySQL indexes
   - JSON indexes use MySQL-specific syntax
   - Monitor query performance with `EXPLAIN`

## Rollback Strategy

To rollback to SQLite:

1. Set `PROMPTFOO_USE_MYSQL=false` in your `.env`
2. Ensure your SQLite database file exists
3. Restart the application

The application will automatically switch back to SQLite.

## Security Considerations

1. **Use strong passwords** for MySQL users
2. **Enable SSL** for production environments
3. **Restrict network access** to MySQL server
4. **Regular backups** of MySQL database
5. **Keep MySQL updated** to latest stable version

## Next Steps

After successful migration:

1. **Monitor performance** - MySQL may perform differently than SQLite
2. **Set up backups** - Implement regular MySQL backups
3. **Optimize queries** - Review and optimize any slow queries
4. **Update documentation** - Document your MySQL setup for your team
5. **Consider replication** - Set up MySQL replication for high availability