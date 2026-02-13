require('dotenv').config();
const db = require('./src/config/database');

async function migrateStudents() {
    console.log('🔄 Migrating students table for enhanced fields...\n');

    const alterQueries = [
        // Add new columns for enhanced student data
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS reg_no VARCHAR(50)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS password VARCHAR(100)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS course VARCHAR(255)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS fee_status VARCHAR(20) DEFAULT 'DUE'`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS due_amount INTEGER DEFAULT 0`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS net_fee INTEGER DEFAULT 0`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS father_name VARCHAR(255)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS doj VARCHAR(50)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS batch VARCHAR(100)`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS address TEXT`,
        `ALTER TABLE students ADD COLUMN IF NOT EXISTS updated_by VARCHAR(255)`,
        // Add unique constraint on reg_no if not exists
        `CREATE UNIQUE INDEX IF NOT EXISTS students_reg_no_idx ON students(reg_no)`
    ];

    for (const query of alterQueries) {
        try {
            await db.query(query);
            console.log('✅', query.substring(0, 60) + '...');
        } catch (e) {
            console.log('⚠️ ', e.message.substring(0, 60));
        }
    }

    console.log('\n✅ Migration complete!');
    process.exit(0);
}

migrateStudents().catch(console.error);
