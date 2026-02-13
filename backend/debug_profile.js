require('dotenv').config({ path: './.env' });
require('dotenv').config({ path: '../.env' });
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function debugProfile() {
    await syncService.login();
    const $ = await syncService.fetchPage('/profile.php');

    // Dump all text to see what's on the page
    fs.writeFileSync('profile_debug.txt', $.text());

    // Also dump form html
    fs.writeFileSync('profile_html.txt', $('body').html());
    console.log('✅ Dumps saved to profile_debug.txt and profile_html.txt');
}

debugProfile();
