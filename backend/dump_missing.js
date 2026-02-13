require('dotenv').config();
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function dumpMissingPages() {
    console.log('📥 Dumping HTML for missing modules...\n');

    await syncService.login();

    const pagesToDump = [
        { name: 'users', endpoint: '/user_list.php' },
        { name: 'video_classes', endpoint: '/video.php' },
        { name: 'youtube_live', endpoint: '/youtube_live_class.php' },
        { name: 'zoom_live', endpoint: '/zoom_live_class.php' },
        { name: 'income_head', endpoint: '/income_head.php' },
        { name: 'incomes', endpoint: '/cashin.php?institute=0' },
        { name: 'expense_head', endpoint: '/head.php' },
        { name: 'expenses', endpoint: '/cashout.php?institute=0' },
        { name: 'suggestions', endpoint: '/suggestions.php' }
    ];

    for (const page of pagesToDump) {
        console.log(`📄 Fetching ${page.name}...`);
        try {
            const $ = await syncService.fetchPage(page.endpoint);
            const html = $.html();
            fs.writeFileSync(`${page.name}.html`, html);
            console.log(`✅ Saved ${page.name}.html (${html.length} bytes)`);
        } catch (e) {
            console.error(`❌ Error fetching ${page.name}: ${e.message}`);
        }
    }

    console.log('\n✅ Done! Check the .html files for structure analysis.');
}

dumpMissingPages().catch(console.error);
