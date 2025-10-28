#!/bin/bash
# Installation script for Promptfoo with MySQL integration

set -e

echo "================================"
echo "🚀 Installing Promptfoo with MySQL Integration"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a project directory
if [[ ! -f "package.json" && ! -f "requirements.txt" && ! -f "Gemfile" ]]; then
    echo -e "${YELLOW}⚠️  Warning: No package.json, requirements.txt, or Gemfile found.${NC}"
    echo "    Are you in your project root directory?"
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}❌ Node.js not found. Please install Node.js first.${NC}"
    exit 1
fi

# Check npm
if ! command_exists npm; then
    echo -e "${RED}❌ npm not found. Please install npm first.${NC}"
    exit 1
fi

echo "📦 Installing @hasinirangana/promptfoo-mysql..."

# Install the package
if [[ -f "package.json" ]]; then
    # Add to existing Node.js project
    npm install @hasinirangana/promptfoo-mysql
    
    echo "📝 Adding scripts to package.json..."
    
    # Create a temporary script to add npm scripts
    cat > add_scripts.js << 'EOF'
const fs = require('fs');
const path = require('path');

const packageJsonPath = './package.json';
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

if (!packageJson.scripts) {
    packageJson.scripts = {};
}

// Add MySQL Promptfoo scripts
packageJson.scripts['promptfoo:eval'] = 'promptfoo-mysql eval';
packageJson.scripts['promptfoo:view'] = 'promptfoo-mysql view';
packageJson.scripts['promptfoo:init'] = 'promptfoo-mysql init';
packageJson.scripts['promptfoo:cache'] = 'promptfoo-mysql cache';
packageJson.scripts['promptfoo:mysql:migrate'] = 'promptfoo-mysql db:mysql:migrate';
packageJson.scripts['promptfoo:mysql:studio'] = 'promptfoo-mysql db:mysql:studio';

fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));
console.log('✅ Scripts added to package.json');
EOF

    node add_scripts.js
    rm add_scripts.js
    
else
    # Global installation
    echo "📦 Installing globally..."
    npm install -g @hasinirangana/promptfoo-mysql
fi

echo "⚙️  Setting up MySQL configuration..."

# Create sample .env file
if [[ ! -f ".env" ]]; then
    cat > .env << 'EOF'
# MySQL Configuration for Promptfoo
PROMPTFOO_MYSQL_HOST=localhost
PROMPTFOO_MYSQL_PORT=3306
PROMPTFOO_MYSQL_USER=root
PROMPTFOO_MYSQL_PASSWORD=your_password_here
PROMPTFOO_MYSQL_DATABASE=promptfoo

# Optional: Enable SSL
# PROMPTFOO_MYSQL_SSL=true

# Optional: Enable database query logging
# PROMPTFOO_ENABLE_DATABASE_LOGS=true

# Your LLM API Keys
OPENAI_API_KEY=your_openai_key_here
ANTHROPIC_API_KEY=your_anthropic_key_here
EOF
    echo "📄 Created .env file with sample configuration"
else
    echo "📄 .env file already exists, skipping creation"
fi

# Create sample promptfoo config
if [[ ! -f "promptfooconfig.yaml" ]]; then
    cat > promptfooconfig.yaml << 'EOF'
# Promptfoo configuration with MySQL backend
description: 'My LLM evaluation with MySQL storage'

providers:
  - openai:gpt-4o-mini
  - openai:gpt-3.5-turbo

tests:
  - vars:
      question: "What is the capital of France?"
    assert:
      - type: contains
        value: "Paris"
  
  - vars:
      question: "Explain quantum computing in simple terms"
    assert:
      - type: llm-rubric
        value: "The response should explain quantum computing concepts clearly and be understandable to a general audience"

# Results will be stored in MySQL database
outputPath: './promptfoo_output.json'
EOF
    echo "📄 Created sample promptfooconfig.yaml"
else
    echo "📄 promptfooconfig.yaml already exists, skipping creation"
fi

# Create MySQL setup script
cat > setup_mysql.sh << 'EOF'
#!/bin/bash
# MySQL database setup script

echo "🗄️  Setting up MySQL database for Promptfoo..."

# Check if MySQL is installed
if ! command -v mysql >/dev/null 2>&1; then
    echo "❌ MySQL client not found. Please install MySQL first."
    exit 1
fi

# Read MySQL credentials
read -p "MySQL host (default: localhost): " mysql_host
mysql_host=${mysql_host:-localhost}

read -p "MySQL port (default: 3306): " mysql_port
mysql_port=${mysql_port:-3306}

read -p "MySQL user (default: root): " mysql_user
mysql_user=${mysql_user:-root}

read -s -p "MySQL password: " mysql_password
echo

read -p "Database name (default: promptfoo): " mysql_database
mysql_database=${mysql_database:-promptfoo}

# Create database
echo "📊 Creating database '$mysql_database'..."
mysql -h "$mysql_host" -P "$mysql_port" -u "$mysql_user" -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS $mysql_database;"

if [ $? -eq 0 ]; then
    echo "✅ Database created successfully!"
    
    # Update .env file
    if [ -f ".env" ]; then
        sed -i.bak "s/PROMPTFOO_MYSQL_HOST=.*/PROMPTFOO_MYSQL_HOST=$mysql_host/" .env
        sed -i.bak "s/PROMPTFOO_MYSQL_PORT=.*/PROMPTFOO_MYSQL_PORT=$mysql_port/" .env
        sed -i.bak "s/PROMPTFOO_MYSQL_USER=.*/PROMPTFOO_MYSQL_USER=$mysql_user/" .env
        sed -i.bak "s/PROMPTFOO_MYSQL_PASSWORD=.*/PROMPTFOO_MYSQL_PASSWORD=$mysql_password/" .env
        sed -i.bak "s/PROMPTFOO_MYSQL_DATABASE=.*/PROMPTFOO_MYSQL_DATABASE=$mysql_database/" .env
        rm .env.bak
        echo "📝 Updated .env file with your MySQL configuration"
    fi
else
    echo "❌ Failed to create database. Please check your MySQL credentials."
    exit 1
fi

echo "🚀 Running database migrations..."
if [ -f "package.json" ]; then
    npm run promptfoo:mysql:migrate
else
    promptfoo-mysql db:mysql:migrate
fi

echo "✅ MySQL setup complete!"
EOF

chmod +x setup_mysql.sh

# Create quick test script
cat > test_promptfoo.sh << 'EOF'
#!/bin/bash
# Quick test script for Promptfoo with MySQL

echo "🧪 Testing Promptfoo with MySQL integration..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please run setup_mysql.sh first."
    exit 1
fi

# Source environment variables
export $(cat .env | grep -v '^#' | xargs)

# Test MySQL connection
echo "🔗 Testing MySQL connection..."
if [ -f "package.json" ]; then
    node -e "
    const { testMysqlConnection } = require('@hasinirangana/promptfoo-mysql/dist/src/database/mysql-index');
    testMysqlConnection().then(success => {
        if (success) {
            console.log('✅ MySQL connection successful!');
            process.exit(0);
        } else {
            console.log('❌ MySQL connection failed!');
            process.exit(1);
        }
    });
    "
else
    promptfoo-mysql eval --help >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Promptfoo MySQL installation verified!"
    else
        echo "❌ Promptfoo MySQL installation verification failed!"
        exit 1
    fi
fi

echo "🎯 Running sample evaluation..."
if [ -f "package.json" ]; then
    npm run promptfoo:eval
else
    promptfoo-mysql eval
fi

echo "🎉 Test complete! Check the results with:"
if [ -f "package.json" ]; then
    echo "   npm run promptfoo:view"
else
    echo "   promptfoo-mysql view"
fi
EOF

chmod +x test_promptfoo.sh

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "📋 Next steps:"
echo "1. 🗄️  Set up MySQL database: ./setup_mysql.sh"
echo "2. 📝 Edit .env file with your API keys"
echo "3. 🧪 Run a test: ./test_promptfoo.sh"
echo ""
echo "📚 Available commands:"
if [[ -f "package.json" ]]; then
    echo "  npm run promptfoo:eval       - Run evaluations"
    echo "  npm run promptfoo:view       - View results"
    echo "  npm run promptfoo:init       - Initialize new config"
    echo "  npm run promptfoo:mysql:migrate - Run MySQL migrations"
    echo "  npm run promptfoo:mysql:studio  - Open MySQL studio"
else
    echo "  promptfoo-mysql eval         - Run evaluations"
    echo "  promptfoo-mysql view         - View results"
    echo "  promptfoo-mysql init         - Initialize new config"
    echo "  promptfoo-mysql db:mysql:migrate - Run MySQL migrations"
    echo "  promptfoo-mysql db:mysql:studio  - Open MySQL studio"
fi
echo ""
echo "📖 Documentation:"
echo "  https://github.com/HasiniRangana/promptfoo"
echo ""
echo -e "${YELLOW}💡 Don't forget to set your API keys in .env file!${NC}"