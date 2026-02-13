const { Client } = require('pg');
require('dotenv').config({ path: './.env' });

async function testPort(port) {
    console.log(`Testing connection on port ${port}...`);
    const client = new Client({
        host: 'localhost',
        port: port,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        connectionTimeoutMillis: 2000
    });

    try {
        await client.connect();
        console.log(`✅ SUCCESS! Postgres is running on port ${port}`);
        await client.end();
        return true;
    } catch (e) {
        console.log(`❌ Failed on port ${port}: ${e.message}`);
        return false;
    }
}

async function run() {
    const ports = [5432, 5441, 5439, 5018];
    for (const p of ports) {
        if (await testPort(p)) process.exit(0);
    }
    console.log('❌ Could not connect on any candidate port.');
    process.exit(1);
}

run();
