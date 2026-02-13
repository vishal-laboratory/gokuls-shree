require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const axios = require('axios');
const cheerio = require('cheerio');
const { CookieJar } = require('tough-cookie');
const { wrapper } = require('axios-cookiejar-support');

// ==========================================
// CONFIGURATION
// ==========================================
const BASE_URL = 'https://www.gokulshreeschool.com/new'; // From sync.service.js
const LOGIN_URL = `${BASE_URL}/login.php`;
const STUDENT_LIST_URL = `${BASE_URL}/search_home.php`; // Confirmed page for student list

// Supabase
const supabaseUrl = process.env.SUPABASE_URL || 'https://rxjmdrjlsltqufrpvdyq.supabase.co';
let supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Admin Credentials
const ADMIN_USER = process.env.PHP_ADMIN_USER;
const ADMIN_PASS = process.env.PHP_ADMIN_PASSWORD;

// ==========================================
// SCRAPER CLIENT
// ==========================================
const jar = new CookieJar();
const client = wrapper(axios.create({
    baseURL: BASE_URL,
    jar,
    withCredentials: true,
    headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Content-Type': 'application/x-www-form-urlencoded'
    }
}));

// ==========================================
// MAIN EXECUTION
// ==========================================
async function main() {
    console.log('🚀 Starting Sync Engine: Admin Panel Scraping -> Supabase');
    console.log('-------------------------------------------------------');

    if (!supabaseKey) {
        console.error('❌ Error: Service Role Key is missing in .env');
        process.exit(1);
    }

    if (!ADMIN_USER || !ADMIN_PASS) {
        console.error('❌ Error: PHP_ADMIN_USER or PHP_ADMIN_PASSWORD missing in .env');
        process.exit(1);
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
        auth: { autoRefreshToken: false, persistSession: false }
    });

    try {
        await testSupabaseConnection(supabase);

        // 1. Login to Admin Panel
        const isLoggedIn = await loginToAdminPanel();
        if (!isLoggedIn) throw new Error('Failed to log in to Admin Panel');

        // 2. Scrape Students
        const students = await scrapeStudents();
        console.log(`✅ Extracted ${students.length} students from Admin Panel`);

        // 3. Sync to Supabase
        await syncStudentsToSupabase(supabase, students);

        console.log('\n✅ Sync process completed successfully!');
    } catch (err) {
        console.error('\n❌ Sync failed:', err.message);
    } finally {
        process.exit(0);
    }
}

// ==========================================
// SCRAPING FUNCTIONS
// ==========================================

async function loginToAdminPanel() {
    console.log('🔄 Logging in to Admin Panel...');
    try {
        // Init session
        console.log(`   GET ${BASE_URL}/index.php`);
        await client.get('/index.php');

        const params = new URLSearchParams();
        params.append('loginid', ADMIN_USER);
        params.append('password', ADMIN_PASS);
        params.append('Submit2', 'Login');

        console.log(`   POST ${BASE_URL}/login.php`);
        const response = await client.post('/login.php', params);

        console.log(`   Response URL: ${response.request.res.responseUrl}`);
        if (response.request.res.responseUrl.includes('dashboard.php')) {
            console.log('✅ Login Successful');
            return true;
        } else {
            console.error('❌ Login Failed. Still on login page or redirected elsewhere.');
            // console.log('   Response HTML:', response.data.substring(0, 500)); 
            return false;
        }
    } catch (e) {
        console.error('❌ Login Error:', e.message);
        return false;
    }
}

async function scrapeStudents() {
    console.log('🔄 Scraping Student List...');
    const students = [];

    try {
        console.log(`   GET ${BASE_URL}/search_home.php`);
        const response = await client.get('/search_home.php');
        const $ = cheerio.load(response.data);
        console.log('   Page Loaded. Parsing table...');

        // Debug: Dump headers
        // $('table tr').first().find('td').each((i, el) => console.log(`   Header ${i}: ${$(el).text().trim()}`));

        // Iterate Table Rows
        $('table tr').each((i, el) => {
            const tds = $(el).find('td');
            if (tds.length < 5) return; // Skip invalid rows

            const col1 = $(tds[1]).text().trim(); // REG & PASS column
            if (col1.includes('REG')) return; // Header

            // Extract Reg No
            let regNo = $(tds[1]).find('strong').first().text().trim();
            if (!regNo) regNo = col1.split(' ')[0]; // Fallback

            // Extract Name
            const name = $(tds[2]).text().trim();

            // Extract Phone
            const contactText = $(tds[4]).text().trim();
            const phoneMatch = contactText.match(/(\d{10})/);
            const phone = phoneMatch ? phoneMatch[1] : '';

            // Extract Password (Critical!)
            let password = 'password123'; // Default fallback
            // Try to find password in the cell text
            if (col1.toLowerCase().includes('pass')) {
                const parts = col1.split(/pass/i);
                if (parts[1]) password = parts[1].replace(/[:\-\s]/g, '').trim();
            }

            if (regNo && regNo.length > 5) {
                students.push({
                    regNo,
                    name,
                    phone,
                    password,
                    course: $(tds[3]).text().trim()
                });
            }
        });

        return students;
    } catch (e) {
        throw new Error(`Scraping failed: ${e.message}`);
    }
}

// ==========================================
// SYNC FUNCTIONS
// ==========================================

async function syncStudentsToSupabase(supabase, students) {
    if (students.length === 0) {
        console.log('⚠️  No students found to sync.');
        return;
    }

    console.log(`\n👨‍🎓 Syncing ${students.length} students to Supabase...`);

    let success = 0;
    let fail = 0;

    for (const s of students) {
        const email = `${s.regNo.toLowerCase()}@gokulshree.com`;
        const password = s.password || 'welcome123';

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
                    user_metadata: { name: s.name, reg_no: s.regNo }
                });
                if (createError) throw createError;
                userId = newUser.user.id;
            }

            // B. Upsert Student Record (Postgres Data)
            // Need to ensure courses/batches exist or just store string?
            // Storing string in 'batch' column for now.

            const payload = {
                user_id: userId,
                reg_no: s.regNo,
                full_name: s.name,
                contact_mobile: s.phone,
                email: email,
                batch: s.course
            };

            const { error } = await supabase.from('students').upsert(payload, { onConflict: 'reg_no' });
            if (error) throw error;

            success++;
            if (success % 10 === 0) process.stdout.write('.');

        } catch (e) {
            // console.error(`Failed ${s.regNo}: ${e.message}`);
            fail++;
        }
    }
    console.log(`\n   Result: ${success} synced, ${fail} failed`);
}

async function testSupabaseConnection(supabase) {
    const { data, error } = await supabase.from('profiles').select('count', { count: 'exact', head: true });
    if (error) throw new Error(`Supabase Connection Failed: ${error.message}`);
    console.log('✅ Supabase Connected');
}

main().catch(console.error);
