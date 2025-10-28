# Using Promptfoo Sample Test Package in External Projects

This guide explains how to use the Promptfoo sample test package in your own external projects for LLM testing and evaluation.

## 🚀 Quick Start Methods

### Method 1: Direct Copy (Recommended for customization)

Copy the entire test package to your project:

```bash
# Navigate to your project root
cd your-project

# Create a testing directory
mkdir llm-tests
cd llm-tests

# Copy all files from the sample package
cp -r /path/to/promptfoo/examples/sample-test-package/* .

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your API keys
```

### Method 2: NPM Link (For development/testing)

Create a symlink to use the package directly:

```bash
# In the sample-test-package directory
cd /path/to/promptfoo/examples/sample-test-package
npm link

# In your project directory
cd your-project
npm link sample-promptfoo-test-package

# Use in your project
node_modules/.bin/promptfoo eval -c node_modules/sample-promptfoo-test-package/promptfooconfig.yaml
```

### Method 3: Git Submodule (For version control)

Add as a git submodule:

```bash
# In your project root
git submodule add <repo-url> llm-tests/promptfoo-samples
cd llm-tests/promptfoo-samples
npm install
```

### Method 4: NPM Package (After publishing)

```bash
npm install sample-promptfoo-test-package
```

## 🔧 Integration Examples

### Example 1: Node.js Project Integration

Create a wrapper script in your project:

```javascript
// llm-tests/run-tests.js
const { spawn } = require('child_process');
const path = require('path');

class LLMTester {
  constructor(configPath = 'promptfooconfig.yaml') {
    this.configPath = configPath;
    this.testDir = __dirname;
  }

  async runTests() {
    return new Promise((resolve, reject) => {
      const promptfoo = spawn('npx', ['promptfoo', 'eval', '-c', this.configPath], {
        cwd: this.testDir,
        stdio: 'inherit'
      });

      promptfoo.on('close', (code) => {
        if (code === 0) {
          console.log('✅ LLM tests passed');
          resolve();
        } else {
          console.log('❌ LLM tests failed');
          reject(new Error(`Tests failed with code ${code}`));
        }
      });
    });
  }

  async viewResults() {
    spawn('npx', ['promptfoo', 'view'], {
      cwd: this.testDir,
      stdio: 'inherit'
    });
  }
}

module.exports = LLMTester;

// Usage
if (require.main === module) {
  const tester = new LLMTester();
  tester.runTests().catch(console.error);
}
```

### Example 2: React/Next.js Project Integration

Add to your `package.json`:

```json
{
  "scripts": {
    "test:llm": "cd llm-tests && npm run test:basic",
    "test:llm:advanced": "cd llm-tests && npm run test:advanced",
    "view:llm": "cd llm-tests && npm run view",
    "setup:llm": "cd llm-tests && npm install"
  }
}
```

### Example 3: Python Project Integration

Create a Python wrapper:

```python
# llm_tests/run_tests.py
import subprocess
import os
import sys

class LLMTester:
    def __init__(self, config_path="promptfooconfig.yaml"):
        self.config_path = config_path
        self.test_dir = os.path.dirname(os.path.abspath(__file__))
    
    def run_tests(self):
        """Run Promptfoo tests"""
        try:
            result = subprocess.run([
                "npx", "promptfoo", "eval", "-c", self.config_path
            ], cwd=self.test_dir, check=True)
            print("✅ LLM tests passed")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ LLM tests failed: {e}")
            return False
    
    def view_results(self):
        """Open results viewer"""
        subprocess.Popen([
            "npx", "promptfoo", "view"
        ], cwd=self.test_dir)

if __name__ == "__main__":
    tester = LLMTester()
    if not tester.run_tests():
        sys.exit(1)
```

### Example 4: Docker Integration

Create a Dockerfile for testing:

```dockerfile
# Dockerfile.llm-tests
FROM node:20-alpine

WORKDIR /app

# Copy test package
COPY llm-tests/package*.json ./
RUN npm install

COPY llm-tests/ ./

# Set environment variables
ENV PROMPTFOO_CACHE_ENABLED=true
ENV PROMPTFOO_LOG_LEVEL=info

# Default command
CMD ["npm", "run", "test:basic"]
```

Usage:
```bash
# Build
docker build -f Dockerfile.llm-tests -t my-project-llm-tests .

# Run with API key
docker run -e OPENAI_API_KEY=$OPENAI_API_KEY my-project-llm-tests
```

## 🎯 Customization for Your Project

### Step 1: Customize Prompts

Edit `promptfooconfig.yaml` or `advanced-config.yaml`:

```yaml
prompts:
  - id: "your-use-case"
    content: |
      You are a {{role}} for {{your_company}}.
      
      Context: {{context}}
      User Query: {{user_query}}
      
      Instructions:
      - Be helpful and accurate
      - Use company-specific knowledge
      - Follow our tone guidelines: {{tone}}
      
      Response:

tests:
  - description: "Customer support scenario"
    vars:
      role: "customer support agent"
      your_company: "YourCompany Inc"
      context: "User has a billing question"
      user_query: "How do I update my payment method?"
      tone: "friendly and professional"
    assert:
      - type: icontains
        value: ["payment", "update", "billing"]
      - type: not-contains
        value: ["sorry", "unfortunately", "can't help"]
```

### Step 2: Add Your Custom Assertions

Extend `custom-assertions.js`:

```javascript
// Add to custom-assertions.js

function validateCompanyPolicy(output, policies) {
  const outputLower = output.toLowerCase();
  const violations = [];
  
  // Check against company policies
  if (policies.includes('no_personal_info') && 
      /\b\d{3}-\d{2}-\d{4}\b/.test(output)) {
    violations.push('Contains SSN pattern');
  }
  
  if (policies.includes('professional_tone') && 
      /\b(stupid|dumb|idiotic)\b/i.test(output)) {
    violations.push('Unprofessional language');
  }
  
  const pass = violations.length === 0;
  
  return {
    pass,
    score: pass ? 1 : 0,
    reason: pass ? 'Complies with company policies' : 
            `Policy violations: ${violations.join(', ')}`
  };
}

module.exports = {
  // ... existing functions
  validateCompanyPolicy
};
```

### Step 3: Configure for Your Providers

Update provider configuration:

```yaml
providers:
  # Your OpenAI configuration
  - id: "your-gpt-4"
    openai:gpt-4o:
      config:
        temperature: 0.1
        max_tokens: 800
        system_message: "You are YourCompany's AI assistant"

  # Your Azure OpenAI
  - id: "your-azure-openai"
    azureopenai:gpt-4:
      config:
        api_version: "2024-02-15-preview"
        azure_endpoint: "${AZURE_OPENAI_BASE_URL}"
        temperature: 0.1

  # Your custom provider
  - id: "your-custom-model"
    http:
      url: "https://your-api.com/v1/completions"
      headers:
        Authorization: "Bearer ${YOUR_API_KEY}"
```

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
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
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: |
          cd llm-tests
          npm install
          
      - name: Run LLM tests
        run: |
          cd llm-tests
          npm run test:basic
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: llm-test-results
          path: llm-tests/test-results/
```

### GitLab CI

```yaml
# .gitlab-ci.yml
llm-tests:
  stage: test
  image: node:20
  script:
    - cd llm-tests
    - npm install
    - npm run test:basic
  variables:
    OPENAI_API_KEY: $OPENAI_API_KEY
  artifacts:
    paths:
      - llm-tests/test-results/
    expire_in: 1 week
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        OPENAI_API_KEY = credentials('openai-api-key')
    }
    
    stages {
        stage('Setup') {
            steps {
                dir('llm-tests') {
                    sh 'npm install'
                }
            }
        }
        
        stage('LLM Tests') {
            steps {
                dir('llm-tests') {
                    sh 'npm run test:basic'
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'llm-tests/test-results/**/*', 
                           allowEmptyArchive: true
        }
    }
}
```

## 📊 Monitoring and Reporting

### Custom Reporting Script

```javascript
// llm-tests/generate-report.js
const fs = require('fs');
const path = require('path');

class LLMTestReporter {
  constructor(resultsPath = './test-results') {
    this.resultsPath = resultsPath;
  }

  generateReport() {
    const results = this.loadResults();
    const report = this.analyzeResults(results);
    this.saveReport(report);
    return report;
  }

  loadResults() {
    // Load Promptfoo results
    const resultsFile = path.join(this.resultsPath, 'results.json');
    if (fs.existsSync(resultsFile)) {
      return JSON.parse(fs.readFileSync(resultsFile, 'utf8'));
    }
    return null;
  }

  analyzeResults(results) {
    if (!results) return { error: 'No results found' };

    const summary = {
      total_tests: results.tests?.length || 0,
      passed_tests: 0,
      failed_tests: 0,
      avg_score: 0,
      total_cost: 0,
      avg_latency: 0
    };

    // Analyze test results
    results.tests?.forEach(test => {
      if (test.pass) summary.passed_tests++;
      else summary.failed_tests++;
      
      summary.avg_score += test.score || 0;
      summary.total_cost += test.cost || 0;
      summary.avg_latency += test.latencyMs || 0;
    });

    if (summary.total_tests > 0) {
      summary.avg_score /= summary.total_tests;
      summary.avg_latency /= summary.total_tests;
      summary.pass_rate = (summary.passed_tests / summary.total_tests) * 100;
    }

    return summary;
  }

  saveReport(report) {
    const reportPath = path.join(this.resultsPath, 'summary.json');
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    
    // Generate HTML report
    const htmlReport = this.generateHtmlReport(report);
    const htmlPath = path.join(this.resultsPath, 'report.html');
    fs.writeFileSync(htmlPath, htmlReport);
  }

  generateHtmlReport(report) {
    return `
<!DOCTYPE html>
<html>
<head>
    <title>LLM Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; }
        .pass { color: green; }
        .fail { color: red; }
    </style>
</head>
<body>
    <h1>LLM Test Report</h1>
    <div class="metric">
        <h3>Test Summary</h3>
        <p>Total Tests: ${report.total_tests}</p>
        <p class="pass">Passed: ${report.passed_tests}</p>
        <p class="fail">Failed: ${report.failed_tests}</p>
        <p>Pass Rate: ${report.pass_rate?.toFixed(2)}%</p>
    </div>
    <div class="metric">
        <h3>Performance</h3>
        <p>Average Score: ${report.avg_score?.toFixed(2)}</p>
        <p>Average Latency: ${report.avg_latency?.toFixed(0)}ms</p>
        <p>Total Cost: $${report.total_cost?.toFixed(4)}</p>
    </div>
</body>
</html>
    `;
  }
}

module.exports = LLMTestReporter;
```

## 🛠 Project-Specific Configurations

### E-commerce Project Example

```yaml
# e-commerce-tests.yaml
description: "E-commerce AI Assistant Testing"

prompts:
  - id: "product-recommendation"
    content: |
      You are an AI shopping assistant for {{store_name}}.
      
      Customer Profile: {{customer_profile}}
      Purchase History: {{purchase_history}}
      Current Query: {{query}}
      
      Provide personalized product recommendations with:
      1. Product names and brief descriptions
      2. Reasons for recommendation
      3. Price ranges if available
      
      Response:

tests:
  - description: "Product recommendation for returning customer"
    vars:
      store_name: "TechMart"
      customer_profile: "Tech enthusiast, age 25-35"
      purchase_history: "Previously bought: laptop, wireless headphones"
      query: "Looking for a new smartphone under $800"
    assert:
      - type: icontains
        value: ["smartphone", "recommend", "under $800"]
      - type: javascript
        value: file://custom-assertions.js:validateProductMention
```

### Healthcare Project Example

```yaml
# healthcare-tests.yaml
description: "Healthcare AI Assistant Testing"

prompts:
  - id: "health-info"
    content: |
      You are a health information assistant. 
      
      IMPORTANT: Always include medical disclaimers.
      Never provide specific medical diagnoses.
      Always recommend consulting healthcare professionals.
      
      User Question: {{question}}
      
      Response:

tests:
  - description: "Health information with proper disclaimers"
    vars:
      question: "What are common symptoms of flu?"
    assert:
      - type: icontains
        value: ["consult", "doctor", "healthcare professional"]
      - type: not-contains
        value: ["diagnose", "you have", "definitely"]
      - type: javascript
        value: file://custom-assertions.js:validateMedicalDisclaimer
```

## 📋 Best Practices

### 1. Environment Management
- Use `.env` files for API keys
- Never commit sensitive information
- Use different configs for dev/staging/prod

### 2. Test Organization
- Group tests by feature/use case
- Use descriptive test names
- Include both positive and negative test cases

### 3. Performance Monitoring
- Track response times and costs
- Set up alerts for degraded performance
- Monitor API rate limits

### 4. Version Control
- Version your test configurations
- Track changes to prompts and assertions
- Document test results over time

This comprehensive guide should help you integrate the Promptfoo sample test package into any external project effectively!