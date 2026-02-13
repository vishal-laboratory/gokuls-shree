require('dotenv').config({ path: './.env' });
require('dotenv').config({ path: '../.env' });
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function debugHtml() {
    console.log('🔄 Logging in...');
    const loggedIn = await syncService.login();
    if (!loggedIn) { console.error('Login Failed'); process.exit(1); }

    const pages = [
        { url: '/branchfee.php', file: 'branchfee.html' },
        { url: '/membersfee.php', file: 'fee_report.html' },
        { url: '/next-installment-date-report.php', file: 'dues_report.html' },
        { url: '/both_report.php', file: 'balance_sheet.html' },

        { url: '/department.php', file: 'program.html' },
        { url: '/subject.php', file: 'subject.html' },

        { url: '/module.php', file: 'syllabus.html' },
        { url: '/download.php', file: 'study_material.html' },

        { url: '/admitcard_list.php', file: 'admit_card.html' },
        { url: '/result.php', file: 'results.html' },

        { url: '/paper_list.php', file: 'papers.html' },
        { url: '/product_list.php', file: 'questions.html' },

        // CMS Pages
        { url: '/page_list.php?country=0', file: 'pages.html' },
        { url: '/banner_list.php?type=1', file: 'banners.html' },
        { url: '/photo_list.php?country=0', file: 'photos.html' },
        { url: '/video_list.php?country=0', file: 'videos.html' },
        { url: '/news_list.php?country=0', file: 'news.html' }
    ];

    for (const p of pages) {
        console.log(`📄 Fetching ${p.url}...`);
        try {
            const $ = await syncService.fetchPage(p.url);
            fs.writeFileSync(p.file, $('body').html());
        } catch (e) {
            console.error(`❌ Failed ${p.url}: ${e.message}`);
        }
    }

    console.log('✅ All dumps saved.');
}

debugHtml();
