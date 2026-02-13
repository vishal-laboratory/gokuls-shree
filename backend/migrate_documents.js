/**
 * Migration: Create document_verifications table
 * Stores document IDs for QR verification
 */

require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function migrate() {
    console.log('🔄 Running document verification migration...');

    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS document_verifications (
                id SERIAL PRIMARY KEY,
                document_id VARCHAR(50) UNIQUE NOT NULL,
                document_type VARCHAR(20) NOT NULL,
                reg_no VARCHAR(100) NOT NULL,
                student_name VARCHAR(255),
                issue_date TIMESTAMP,
                metadata JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                signed_at TIMESTAMP,
                signature_hash VARCHAR(256)
            );
            
            CREATE INDEX IF NOT EXISTS idx_doc_ver_reg_no ON document_verifications(reg_no);
            CREATE INDEX IF NOT EXISTS idx_doc_ver_type ON document_verifications(document_type);
        `);

        console.log('✅ Document verification table created successfully!');
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
    } finally {
        await pool.end();
    }
}

migrate();
