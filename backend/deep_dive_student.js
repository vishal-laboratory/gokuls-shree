require('dotenv').config();
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function deepDiveStudentPage() {
    console.log('🔬 DEEP DIVE: Student Management Page...\n');

    await syncService.login();

    // Dump complete student page
    console.log('📄 Fetching search_home.php...');
    const $ = await syncService.fetchPage('/search_home.php');
    fs.writeFileSync('student_page.html', $.html());
    console.log('✅ Saved student_page.html');

    // Analyze table structure
    console.log('\n📊 ANALYZING TABLE STRUCTURE:');

    // Find header row
    $('tr').each((i, row) => {
        const tds = $(row).find('td, th');
        if (tds.length > 4 && i < 3) {
            console.log(`\nRow ${i}:`);
            tds.each((j, td) => {
                const text = $(td).text().replace(/\s+/g, ' ').trim().substring(0, 40);
                console.log(`  TD[${j}]: ${text}`);
            });
        }
    });

    // Sample one DATA row with all details
    console.log('\n📋 SAMPLE STUDENT ROW (first data row):');
    let found = false;
    $('tr').each((i, row) => {
        if (found) return;
        const tds = $(row).find('td');
        if (tds.length >= 6) {
            const firstCell = $(tds[0]).text().trim();
            // Skip header
            if (firstCell.includes('REG') || firstCell.includes('SNO')) return;
            // Check if it looks like a reg number
            if (firstCell.length > 5 && firstCell.length < 30) {
                found = true;
                console.log('COLUMNS:');
                tds.each((j, td) => {
                    const text = $(td).text().replace(/\s+/g, ' ').trim().substring(0, 60);
                    const links = $(td).find('a').length;
                    const buttons = $(td).find('button').length;
                    console.log(`  [${j}] "${text}" (links:${links}, buttons:${buttons})`);
                });

                // Check for action buttons/toggles
                console.log('\n🔘 ACTION COLUMN DETAILS:');
                const actionTd = $(tds[5]);
                actionTd.find('a').each((k, a) => {
                    console.log(`  Link: ${$(a).attr('href')?.substring(0, 50) || 'N/A'}`);
                });
            }
        }
    });

    console.log('\n✅ Analysis complete. Check student_page.html for full structure.');
}

deepDiveStudentPage().catch(console.error);
