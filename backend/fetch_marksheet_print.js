require('dotenv').config();
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function fetchMarksheetPrint() {
    console.log('🔍 Fetching Marksheet Print Page...\n');

    await syncService.login();

    // Fetch marksheet print page (with subjects table)
    const printUrl = '/marksheet_print.php?regsno=GO100110020241750126';
    console.log(`📄 Fetching: ${printUrl}`);

    const $ = await syncService.fetchPage(printUrl);
    const html = $.html();

    // Save to file
    fs.writeFileSync('marksheet_print_actual.html', html);
    console.log('✅ Saved to marksheet_print_actual.html');

    // Extract structure
    console.log('\n📋 Marksheet Print Structure:');
    console.log(`   Title: ${$('title').text()}`);
    console.log(`   Images: ${$('img').length}`);
    console.log(`   Tables: ${$('table').length}`);

    // Check for subject table
    console.log('\n📊 Looking for subject marks table...');
    $('table').each((i, table) => {
        const rows = $(table).find('tr').length;
        const ths = $(table).find('th').length;
        console.log(`   Table ${i + 1}: ${rows} rows, ${ths} headers`);
    });

    console.log('\n✅ Done!');
    process.exit(0);
}

fetchMarksheetPrint().catch(console.error);
