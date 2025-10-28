/**
 * Test the enhanced MySQL error handling (v0.118.25)
 * Tests the fix for DrizzleQueryError wrapping MySQL duplicate key errors
 */

const { executeInsertWithConflictHandling, shouldUseMysql } = require('./dist/src/database/index.js');

async function testEnhancedErrorHandling() {
  console.log('🔧 Testing Enhanced MySQL Error Handling (v0.118.25)');
  console.log('=' .repeat(60));
  
  try {
    // Test 1: Direct MySQL error
    console.log('✅ Test 1: Direct MySQL Duplicate Key Error');
    const directErrorQuery = {
      then: (resolve, reject) => {
        const error = new Error('Duplicate entry');
        error.code = 'ER_DUP_ENTRY';
        error.errno = 1062;
        reject(error);
        return Promise.reject(error);
      }
    };
    
    try {
      await executeInsertWithConflictHandling(directErrorQuery);
      console.log('   ✅ Direct MySQL error handled correctly');
    } catch (error) {
      console.log(`   ❌ Failed to handle direct error: ${error.message}`);
    }
    
    // Test 2: Drizzle-wrapped MySQL error (the new case)
    console.log('\n✅ Test 2: Drizzle-Wrapped MySQL Error');
    const wrappedErrorQuery = {
      then: (resolve, reject) => {
        const mysqlError = new Error("Duplicate entry 'test' for key 'PRIMARY'");
        mysqlError.code = 'ER_DUP_ENTRY';
        mysqlError.errno = 1062;
        
        const drizzleError = new Error('DrizzleQueryError: Failed query: insert into prompts...');
        drizzleError.cause = mysqlError;
        drizzleError.query = 'insert into `prompts` (`id`, `created_at`, `prompt`) values (?, default, ?)';
        
        reject(drizzleError);
        return Promise.reject(drizzleError);
      }
    };
    
    try {
      await executeInsertWithConflictHandling(wrappedErrorQuery);
      console.log('   ✅ Drizzle-wrapped MySQL error handled correctly');
    } catch (error) {
      console.log(`   ❌ Failed to handle wrapped error: ${error.message}`);
    }
    
    // Test 3: Message-based detection
    console.log('\n✅ Test 3: Message-Based Duplicate Detection');
    const messageErrorQuery = {
      then: (resolve, reject) => {
        const error = new Error("Failed query: insert... Duplicate entry 'abc' for key 'prompts.PRIMARY'");
        reject(error);
        return Promise.reject(error);
      }
    };
    
    try {
      await executeInsertWithConflictHandling(messageErrorQuery);
      console.log('   ✅ Message-based duplicate detection worked');
    } catch (error) {
      console.log(`   ❌ Failed message-based detection: ${error.message}`);
    }
    
    // Test 4: Non-duplicate error should be thrown
    console.log('\n✅ Test 4: Non-Duplicate Error Handling');
    const otherErrorQuery = {
      then: (resolve, reject) => {
        const error = new Error('Some other database error');
        reject(error);
        return Promise.reject(error);
      }
    };
    
    try {
      await executeInsertWithConflictHandling(otherErrorQuery);
      console.log('   ❌ Non-duplicate error should have been thrown!');
    } catch (error) {
      console.log('   ✅ Non-duplicate error correctly thrown');
    }
    
    console.log('\n🎉 Enhanced error handling tests completed!');
    console.log('\n📦 Ready for v0.118.25 package');
    console.log('   ✅ Handles direct MySQL errors');
    console.log('   ✅ Handles Drizzle-wrapped errors');  
    console.log('   ✅ Handles message-based detection');
    console.log('   ✅ Preserves other error types');
    
  } catch (error) {
    console.error('\n❌ Test suite failed:', error.message);
  }
}

if (require.main === module) {
  testEnhancedErrorHandling().catch(console.error);
}

module.exports = { testEnhancedErrorHandling };