/**
 * Custom assertion functions for Promptfoo tests
 * These can be used in test configurations to create specialized validation logic
 */

/**
 * Check if the response contains a valid email address
 */
function containsValidEmail(output, threshold) {
  const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/;
  const hasEmail = emailRegex.test(output);
  
  return {
    pass: hasEmail,
    score: hasEmail ? 1 : 0,
    reason: hasEmail ? 'Output contains a valid email address' : 'No valid email address found in output'
  };
}

/**
 * Check if code output is syntactically valid
 */
function isValidCode(output, language = 'javascript') {
  let isValid = false;
  let reason = '';

  try {
    if (language.toLowerCase() === 'javascript') {
      // Basic syntax check for JavaScript
      new Function(output);
      isValid = true;
      reason = 'JavaScript code is syntactically valid';
    } else if (language.toLowerCase() === 'python') {
      // Basic Python syntax patterns
      const pythonPatterns = [
        /def\s+\w+\s*\([^)]*\)\s*:/,  // Function definition
        /class\s+\w+.*:/,              // Class definition
        /if\s+.*:/,                    // If statement
        /for\s+.*:/,                   // For loop
        /while\s+.*:/                  // While loop
      ];
      
      isValid = pythonPatterns.some(pattern => pattern.test(output)) || 
                output.includes('return') || 
                output.includes('print');
      reason = isValid ? 'Python code appears to be valid' : 'Python code structure not detected';
    } else {
      // Generic code check
      isValid = output.includes('function') || 
                output.includes('def') || 
                output.includes('class') ||
                output.includes('return');
      reason = isValid ? 'Code structure detected' : 'No recognizable code structure found';
    }
  } catch (error) {
    isValid = false;
    reason = `Code validation failed: ${error.message}`;
  }

  return {
    pass: isValid,
    score: isValid ? 1 : 0,
    reason: reason
  };
}

/**
 * Check if the response demonstrates understanding of the context
 */
function demonstratesUnderstanding(output, context) {
  const outputLower = output.toLowerCase();
  const contextWords = context ? context.toLowerCase().split(/\s+/) : [];
  
  // Count how many context words appear in the output
  const matchingWords = contextWords.filter(word => 
    word.length > 3 && outputLower.includes(word)
  );
  
  const understandingScore = contextWords.length > 0 ? 
    matchingWords.length / contextWords.length : 0;
  
  const pass = understandingScore >= 0.3; // At least 30% context words should appear
  
  return {
    pass: pass,
    score: understandingScore,
    reason: pass ? 
      `Response demonstrates understanding (${Math.round(understandingScore * 100)}% context match)` :
      `Response shows limited understanding (${Math.round(understandingScore * 100)}% context match)`
  };
}

/**
 * Check sentiment appropriateness
 */
function appropriateSentiment(output, expectedSentiment = 'neutral') {
  const outputLower = output.toLowerCase();
  
  const sentimentIndicators = {
    positive: ['great', 'excellent', 'wonderful', 'amazing', 'fantastic', 'good', 'happy', 'pleased'],
    negative: ['bad', 'terrible', 'awful', 'horrible', 'disappointing', 'sorry', 'unfortunately', 'problem'],
    neutral: ['however', 'although', 'consider', 'might', 'could', 'perhaps', 'generally']
  };
  
  const detectedSentiments = {};
  
  for (const [sentiment, words] of Object.entries(sentimentIndicators)) {
    detectedSentiments[sentiment] = words.filter(word => outputLower.includes(word)).length;
  }
  
  const dominantSentiment = Object.keys(detectedSentiments).reduce((a, b) => 
    detectedSentiments[a] > detectedSentiments[b] ? a : b
  );
  
  const pass = dominantSentiment === expectedSentiment || detectedSentiments[expectedSentiment] > 0;
  
  return {
    pass: pass,
    score: pass ? 1 : 0.5, // Partial credit if sentiment is reasonable but not exact
    reason: pass ? 
      `Sentiment is appropriate (detected: ${dominantSentiment})` :
      `Sentiment may be inappropriate (expected: ${expectedSentiment}, detected: ${dominantSentiment})`
  };
}

/**
 * Check response length is appropriate
 */
function appropriateLength(output, minWords = 10, maxWords = 200) {
  const wordCount = output.trim().split(/\s+/).length;
  const pass = wordCount >= minWords && wordCount <= maxWords;
  
  return {
    pass: pass,
    score: pass ? 1 : Math.max(0, 1 - Math.abs(wordCount - (minWords + maxWords) / 2) / maxWords),
    reason: pass ? 
      `Response length is appropriate (${wordCount} words)` :
      `Response length is inappropriate (${wordCount} words, expected ${minWords}-${maxWords})`
  };
}

// Export all functions
module.exports = {
  containsValidEmail,
  isValidCode,
  demonstratesUnderstanding,
  appropriateSentiment,
  appropriateLength
};