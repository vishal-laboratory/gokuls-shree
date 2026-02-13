require('dotenv').config();
const syncService = require('./src/services/sync.service');
const fs = require('fs');

async function fetchMarksheetSample() {
    console.log('🔍 Fetching Marksheet Sample...\n');

    await syncService.login();

    // Get marksheets
    const marksheets = await syncService.getMarksheets();

    console.log('\n📋 Sample Marksheet Data (First 2):');
    marksheets.slice(0, 2).forEach((m, i) => {
        console.log(`\n--- Marksheet ${i + 1} ---`);
        console.log(`RegNo: ${m.regNo}`);
        console.log(`Student: ${m.studentName}`);
        console.log(`Course: ${m.course}`);
        console.log(`Session: ${m.session}`);
        console.log(`Issue Date: ${m.issueDate}`);
        console.log(`Marksheet No: ${m.marksheetNo}`);
        console.log(`Certificate No: ${m.certificateNo}`);
        console.log(`Subjects (${m.subjects?.length || 0}):`);
        m.subjects?.forEach(s => {
            console.log(`   - ${s.subject}: ${s.marks}`);
        });
    });

    // Now let's check the actual print page format
    console.log('\n\n🖨️ Checking Print Page Format...');

    // Fetch the marksheet print page
    const $ = await syncService.fetchPage('/marksheet_list.php');

    // Look for print links
    const printLinks = [];
    $('a[href*="print"]').each((i, el) => {
        const href = $(el).attr('href');
        if (!printLinks.includes(href)) printLinks.push(href);
    });

    console.log(`Found ${printLinks.length} print links:`);
    printLinks.slice(0, 5).forEach(l => console.log(`   ${l}`));

    // Fetch a sample print page
    if (printLinks.length > 0) {
        const printUrl = printLinks[0];
        console.log(`\n📄 Fetching print page: ${printUrl}`);

        try {
            const print$ = await syncService.fetchPage(printUrl);
            const html = print$.html();

            // Save to file for analysis
            fs.writeFileSync('marksheet_print.html', html);
            console.log('✅ Saved print page to marksheet_print.html');

            // Extract key elements
            console.log('\n📋 Print Page Structure:');
            console.log(`   Title: ${print$('title').text()}`);
            console.log(`   Has logo: ${print$('img').length > 0}`);
            console.log(`   Tables: ${print$('table').length}`);
            console.log(`   Body classes: ${print$('body').attr('class') || 'none'}`);
        } catch (e) {
            console.log(`   Error: ${e.message}`);
        }
    }

    console.log('\n✅ Analysis complete!');
    process.exit(0);
}

fetchMarksheetSample().catch(console.error);
