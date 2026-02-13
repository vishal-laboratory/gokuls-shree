require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const { Pool } = require('pg');

// ==========================================
// CONFIGURATION
// ==========================================
// Local DB (Source)
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

// Remote DB (Destination)
const supabaseUrl = process.env.SUPABASE_URL || 'https://rxjmdrjlsltqufrpvdyq.supabase.co';
let supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// ==========================================
// MAIN EXECUTION
// ==========================================
async function main() {
    console.log('🚀 Starting Sync Engine: Local DB -> Supabase');
    console.log('---------------------------------------------');

    if (!supabaseKey) {
        console.error('❌ Error: Service Role Key is missing in .env');
        process.exit(1);
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
        auth: {
            autoRefreshToken: false,
            persistSession: false
        }
    });

    try {
        // Test Connections
        await testConnections(supabase);

        // Sync Steps
        await syncBranches(supabase);
        await syncStudents(supabase);

        console.log('\n✅ Sync process completed successfully!');
    } catch (err) {
        console.error('\n❌ Sync failed:', err.message);
    } finally {
        await pool.end();
        process.exit(0);
    }
}

// ==========================================
// SYNC FUNCTIONS
// ==========================================

async function syncBranches(supabase) {
    console.log('\n🏢 Syncing Branches...');

    // 1. Fetch from Local
    const res = await pool.query('SELECT * FROM franchises');
    const branches = res.rows;
    console.log(`   Found ${branches.length} branches in local DB`);

    if (branches.length === 0) return;

    let success = 0;
    let fail = 0;

    for (const b of branches) {
        try {
            const payload = {
                id: b.id, // Keep ID
                code: b.code,
                name: b.name,
                owner_name: b.owner_name,
                contact_phone: b.contact_phone,
                contact_email: b.contact_email,
                address: b.address,
                city: b.city,
                district: b.district,
                state: b.state,
                pincode: b.pincode,
                is_active: b.is_active,
            };

            const { error } = await supabase.from('branches').upsert(payload);
            if (error) throw error;
            success++;
        } catch (e) {
            console.error(`   ❌ Failed branch ${b.code}:`, e.message);
            fail++;
        }
    }
    console.log(`   Result: ${success} synced, ${fail} failed`);
}

async function syncStudents(supabase) {
    console.log('\n👨‍🎓 Syncing Students & Auth Users...');

    // 1. Fetch from Local
    const res = await pool.query('SELECT * FROM students');
    const students = res.rows;
    console.log(`   Found ${students.length} students in local DB`);

    let success = 0;
    let fail = 0;
    let skipped = 0;

    for (const s of students) {
        // Validation: reg_no is mandatory
        if (!s.reg_no || !s.password) {
            // console.log(`   ⚠️  Skipping ID ${s.id}: No reg_no/password`);
            skipped++;
            continue;
        }

        const email = s.email || `${s.reg_no.toLowerCase()}@gokulshree.com`;
        const password = s.password;

        try {
            // A. Create/Get Auth User
            let userId = null;
            const { data: { users } } = await supabase.auth.admin.listUsers();
            const existingUser = users.find(u => u.email === email);

            if (existingUser) {
                userId = existingUser.id;
            } else {
                const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
                    email: email,
                    password: password,
                    email_confirm: true,
                    user_metadata: { name: s.name, reg_no: s.reg_no }
                });

                if (createError) throw createError;
                userId = newUser.user.id;
            }

            // B. Upsert Student Record
            let dob = null;
            if (s.dob && s.dob !== '0000-00-00') dob = s.dob;

            const payload = {
                user_id: userId,
                reg_no: s.reg_no,
                full_name: s.name,
                father_name: s.father_name,
                mother_name: s.mother_name,
                dob: dob,
                gender: s.gender,
                category: s.category,
                contact_mobile: s.mobile || s.phone,
                email: email,
                permanent_address: s.address,
                batch: s.batch,
                legacy_id: s.id
            };

            const { data: existingStudent } = await supabase
                .from('students')
                .select('id')
                .eq('reg_no', s.reg_no)
                .maybeSingle();

            if (existingStudent) {
                await supabase.from('students').update(payload).eq('id', existingStudent.id);
            } else {
                await supabase.from('students').insert(payload);
            }

            success++;
            if (success % 10 === 0) process.stdout.write('.');

        } catch (e) {
            console.error(`\n   ❌ Failed ${s.reg_no}:`, e.message);
            fail++;
        }
    }
    console.log(`\n   Result: ${success} synced, ${fail} failed, ${skipped} skipped`);
}

async function testConnections(supabase) {
    // 1. Local
    const localRes = await pool.query('SELECT NOW()');
    console.log('✅ Local DB Connected:', localRes.rows[0].now);

    // 2. Remote
    const { data, error } = await supabase.from('profiles').select('count', { count: 'exact', head: true });
    if (error) throw new Error(`Supabase Connection Failed: ${error.message}`);
    console.log('✅ Supabase Connected');
}

main().catch(console.error);
