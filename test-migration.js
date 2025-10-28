#!/usr/bin/env node

/**
 * Quick test to verify MySQL migration works after reset
 */

console.log('🧪 Testing MySQL migration after reset...\n');

// Set environment variables for testing
process.env.PROMPTFOO_MYSQL_HOST = 'localhost';
process.env.PROMPTFOO_MYSQL_USER = 'root';
process.env.PROMPTFOO_MYSQL_PASSWORD = 'password';
process.env.PROMPTFOO_MYSQL_DATABASE = 'promptfoo';
process.env.PROMPTFOO_USE_MYSQL = 'true';

async function testMigration() {
  try {
    console.log('📋 Testing migration system...');
    
    // Import the migration function
    const { runMysqlDbMigrations } = require('./dist/src/database/mysql-migrate');
    
    // Try to run migration
    await runMysqlDbMigrations();
    
    console.log('✅ Migration test completed successfully!');
    console.log('🎉 Database is ready for use.');
    
  } catch (error) {
    console.error('❌ Migration test failed:', error.message);
    
    if (error.message.includes('already exists')) {
      console.log('\n💡 This suggests the reset utility needs to be run again.');
      console.log('   Run: node reset-mysql-migrations.js');
    }
  }
}

testMigration().catch(console.error);