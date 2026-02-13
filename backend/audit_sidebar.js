require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function auditSidebar() {
    console.log('🔍 AUDITING ADMIN SIDEBAR MENU...\n');

    await syncService.login();
    const $ = await syncService.fetchPage('/dashboard.php');

    console.log('--- ALL SIDEBAR LINKS ---\n');

    const links = new Map();
    $('a').each((i, el) => {
        const href = $(el).attr('href');
        const text = $(el).text().replace(/\s+/g, ' ').trim();

        if (href && href.includes('.php') && text && text.length < 50) {
            if (!links.has(href)) {
                links.set(href, text);
            }
        }
    });

    // Print unique links
    links.forEach((text, href) => {
        console.log(`📌 [${text}] => ${href}`);
    });

    console.log(`\n✅ Found ${links.size} unique PHP links`);
}

auditSidebar().catch(console.error);
