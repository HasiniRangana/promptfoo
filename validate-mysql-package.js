#!/usr/bin/env node

// Package Validation Test for hasinirangana-promptfoo-mysql v0.118.22
// This script verifies that the MySQL integration package is properly installed

const fs = require('fs');
const path = require('path');

console.log('🔍 Validating promptfoo MySQL Integration Package v0.118.22...\n');

function checkFile(filePath, description) {
  try {
    if (fs.existsSync(filePath)) {
      console.log(`✅ ${description}`);
      return true;
    } else {
      console.log(`❌ ${description}`);
      return false;
    }
  } catch (error) {
    console.log(`❌ ${description} (Error: ${error.message})`);
    return false;
  }
}

function checkModule(moduleName, description) {
  try {
    require(moduleName);
    console.log(`✅ ${description}`);
    return true;
  } catch (error) {
    console.log(`❌ ${description} (Error: ${error.message})`);
    return false;
  }
}

let allChecks = true;

// Check core files
console.log('📁 Core Files:');
allChecks &= checkFile('./dist/src/database/index.js', 'Database index module');
allChecks &= checkFile('./dist/src/database/dynamic-tables.js', 'Dynamic tables module');
allChecks &= checkFile('./dist/src/models/eval.js', 'Eval model');

console.log('\n📁 MySQL Integration Files:');
allChecks &= checkFile('./dist/src/database/mysql-index.js', 'MySQL index module');
allChecks &= checkFile('./dist/src/database/mysql-tables.js', 'MySQL table definitions');
allChecks &= checkFile('./dist/src/database/mysql-migrate.js', 'MySQL migration module');

console.log('\n📁 Migration Files:');
allChecks &= checkFile('./drizzle-mysql/0000_sparkling_hulk.sql', 'MySQL migration SQL');
allChecks &= checkFile('./drizzle-mysql/meta/_journal.json', 'MySQL migration metadata');

console.log('\n🔧 Module Imports:');
try {
  const dbIndex = require('./dist/src/database/index.js');
  allChecks &= checkModule('./dist/src/database/index.js', 'Database index import');
  
  // Check for new functions
  if (typeof dbIndex.withTransaction === 'function') {
    console.log('✅ withTransaction function available');
  } else {
    console.log('❌ withTransaction function missing');
    allChecks = false;
  }
  
  if (typeof dbIndex.convertDateForDb === 'function') {
    console.log('✅ convertDateForDb function available');
  } else {
    console.log('❌ convertDateForDb function missing');
    allChecks = false;
  }
  
  if (typeof dbIndex.shouldUseMysql === 'function') {
    console.log('✅ shouldUseMysql function available');
  } else {
    console.log('❌ shouldUseMysql function missing');
    allChecks = false;
  }
  
} catch (error) {
  console.log(`❌ Database index module import failed: ${error.message}`);
  allChecks = false;
}

try {
  const dynamicTables = require('./dist/src/database/dynamic-tables.js');
  allChecks &= checkModule('./dist/src/database/dynamic-tables.js', 'Dynamic tables import');
  
  // Check table exports
  if (dynamicTables.evalsTable) {
    console.log('✅ Dynamic evalsTable export available');
  } else {
    console.log('❌ Dynamic evalsTable export missing');
    allChecks = false;
  }
  
} catch (error) {
  console.log(`❌ Dynamic tables module import failed: ${error.message}`);
  allChecks = false;
}

console.log('\n📋 Package Information:');
try {
  const packageInfo = require('./package.json');
  console.log(`✅ Package: ${packageInfo.name}`);
  console.log(`✅ Version: ${packageInfo.version}`);
  console.log(`✅ Description: ${packageInfo.description}`);
  
  if (packageInfo.version === '0.118.22') {
    console.log('✅ Correct version (0.118.22)');
  } else {
    console.log(`❌ Version mismatch. Expected 0.118.22, got ${packageInfo.version}`);
    allChecks = false;
  }
} catch (error) {
  console.log(`❌ Package.json read failed: ${error.message}`);
  allChecks = false;
}

console.log('\n🎯 Environment Test:');
const dbType = process.env.PROMPTFOO_DB_TYPE;
if (dbType === 'mysql') {
  console.log('✅ MySQL mode detected (PROMPTFOO_DB_TYPE=mysql)');
  console.log('🔧 Verify MySQL connection variables are set:');
  console.log(`   PROMPTFOO_DB_HOST: ${process.env.PROMPTFOO_DB_HOST || 'NOT SET'}`);
  console.log(`   PROMPTFOO_DB_USER: ${process.env.PROMPTFOO_DB_USER || 'NOT SET'}`);
  console.log(`   PROMPTFOO_DB_NAME: ${process.env.PROMPTFOO_DB_NAME || 'NOT SET'}`);
} else if (dbType === 'sqlite') {
  console.log('✅ SQLite mode detected (PROMPTFOO_DB_TYPE=sqlite)');
} else {
  console.log('✅ Default mode (SQLite) - no PROMPTFOO_DB_TYPE set');
}

console.log('\n' + '='.repeat(60));

if (allChecks) {
  console.log('🎉 VALIDATION SUCCESSFUL!');
  console.log('✅ All MySQL integration components are properly installed');
  console.log('✅ Package is ready for use');
  console.log('\n📚 Next steps:');
  console.log('   - For SQLite: Start using promptfoo normally');
  console.log('   - For MySQL: Set environment variables and run migrations');
  console.log('   - See RELEASE_NOTES_v0.118.22.md for detailed setup');
} else {
  console.log('❌ VALIDATION FAILED!');
  console.log('❌ Some components are missing or not properly installed');
  console.log('\n🔧 Troubleshooting:');
  console.log('   - Reinstall the package: npm install hasinirangana-promptfoo-mysql-0.118.42.tgz');
  console.log('   - Check file permissions');
  console.log('   - Verify Node.js version compatibility');
  process.exit(1);
}

console.log('\n🚀 Ready to evaluate with promptfoo MySQL integration!');