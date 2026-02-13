require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

async function checkTables() {
    try {
        console.log(`Connecting to ${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}...`);
        const res = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        `);

        console.log('\n📊 Tables in local database:');
        console.log('-----------------------------');
        const fs = require('fs');
        const list = res.rows.map(r => r.table_name).join('\n');
        fs.writeFileSync('tables_list.txt', list);
        console.log('✅ Tables list written to tables_list.txt');

        // Log to console as well for good measure
        console.log(list);

    } catch (err) {
        console.error('❌ Error connecting to database:', err.message);
    } finally {
        await pool.end();
    }
}

checkTables();
