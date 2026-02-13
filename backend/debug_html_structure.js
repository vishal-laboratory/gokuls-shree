require('dotenv').config({ path: './.env' });
require('dotenv').config({ path: '../.env' });
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function debugHtml() {
    console.log('🔄 Logging in...');
    await syncService.login();

    // 7. Marksheet HTML
    console.log('📄 Fetching Marksheet HTML...');
    const $marks = await syncService.fetchPage('/marksheet_list.php');
    fs.writeFileSync('marksheet.html', $marks('body').html());

    console.log('✅ HTML dumps saved.');
}

debugHtml();
