const { spawn } = require('child_process');
const fs = require('fs');

// Log start
fs.writeFileSync('/wrapper.log', 'Starting wrapper\n');

// Spawn the installed n8n-mcp directly to avoid npx download/warnings
// Spawn the installed n8n-mcp directly (CORRECT PATH)
const child = spawn('/usr/bin/node', ['/usr/local/lib/node_modules/n8n-mcp/dist/mcp/index.js'], {
    stdio: ['inherit', 'pipe', 'pipe'],
    shell: false
});

let buffer = '';

child.stdout.on('data', (data) => {
    fs.appendFileSync('/wrapper.log', 'RAW STDOUT: ' + data.toString() + '\n');
    buffer += data.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop(); // Keep partial line

    lines.forEach(line => {
        const trimmed = line.trim();
        // Allow JSON-RPC (object/batch), Headers (Content-Length), and empty lines (protocol separators)
        if (trimmed.length === 0 || trimmed.startsWith('{') || trimmed.startsWith('[{') || trimmed.startsWith('Content-Length')) {
            process.stdout.write(line + '\n');
        } else {
            // Redirect logs to stderr
            process.stderr.write(`[FILTERED] ${line}\n`);
            fs.appendFileSync('/wrapper.log', 'FILTERED: ' + line + '\n');
        }
    });
});

child.stderr.on('data', (data) => {
    fs.appendFileSync('/wrapper.log', 'RAW STDERR: ' + data.toString() + '\n');
    process.stderr.write(data);
});

child.on('close', (code) => {
    process.exit(code);
});

// Handle termination signals
process.on('SIGINT', () => child.kill('SIGINT'));
process.on('SIGTERM', () => child.kill('SIGTERM'));
