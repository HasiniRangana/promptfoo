# Sample Promptfoo Test Package

This package demonstrates comprehensive LLM testing capabilities using Promptfoo. It includes various test scenarios, custom providers, custom assertions, and real-world use cases.

## 🚀 Quick Start

### Prerequisites

1. **Node.js 20+**: Ensure you have Node.js installed
2. **OpenAI API Key**: Set your OpenAI API key as an environment variable

```bash
# Set your OpenAI API key
export OPENAI_API_KEY="your-api-key-here"

# On Windows:
# set OPENAI_API_KEY=your-api-key-here
```

### Installation and Setup

```bash
# Navigate to the sample package directory
cd examples/sample-test-package

# Install dependencies
npm install

# Run basic tests
npm run test:basic

# View results in browser
npm run view:basic
```

## 📁 Package Structure

```
sample-test-package/
├── promptfooconfig.yaml          # Basic test configuration
├── advanced-config.yaml          # Advanced test scenarios
├── test-data.yaml                # Sample test datasets
├── custom-provider.js            # Custom provider implementation
├── custom-assertions.js          # Custom assertion functions
├── package.json                  # Package configuration
└── README.md                     # This file
```

## 🧪 Test Configurations

### Basic Configuration (`promptfooconfig.yaml`)

Demonstrates fundamental Promptfoo features:
- Multiple prompt templates
- Provider comparisons
- Basic assertions
- JSON validation
- Creative writing tests
- Code generation tests
- Data analysis scenarios

**Key Features:**
- **5 different prompt types** for various use cases
- **Multiple test scenarios** covering different domains
- **Provider comparison** between GPT-4o and GPT-4o-mini
- **Built-in assertions** for content validation

### Advanced Configuration (`advanced-config.yaml`)

Showcases advanced testing capabilities:
- Custom assertions and providers
- Multi-environment configurations
- Complex validation logic
- Sentiment analysis
- Code review scenarios
- Educational content testing

**Key Features:**
- **Custom assertion functions** for specialized validation
- **Customer service scenarios** with sentiment matching
- **Code review automation** with security considerations
- **Educational content** appropriateness testing
- **Multi-provider comparisons** with different configurations

## 🎯 Test Scenarios Included

### 1. **Basic Q&A Testing**
- Factual questions
- Mathematical reasoning
- Empty input handling
- Ambiguous question handling

### 2. **Structured Response Testing**
- JSON format validation
- Required field validation
- Data type verification

### 3. **Creative Writing Testing**
- Story generation with constraints
- Tone and theme validation
- Word count compliance
- Content appropriateness

### 4. **Code Generation Testing**
- Python function generation
- JavaScript validation
- Syntax verification
- Best practices checking

### 5. **Data Analysis Testing**
- Trend analysis
- Insight generation
- Recommendation quality

### 6. **Customer Service Scenarios**
- Sentiment-appropriate responses
- Professional tone maintenance
- Problem resolution focus

### 7. **Code Review Automation**
- Security vulnerability detection
- Best practices validation
- Improvement suggestions

## 🛠 Custom Components

### Custom Provider (`custom-provider.js`)

A sample implementation showing how to:
- Create custom LLM providers
- Handle different response types
- Simulate API calls and responses
- Integrate with Promptfoo's evaluation system

```javascript
// Usage in config:
providers:
  - id: "custom-test-provider"
    file://custom-provider.js:
      config:
        id: "custom-test"
```

### Custom Assertions (`custom-assertions.js`)

Specialized validation functions for:
- **Email validation**: Checks for valid email addresses
- **Code syntax validation**: Verifies code structure
- **Understanding assessment**: Measures context comprehension
- **Sentiment analysis**: Validates emotional appropriateness
- **Length validation**: Ensures appropriate response length

```javascript
// Usage in config:
assert:
  - type: javascript
    value: file://custom-assertions.js:appropriateSentiment
    threshold: "positive"
```

## 📊 Running Tests

### Basic Tests
```bash
# Run all basic tests
npm run test:basic

# View results
npm run view:basic
```

### Advanced Tests
```bash
# Run advanced test scenarios
npm run test:advanced

# View advanced results
npm run view:advanced
```

### Custom Commands
```bash
# Clean up result files
npm run clean

# Run specific config file
npx promptfoo eval -c your-config.yaml

# Compare specific providers
npx promptfoo eval --providers openai:gpt-4o,openai:gpt-4o-mini

# Run with custom output path
npx promptfoo eval -o ./custom-results
```

## 🔧 Configuration Options

### Environment Variables

```bash
# Required
OPENAI_API_KEY=your-api-key

# Optional
PROMPTFOO_CACHE_ENABLED=true
PROMPTFOO_LOG_LEVEL=info
PROMPTFOO_MAX_CONCURRENCY=5
```

### Provider Configuration Examples

```yaml
providers:
  # OpenAI with custom settings
  - openai:gpt-4o:
      config:
        temperature: 0.1
        max_tokens: 500
        top_p: 0.9

  # Anthropic Claude
  - anthropic:claude-3-sonnet-20240229:
      config:
        temperature: 0.1
        max_tokens: 500

  # Custom provider
  - file://custom-provider.js:
      config:
        custom_param: "value"
```

## 📈 Understanding Results

### Scoring System
- **Pass/Fail**: Binary assessment for each assertion
- **Score**: Numerical value (0-1) indicating quality
- **Detailed Metrics**: Token usage, latency, cost analysis

### Key Metrics to Monitor
1. **Pass Rate**: Percentage of tests passing
2. **Average Score**: Overall quality metric
3. **Latency**: Response time per test
4. **Cost**: API usage costs
5. **Error Rate**: Failed API calls

### Result Analysis
```bash
# View detailed results in browser
npm run view

# Export results to CSV
npx promptfoo export --format csv

# Generate summary report
npx promptfoo export --format html
```

## 🎨 Customization Guide

### Adding New Test Cases

1. **Define prompts** in the `prompts` section
2. **Add test scenarios** in the `tests` section
3. **Configure assertions** for validation
4. **Set up providers** for comparison

Example:
```yaml
prompts:
  - id: "my-custom-prompt"
    content: |
      You are a {{role}}. {{task}}
      
      Input: {{input}}
      Output:

tests:
  - description: "My custom test"
    vars:
      role: "helpful assistant"
      task: "Provide a clear answer"
      input: "What is AI?"
    assert:
      - type: contains
        value: "artificial intelligence"
```

### Creating Custom Assertions

1. **Write assertion function** in JavaScript
2. **Export the function** from your module
3. **Reference in config** using `file://` syntax

Example:
```javascript
function customAssertion(output, threshold) {
  const isValid = output.includes(threshold);
  return {
    pass: isValid,
    score: isValid ? 1 : 0,
    reason: `Custom validation ${isValid ? 'passed' : 'failed'}`
  };
}

module.exports = { customAssertion };
```

## 🚀 Integration with Projects

### Using with Existing Projects

1. **Copy configuration files** to your project
2. **Modify prompts** to match your use case
3. **Update providers** based on your requirements
4. **Customize test data** for your domain

### CI/CD Integration

```yaml
# GitHub Actions example
name: LLM Testing
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '20'
      - run: npm install
      - run: npm run test
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

### Docker Integration

```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "test"]
```

## 🔍 Troubleshooting

### Common Issues

1. **API Key Not Set**
   ```bash
   Error: OpenAI API key not provided
   Solution: Set OPENAI_API_KEY environment variable
   ```

2. **Rate Limiting**
   ```bash
   Error: Rate limit exceeded
   Solution: Reduce maxConcurrency or add delays
   ```

3. **Invalid Configuration**
   ```bash
   Error: Invalid YAML syntax
   Solution: Validate YAML syntax using online tools
   ```

### Debug Mode
```bash
# Enable debug logging
PROMPTFOO_LOG_LEVEL=debug npm run test

# Verbose output
npx promptfoo eval --verbose
```

## 📚 Additional Resources

- [Promptfoo Documentation](https://promptfoo.dev/docs)
- [Configuration Reference](https://promptfoo.dev/docs/configuration)
- [Provider Guide](https://promptfoo.dev/docs/providers)
- [Assertion Types](https://promptfoo.dev/docs/configuration/expected-outputs)

## 🤝 Contributing

This sample package is designed to be educational and extensible. Feel free to:
- Add new test scenarios
- Improve custom assertions
- Create additional providers
- Enhance documentation

## 📄 License

MIT License - Feel free to use this package as a starting point for your own LLM testing needs.