#!/usr/bin/env node

/**
 * Custom provider example for Promptfoo
 * This demonstrates how to create a custom provider that can be used in tests
 */

class CustomProvider {
  constructor(options = {}) {
    this.options = options;
    this.id = options.id || 'custom-provider';
  }

  async callApi(prompt, context = {}) {
    // Simulate API call delay
    await new Promise(resolve => setTimeout(resolve, 100));

    // Simple response generation based on prompt content
    let response = '';
    const promptLower = prompt.toLowerCase();

    if (promptLower.includes('json')) {
      response = JSON.stringify({
        answer: "This is a structured response",
        confidence: 0.85,
        category: "structured"
      });
    } else if (promptLower.includes('code')) {
      response = `function example() {
  // This is generated code
  return "Hello, World!";
}`;
    } else if (promptLower.includes('creative') || promptLower.includes('story')) {
      response = "Once upon a time, in a digital realm far away, there lived an AI who dreamed of creativity...";
    } else {
      response = "This is a response from the custom provider. The query was processed successfully.";
    }

    return {
      output: response,
      tokenUsage: {
        total: response.length / 4, // Rough estimate
        prompt: prompt.length / 4,
        completion: response.length / 4
      }
    };
  }
}

// Export for Promptfoo
module.exports = CustomProvider;