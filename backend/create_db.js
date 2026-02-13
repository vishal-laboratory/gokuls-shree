const { Client } = require('pg');
require('dotenv').config({ path: './.env' });

async function createDatabase() {
    // Connect to default 'postgres' database to create new DB
    const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: 'postgres'
    });

    try {
        await client.connect();
        console.log('✅ Connected to Postgres system DB.');

        await client.query(`CREATE DATABASE ${process.env.DB_NAME}`);
        console.log(`✅ Database ${process.env.DB_NAME} created successfully!`);
    } catch (e) {
        if (e.code === '42P04') {
            console.log(`ℹ️ Database ${process.env.DB_NAME} already exists.`);
        } else {
            console.error('❌ Error creating database:', e.message);
        }
    } finally {
        await client.end();
    }
}

createDatabase();
