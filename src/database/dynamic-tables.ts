// Dynamic table exports based on database type
import { getEnvBool } from '../envars';

// Detect if MySQL should be used (duplicated to avoid circular dependency)
function shouldUseMysql(): boolean {
  // Check explicit database type flag first
  const dbType = process.env.PROMPTFOO_DB_TYPE;
  if (dbType === 'mysql') {
    return true;
  }
  if (dbType === 'sqlite') {
    return false;
  }
  
  // Check explicit flag
  if (getEnvBool('PROMPTFOO_USE_MYSQL', false)) {
    return true;
  }
  
  // Check if MySQL environment variables are set (old format)
  const mysqlHost = process.env.PROMPTFOO_MYSQL_HOST;
  const mysqlDatabase = process.env.PROMPTFOO_MYSQL_DATABASE;
  
  // Check if MySQL environment variables are set (new format)
  const dbHost = process.env.PROMPTFOO_DB_HOST;
  const dbName = process.env.PROMPTFOO_DB_NAME;
  
  // Use MySQL if host is explicitly set (and not testing)
  return !!((mysqlHost && mysqlDatabase) || (dbHost && dbName)) && !getEnvBool('IS_TESTING');
}

// Export the appropriate table definitions based on database type
let tables: any;

if (shouldUseMysql()) {
  // Use MySQL table definitions
  tables = require('./mysql-tables');
} else {
  // Use SQLite table definitions (default)
  tables = require('./tables');
}

// Re-export all tables
export const {
  promptsTable,
  evalsTable,
  evalResultsTable,
  evalsToPromptsTable,
  evalsToDatasetsTable,
  evalsToTagsTable,
  datasetsTable,
  tagsTable,
  modelAuditsTable,
  tracesTable,
  spansTable,
  configsTable,
} = tables;

// Export relations if they exist
export const {
  evalsTableRelations,
  promptsTableRelations,
  evalResultsTableRelations,
  datasetsTableRelations,
  tagsTableRelations,
  evalsToPromptsTableRelations,
  evalsToDatasetsTableRelations,
  evalsToTagsTableRelations,
  modelAuditsTableRelations,
  tracesTableRelations,
  spansTableRelations,
  configsTableRelations,
} = tables;