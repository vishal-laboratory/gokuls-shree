const db = require('./src/config/database');
const fs = require('fs');

async function run() {
    try {
        await db.query(`ALTER TABLE students ADD COLUMN IF NOT EXISTS father_name VARCHAR(255)`);
        fs.writeFileSync('migration_result.txt', 'SUCCESS: Added father_name');
    } catch (e) {
        fs.writeFileSync('migration_result.txt', 'ERROR: ' + e.message);
    }
    process.exit(0);
}
run();
