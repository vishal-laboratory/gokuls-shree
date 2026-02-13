require('dotenv').config();
const syncService = require('./src/services/sync.service');

async function testNewMethods() {
    console.log('🧪 Testing ALL new scraper methods...\n');

    await syncService.login();

    // Test all new methods
    await syncService.getUsers();
    await syncService.getVideoClasses();
    await syncService.getYoutubeLiveClasses();
    await syncService.getZoomLiveClasses();
    await syncService.getIncomeHeads();
    await syncService.getIncomes();
    await syncService.getExpenseHeads();
    await syncService.getExpenses();
    await syncService.getSuggestions();

    console.log('\n✅ All new methods tested successfully!');
}

testNewMethods().catch(console.error);
