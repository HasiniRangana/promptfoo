#!/bin/bash

# Installation script for external projects
# This script sets up the Promptfoo test package in your project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="promptfoo-llm-tests"
SOURCE_PATH="$(dirname "$0")"

echo -e "${GREEN}🚀 Promptfoo LLM Test Package Installer${NC}"
echo "=================================="

# Check if we're in a project directory
if [ ! -f "package.json" ] && [ ! -f "requirements.txt" ] && [ ! -f "Gemfile" ]; then
    echo -e "${YELLOW}⚠️  Warning: No package.json, requirements.txt, or Gemfile found.${NC}"
    echo -e "${YELLOW}   Are you in your project root directory?${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create test directory
echo -e "${GREEN}📁 Creating test directory...${NC}"
mkdir -p "$PACKAGE_NAME"

# Copy files
echo -e "${GREEN}📋 Copying test files...${NC}"
cp -r "$SOURCE_PATH"/* "$PACKAGE_NAME/"

# Navigate to test directory
cd "$PACKAGE_NAME"

# Remove installer script from copied files
rm -f install.sh

# Install Node.js dependencies
echo -e "${GREEN}📦 Installing dependencies...${NC}"
if command -v npm &> /dev/null; then
    npm install
else
    echo -e "${RED}❌ npm not found. Please install Node.js first.${NC}"
    exit 1
fi

# Create environment file
echo -e "${GREEN}⚙️  Setting up environment...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${YELLOW}📝 Please edit .env file with your API keys${NC}"
fi

# Update parent package.json if it exists
cd ..
if [ -f "package.json" ]; then
    echo -e "${GREEN}📝 Adding test scripts to package.json...${NC}"
    
    # Check if jq is available for JSON manipulation
    if command -v jq &> /dev/null; then
        # Use jq to add scripts
        jq '.scripts += {
            "test:llm": "cd '$PACKAGE_NAME' && npm run test:basic",
            "test:llm:advanced": "cd '$PACKAGE_NAME' && npm run test:advanced",
            "test:llm:quick": "cd '$PACKAGE_NAME' && npm run test -- -c quick-test.yaml",
            "view:llm": "cd '$PACKAGE_NAME' && npm run view",
            "setup:llm": "cd '$PACKAGE_NAME' && npm install"
        }' package.json > package.json.tmp && mv package.json.tmp package.json
        
        echo -e "${GREEN}✅ Added LLM test scripts to package.json${NC}"
    else
        echo -e "${YELLOW}⚠️  jq not found. Please manually add these scripts to your package.json:${NC}"
        cat << EOF

"scripts": {
  "test:llm": "cd $PACKAGE_NAME && npm run test:basic",
  "test:llm:advanced": "cd $PACKAGE_NAME && npm run test:advanced", 
  "test:llm:quick": "cd $PACKAGE_NAME && npm run test -- -c quick-test.yaml",
  "view:llm": "cd $PACKAGE_NAME && npm run view",
  "setup:llm": "cd $PACKAGE_NAME && npm install"
}

EOF
    fi
fi

# Create integration examples
echo -e "${GREEN}📄 Creating integration examples...${NC}"

# Python integration
cat > "$PACKAGE_NAME/python_integration.py" << 'EOF'
#!/usr/bin/env python3
"""
Python integration example for Promptfoo LLM tests
"""

import subprocess
import os
import sys
from pathlib import Path

class LLMTester:
    def __init__(self, config_file="promptfooconfig.yaml"):
        self.config_file = config_file
        self.test_dir = Path(__file__).parent
        
    def run_tests(self, config="basic"):
        """Run LLM tests with specified configuration"""
        config_map = {
            "basic": "promptfooconfig.yaml",
            "advanced": "advanced-config.yaml", 
            "quick": "quick-test.yaml"
        }
        
        config_file = config_map.get(config, config)
        
        try:
            print(f"🧪 Running {config} LLM tests...")
            result = subprocess.run([
                "npm", "run", f"test -- -c {config_file}"
            ], cwd=self.test_dir, check=True, capture_output=True, text=True)
            
            print("✅ LLM tests passed!")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ LLM tests failed: {e}")
            print(f"Output: {e.stdout}")
            print(f"Error: {e.stderr}")
            return False
    
    def view_results(self):
        """Open the results viewer"""
        subprocess.Popen([
            "npm", "run", "view"
        ], cwd=self.test_dir)

if __name__ == "__main__":
    tester = LLMTester()
    
    config = sys.argv[1] if len(sys.argv) > 1 else "basic"
    
    if not tester.run_tests(config):
        sys.exit(1)
EOF

# Node.js integration
cat > "$PACKAGE_NAME/nodejs_integration.js" << 'EOF'
#!/usr/bin/env node
/**
 * Node.js integration example for Promptfoo LLM tests
 */

const { spawn } = require('child_process');
const path = require('path');

class LLMTester {
    constructor(configFile = 'promptfooconfig.yaml') {
        this.configFile = configFile;
        this.testDir = __dirname;
    }

    async runTests(config = 'basic') {
        const configMap = {
            basic: 'promptfooconfig.yaml',
            advanced: 'advanced-config.yaml',
            quick: 'quick-test.yaml'
        };

        const configFile = configMap[config] || config;

        return new Promise((resolve, reject) => {
            console.log(`🧪 Running ${config} LLM tests...`);
            
            const promptfoo = spawn('npm', ['run', `test`, '--', '-c', configFile], {
                cwd: this.testDir,
                stdio: 'inherit'
            });

            promptfoo.on('close', (code) => {
                if (code === 0) {
                    console.log('✅ LLM tests passed!');
                    resolve();
                } else {
                    console.log('❌ LLM tests failed!');
                    reject(new Error(`Tests failed with code ${code}`));
                }
            });

            promptfoo.on('error', (err) => {
                reject(err);
            });
        });
    }

    viewResults() {
        const viewer = spawn('npm', ['run', 'view'], {
            cwd: this.testDir,
            stdio: 'inherit'
        });
        
        return viewer;
    }
}

// CLI usage
if (require.main === module) {
    const tester = new LLMTester();
    const config = process.argv[2] || 'basic';
    
    tester.runTests(config).catch((error) => {
        console.error(error);
        process.exit(1);
    });
}

module.exports = LLMTester;
EOF

# Docker example
cat > "$PACKAGE_NAME/Dockerfile.example" << 'EOF'
# Example Dockerfile for running LLM tests
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy test files
COPY . .

# Set environment variables
ENV PROMPTFOO_CACHE_ENABLED=true
ENV PROMPTFOO_LOG_LEVEL=info

# Default command - run basic tests
CMD ["npm", "run", "test:basic"]

# To run with different configs:
# docker run -e OPENAI_API_KEY=$OPENAI_API_KEY your-image npm run test:advanced
EOF

# CI/CD examples
mkdir -p "$PACKAGE_NAME/ci-examples"

cat > "$PACKAGE_NAME/ci-examples/github-actions.yml" << 'EOF'
# .github/workflows/llm-tests.yml
name: LLM Testing

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  llm-tests:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: '**/package-lock.json'
          
      - name: Install dependencies
        run: npm run setup:llm
          
      - name: Run quick LLM tests
        run: npm run test:llm:quick
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          
      - name: Run full LLM tests
        run: npm run test:llm
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: llm-test-results
          path: promptfoo-llm-tests/test-results/
          retention-days: 30
EOF

cat > "$PACKAGE_NAME/ci-examples/gitlab-ci.yml" << 'EOF'
# .gitlab-ci.yml
stages:
  - test

llm-tests:
  stage: test
  image: node:20
  before_script:
    - npm run setup:llm
  script:
    - npm run test:llm:quick
    - npm run test:llm
  variables:
    OPENAI_API_KEY: $OPENAI_API_KEY
  artifacts:
    paths:
      - promptfoo-llm-tests/test-results/
    expire_in: 1 week
    when: always
  only:
    - main
    - develop
    - merge_requests
EOF

# Add .gitignore entries
cat >> "$PACKAGE_NAME/.gitignore" << 'EOF'

# Test results
test-results/
advanced-test-results/
quick-test-results/

# Environment files
.env
.env.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Cache
.promptfoo-cache/
EOF

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${GREEN}📋 Next steps:${NC}"
echo "1. Edit $PACKAGE_NAME/.env with your API keys"
echo "2. Run a quick test: cd $PACKAGE_NAME && npm run test -- -c quick-test.yaml"
echo "3. Run full tests: npm run test:llm (from project root)"
echo "4. View results: npm run view:llm"
echo ""
echo -e "${GREEN}📚 Available commands:${NC}"
echo "  npm run test:llm           - Run basic LLM tests"
echo "  npm run test:llm:advanced  - Run advanced LLM tests"
echo "  npm run test:llm:quick     - Run quick validation tests"
echo "  npm run view:llm           - View test results in browser"
echo "  npm run setup:llm          - Reinstall test dependencies"
echo ""
echo -e "${GREEN}📖 Documentation:${NC}"
echo "  See $PACKAGE_NAME/README.md for detailed usage"
echo "  See $PACKAGE_NAME/INTEGRATION_GUIDE.md for integration examples"
echo ""
echo -e "${YELLOW}💡 Don't forget to set your OPENAI_API_KEY in $PACKAGE_NAME/.env${NC}"
EOF