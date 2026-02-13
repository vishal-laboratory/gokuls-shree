require('dotenv').config();
const syncService = require('./src/services/sync.service');
const cheerio = require('cheerio');

async function findAllPaginationLinks() {
    console.log('🔍 Finding ALL pagination links...\n');

    await syncService.login();

    const $ = await syncService.fetchPage('/search_home.php');

    console.log('Links with "start=":');
    $('a[href*="start="]').each((i, el) => {
        const href = $(el).attr('href');
        const text = $(el).text().trim();
        console.log(`  ${text}: ${href}`);
    });

    console.log('\nLinks with "page=":');
    $('a[href*="page="]').each((i, el) => {
        const href = $(el).attr('href');
        const text = $(el).text().trim();
        console.log(`  ${text}: ${href}`);
    });

    // Try to find total count
    console.log('\nLooking for total count...');
    const bodyText = $('body').text();
    const totalMatch = bodyText.match(/Total\s*:\s*(\d+)/i) || bodyText.match(/(\d+)\s*students?/i);
    if (totalMatch) {
        console.log(`Found total: ${totalMatch[0]}`);
    }

    process.exit(0);
}

findAllPaginationLinks().catch(console.error);
