require('dotenv').config({ path: './.env' });
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function run() {
    try {
        const result = await syncService.login();
        fs.writeFileSync('login_result.txt', result ? 'SUCCESS: Logged In' : 'FAILED: Login returned false');
    } catch (e) {
        fs.writeFileSync('login_result.txt', 'ERROR: ' + e.message);
    }
}
run();
