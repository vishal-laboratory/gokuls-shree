require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function explorePagination() {
    console.log('🔍 Exploring pagination on student page...\n');

    await syncService.login();

    // Try different URL patterns
    const testUrls = [
        '/search_home.php',
        '/search_home.php?page=2',
        '/search_home.php?start=50',
        '/search_home.php?limit=500',
        '/members.php',  // Student report page might have all
        '/members.php?page=1',
        '/members.php?page=2',
    ];

    for (const url of testUrls) {
        console.log(`\n📄 Testing: ${url}`);
        try {
            const $ = await syncService.fetchPage(url);

            // Count student rows
            let count = 0;
            $('tr').each((i, el) => {
                const text = $(el).find('td').first().text().trim();
                if (text.match(/^GO\d+|^GOKUL\d+/) && text.length > 5) {
                    count++;
                }
            });

            console.log(`   Found ${count} student-like rows`);

            // Check for pagination links
            const pageLinks = $('a[href*="page="]').length;
            const startLinks = $('a[href*="start="]').length;
            console.log(`   Pagination links: page=${pageLinks}, start=${startLinks}`);

        } catch (e) {
            console.log(`   Error: ${e.message}`);
        }
    }

    console.log('\n✅ Pagination exploration complete');
    process.exit(0);
}

explorePagination().catch(console.error);
