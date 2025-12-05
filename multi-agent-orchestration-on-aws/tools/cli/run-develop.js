#!/usr/bin/env node

/**
 * Wrapper script for npm run develop
 * Ensures TypeScript CLI is always run with latest changes
 * Clears any caches and runs with tsx
 */

const { execSync } = require('child_process');
const path = require('path');

// Clear tsx cache to ensure fresh execution
const cacheDir = path.join(require('os').homedir(), '.tsx');
try {
    const fs = require('fs');
    if (fs.existsSync(cacheDir)) {
        fs.rmSync(cacheDir, { recursive: true, force: true });
    }
} catch (error) {
    // Ignore cache clear errors
}

// Run tsx with the develop.ts file
const developPath = path.join(__dirname, 'develop.ts');

try {
    execSync(`npx tsx "${developPath}"`, {
        stdio: 'inherit',
        cwd: path.join(__dirname, '..', '..')
    });
} catch (error) {
    process.exit(error.status || 1);
}
