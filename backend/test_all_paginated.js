require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function testAllPaginatedScrapers() {
    console.log('🧪 Testing ALL Paginated Scrapers...\n');
    console.log('='.repeat(50));

    await syncService.login();

    console.log('\n📊 STUDENTS:');
    const students = await syncService.getStudents();

    console.log('\n📊 MARKSHEETS:');
    const marksheets = await syncService.getMarksheets();

    console.log('\n📊 PAPER SETS:');
    const papers = await syncService.getPaperSets();

    console.log('\n📊 FEE REPORTS:');
    const fees = await syncService.getFeeReports();

    console.log('\n📊 ADMIT CARDS:');
    const admitCards = await syncService.getAdmitCards();

    console.log('\n📊 EXAM QUESTIONS:');
    const questions = await syncService.getQuestions();

    console.log('\n📊 EXAM RESULTS:');
    const results = await syncService.getOnlineExamResults();

    console.log('\n📊 COURSES:');
    const courses = await syncService.getCourses();

    console.log('\n' + '='.repeat(50));
    console.log('📈 FINAL TOTALS:');
    console.log(`   Students:     ${students.length}`);
    console.log(`   Marksheets:   ${marksheets.length}`);
    console.log(`   Paper Sets:   ${papers.length}`);
    console.log(`   Fee Records:  ${fees.length}`);
    console.log(`   Admit Cards:  ${admitCards.length}`);
    console.log(`   Questions:    ${questions.length}`);
    console.log(`   Exam Results: ${results.length}`);
    console.log(`   Courses:      ${courses.length}`);
    console.log('='.repeat(50));

    console.log('\n✅ ALL SCRAPERS TESTED!');
    process.exit(0);
}

testAllPaginatedScrapers().catch(console.error);
