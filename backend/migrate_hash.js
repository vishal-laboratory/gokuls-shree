/**
 * Migration: Add file_hash to document_verifications
 */

require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function migrate() {
    console.log('🔄 Adding file_hash column...');

    try {
        await pool.query(`
            ALTER TABLE document_verifications 
            ADD COLUMN IF NOT EXISTS file_hash VARCHAR(64);
        `);

        console.log('✅ Migration successful!');
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
    } finally {
        await pool.end();
    }
}

migrate();
