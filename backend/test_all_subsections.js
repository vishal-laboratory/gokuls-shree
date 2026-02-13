require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function testAllSubsections() {
    console.log('🧪 Testing ALL Subsection Scrapers...\n');

    await syncService.login();

    console.log('\n=== STAFF/EMP SUBSECTIONS ===');
    await syncService.getEmployeeDepartments();
    await syncService.getAttendanceReport();
    await syncService.getAdvanceReport();
    await syncService.getStaff();

    console.log('\n=== ONLINE EXAM SUBSECTIONS ===');
    await syncService.getPaperSets();
    await syncService.getQuestions();
    await syncService.getOnlineExamResults();
    await syncService.getAdmitCards();

    console.log('\n=== REPORT SUBSECTIONS ===');
    await syncService.getStudentReport();
    await syncService.getFeeReports();
    await syncService.getDuesReports();
    await syncService.getBalanceSheet();

    console.log('\n=== STUDY MATERIALS SUBSECTIONS ===');
    await syncService.getSyllabus();
    await syncService.getStudyMaterials();
    await syncService.getVideoClasses();

    console.log('\n=== MARKSHEET/CERTIFICATE ===');
    await syncService.getMarksheets();

    console.log('\n=== STUDENT DETAILS (Enhanced) ===');
    const students = await syncService.getStudents();
    console.log(`Total students scraped: ${students.length}`);

    console.log('\n✅ ALL SUBSECTION SCRAPERS TESTED!');
    process.exit(0);
}

testAllSubsections().catch(console.error);
