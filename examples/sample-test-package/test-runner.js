#!/usr/bin/env node

/**
 * Test runner for the sample Promptfoo test package
 * This script helps set up and run tests with different configurations
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

class TestRunner {
  constructor() {
    this.packageRoot = __dirname;
    this.configs = {
      basic: 'promptfooconfig.yaml',
      advanced: 'advanced-config.yaml'
    };
  }

  async checkPrerequisites() {
    console.log('🔍 Checking prerequisites...');
    
    // Check if OpenAI API key is set
    if (!process.env.OPENAI_API_KEY) {
      console.log('❌ OPENAI_API_KEY environment variable not set');
      console.log('💡 Please set your OpenAI API key:');
      console.log('   export OPENAI_API_KEY="your-key-here"');
      console.log('   # On Windows: set OPENAI_API_KEY=your-key-here');
      return false;
    }

    // Check if promptfoo is available
    try {
      await this.runCommand('npx', ['promptfoo', '--version'], { silent: true });
      console.log('✅ Promptfoo is available');
    } catch (error) {
      console.log('❌ Promptfoo not found');
      console.log('💡 Installing promptfoo...');
      await this.runCommand('npm', ['install'], { silent: false });
    }

    console.log('✅ Prerequisites check complete');
    return true;
  }

  async runCommand(command, args, options = {}) {
    return new Promise((resolve, reject) => {
      const child = spawn(command, args, {
        stdio: options.silent ? 'pipe' : 'inherit',
        shell: true,
        cwd: this.packageRoot
      });

      child.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Command failed with code ${code}`));
        }
      });

      child.on('error', reject);
    });
  }

  async runTests(configType = 'basic') {
    const configFile = this.configs[configType];
    
    if (!configFile) {
      throw new Error(`Invalid config type: ${configType}. Available: ${Object.keys(this.configs).join(', ')}`);
    }

    if (!fs.existsSync(path.join(this.packageRoot, configFile))) {
      throw new Error(`Config file not found: ${configFile}`);
    }

    console.log(`🚀 Running ${configType} tests...`);
    console.log(`📁 Config: ${configFile}`);
    console.log('⏳ This may take a few minutes...\n');

    try {
      await this.runCommand('npx', ['promptfoo', 'eval', '-c', configFile]);
      console.log(`\n✅ ${configType} tests completed successfully!`);
      console.log(`💡 View results: npm run view:${configType}`);
      return true;
    } catch (error) {
      console.log(`\n❌ ${configType} tests failed:`, error.message);
      return false;
    }
  }

  async viewResults(configType = 'basic') {
    const configFile = this.configs[configType];
    
    console.log(`🌐 Opening results viewer for ${configType} tests...`);
    
    try {
      await this.runCommand('npx', ['promptfoo', 'view', '--config', configFile]);
    } catch (error) {
      console.log('❌ Failed to open results viewer:', error.message);
    }
  }

  async cleanResults() {
    console.log('🧹 Cleaning up test results...');
    
    const resultDirs = ['test-results', 'advanced-test-results'];
    
    for (const dir of resultDirs) {
      const dirPath = path.join(this.packageRoot, dir);
      if (fs.existsSync(dirPath)) {
        fs.rmSync(dirPath, { recursive: true, force: true });
        console.log(`🗑️  Removed ${dir}`);
      }
    }
    
    console.log('✅ Cleanup complete');
  }

  printUsage() {
    console.log(`
🧪 Promptfoo Sample Test Package Runner

Usage: node test-runner.js [command] [options]

Commands:
  check           Check prerequisites and setup
  test [type]     Run tests (type: basic, advanced, all)
  view [type]     View test results (type: basic, advanced)
  clean           Clean up result files
  help            Show this help message

Examples:
  node test-runner.js check
  node test-runner.js test basic
  node test-runner.js test advanced
  node test-runner.js test all
  node test-runner.js view basic
  node test-runner.js clean

Environment Setup:
  export OPENAI_API_KEY="your-api-key-here"
  # On Windows: set OPENAI_API_KEY=your-api-key-here
`);
  }

  async run() {
    const args = process.argv.slice(2);
    const command = args[0];
    const option = args[1];

    try {
      switch (command) {
        case 'check':
          await this.checkPrerequisites();
          break;

        case 'test':
          if (!(await this.checkPrerequisites())) {
            process.exit(1);
          }

          if (option === 'all') {
            console.log('🎯 Running all test configurations...\n');
            const basicSuccess = await this.runTests('basic');
            console.log('\n' + '='.repeat(50) + '\n');
            const advancedSuccess = await this.runTests('advanced');
            
            if (basicSuccess && advancedSuccess) {
              console.log('\n🎉 All tests completed successfully!');
            } else {
              console.log('\n⚠️  Some tests failed. Check the output above.');
              process.exit(1);
            }
          } else {
            const testType = option || 'basic';
            const success = await this.runTests(testType);
            if (!success) {
              process.exit(1);
            }
          }
          break;

        case 'view':
          const viewType = option || 'basic';
          await this.viewResults(viewType);
          break;

        case 'clean':
          await this.cleanResults();
          break;

        case 'help':
        case '--help':
        case '-h':
          this.printUsage();
          break;

        default:
          if (command) {
            console.log(`❌ Unknown command: ${command}\n`);
          }
          this.printUsage();
          break;
      }
    } catch (error) {
      console.error('❌ Error:', error.message);
      process.exit(1);
    }
  }
}

// Run the test runner if this script is executed directly
if (require.main === module) {
  const runner = new TestRunner();
  runner.run();
}

module.exports = TestRunner;