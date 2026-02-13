require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function testEnhancedStudents() {
    console.log('🧪 Testing ENHANCED Student Scraper...\n');

    await syncService.login();
    const students = await syncService.getStudents();

    console.log('\n📊 SAMPLE STUDENT DATA (first 3):');
    students.slice(0, 3).forEach((s, i) => {
        console.log(`\n--- Student ${i + 1} ---`);
        console.log(`RegNo: ${s.regNo}`);
        console.log(`Password: ${s.password}`);
        console.log(`Name: ${s.name}`);
        console.log(`Course: ${s.course}`);
        console.log(`Contact: ${s.contact}`);
        console.log(`Fee Status: ${s.feeStatus} (Due: ₹${s.dueAmount})`);
        console.log(`Net Fee: ₹${s.netFee}`);
        console.log(`Father: ${s.fatherName}`);
        console.log(`DOJ: ${s.doj}`);
        console.log(`Batch: ${s.batch}`);
        console.log(`Address: ${s.address}`);
        console.log(`Updated By: ${s.updatedBy}`);
    });

    console.log('\n✅ Test complete!');
    process.exit(0);
}

testEnhancedStudents().catch(console.error);
