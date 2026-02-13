require('dotenv').config();
const syncService = require('./src/services/sync.service');
const fs = require('fs');
const cheerio = require('cheerio');

async function debugDashboard() {
    console.log('🔄 Logging in...');
    await syncService.login();

    console.log('📄 Fetching Dashboard from /new/dashboard.php ...');
    // Note: The user image showed "Dashboard". Usually index.php redirects here.
    // We'll try to fetch the page content using the client directly if exposed, 
    // or add a method to syncService to dump HTML.

    // We'll borrow the client from syncService temporarily or add a raw fetch method
    try {
        const response = await syncService.client.get('/dashboard.php');
        const $ = cheerio.load(response.data);

        let output = '--- DASHBOARD WIDGETS ---\\n';
        // Try to find common widget classes like .card, .box, .stat, .info-box
        $('.card, .box, .info-box, .widget').each((i, el) => {
            output += `Widget: ${$(el).text().replace(/\s\s+/g, ' ').trim()}\n`;
        });

        // Also dump links to see navigation
        output += '\n--- NAVIGATION ---\n';
        $('.sidebar-menu a').each((i, el) => {
            output += `Link: ${$(el).text().trim()} -> ${$(el).attr('href')}\n`;
        });

        fs.writeFileSync('dashboard_debug.txt', output);
        console.log('✅ Generic widget text saved to dashboard_debug.txt');
    } catch (e) {
        console.error('❌ Error:', e.message);
    }
}

debugDashboard();
