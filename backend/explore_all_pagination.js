require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function explorePaginationAllPages() {
    console.log('🔍 Exploring pagination on ALL data pages...\n');

    await syncService.login();

    const pagesToCheck = [
        { name: 'Fee Reports', url: '/membersfee.php' },
        { name: 'Marksheets', url: '/marksheet_list.php' },
        { name: 'Admit Cards', url: '/admitcard_list.php' },
        { name: 'Exam Questions', url: '/product_list.php' },
        { name: 'Exam Results', url: '/result.php' },
        { name: 'Paper Sets', url: '/paper_list.php' },
        { name: 'Staff', url: '/emp.php' },
        { name: 'Courses', url: '/courses.php' },
        { name: 'Study Materials', url: '/download.php' },
    ];

    for (const page of pagesToCheck) {
        console.log(`\n📄 ${page.name} (${page.url})`);
        try {
            const $ = await syncService.fetchPage(page.url);

            // Count data rows
            let rowCount = 0;
            $('tr').each((i, el) => {
                const tds = $(el).find('td');
                if (tds.length >= 3) rowCount++;
            });

            // Check for pagination links
            const startLinks = [];
            $('a[href*="start="]').each((i, el) => {
                const href = $(el).attr('href');
                const text = $(el).text().trim();
                if (!startLinks.includes(href)) startLinks.push({ text, href });
            });

            const pageLinks = [];
            $('a[href*="page="]').each((i, el) => {
                const href = $(el).attr('href');
                const text = $(el).text().trim();
                if (!pageLinks.includes(href)) pageLinks.push({ text, href });
            });

            console.log(`   Rows on page: ${rowCount}`);
            console.log(`   start= links: ${startLinks.length}`);
            if (startLinks.length > 0) {
                startLinks.slice(0, 5).forEach(l => console.log(`      ${l.text}: ${l.href}`));
            }
            console.log(`   page= links: ${pageLinks.length}`);

        } catch (e) {
            console.log(`   Error: ${e.message}`);
        }
    }

    console.log('\n✅ Pagination exploration complete');
    process.exit(0);
}

explorePaginationAllPages().catch(console.error);
