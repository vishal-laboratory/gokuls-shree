require('dotenv').config({ path: './.env' });
require('dotenv').config({ path: '../.env' });
const syncService = require('./src/services/sync.service');

async function testSync() {
    console.log('🧪 Starting Sync Test (Dashboard, Site, Branch, Students)...');

    const loggedIn = await syncService.login();
    if (!loggedIn) process.exit(1);

    await syncService.getSiteSettings();
    await syncService.getBranches();
    // await syncService.getStaff();
    // await syncService.getCourses();
    // await syncService.getMarksheets();
    const fees = await syncService.getFeeReports();
    await syncService.saveFeeReports(fees);

    const wallet = await syncService.getBranchWallet();
    await syncService.saveBranchWallet(wallet);

    await syncService.getDuesReports();

    const cards = await syncService.getAdmitCards();
    await syncService.saveAdmitCards(cards);

    const results = await syncService.getOnlineExamResults();
    await syncService.saveOnlineResults(results);

    const materials = await syncService.getStudyMaterials();
    await syncService.saveStudyMaterials(materials);

    const syllabus = await syncService.getSyllabus();
    await syncService.saveStudyMaterials(syllabus); // Reuse saveStudyMaterials for syllabus

    const webPages = await syncService.getWebPages();
    await syncService.saveWebPages(webPages);

    const banners = await syncService.getBanners();
    await syncService.saveBanners(banners);

    const photos = await syncService.getPhotoAlbums();
    await syncService.saveAlbums(photos);

    const videos = await syncService.getVideoAlbums();
    await syncService.saveAlbums(videos);

    const news = await syncService.getNews();
    await syncService.saveNews(news);

    // Run students to verify DB save
    // await syncService.getStudents();
}

testSync();
