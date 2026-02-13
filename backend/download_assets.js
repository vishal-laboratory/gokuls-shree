require('dotenv').config();
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const assets = [
    { name: 'marksheet.jpg', url: 'https://www.gokulshreeschool.com/images/marksheet.jpg' },
    { name: 'certificate.jpg', url: 'https://www.gokulshreeschool.com/images/certificate.jpg' },
    { name: 'iso.png', url: 'https://www.gokulshreeschool.com/images/iso.png' },
    { name: 'msme.png', url: 'https://www.gokulshreeschool.com/images/msme.png' },
    { name: 'skill.png', url: 'https://www.gokulshreeschool.com/images/skill.png' },
    { name: 'favicon.png', url: 'https://www.gokulshreeschool.com/images/favicon.png' },
];

async function downloadAssets() {
    const assetsDir = path.join(__dirname, 'assets', 'documents');

    if (!fs.existsSync(assetsDir)) {
        fs.mkdirSync(assetsDir, { recursive: true });
    }

    console.log('📥 Downloading document assets...\n');

    for (const asset of assets) {
        const filePath = path.join(assetsDir, asset.name);
        console.log(`   Downloading ${asset.name}...`);

        try {
            const response = await axios.get(asset.url, { responseType: 'arraybuffer' });
            fs.writeFileSync(filePath, response.data);
            console.log(`   ✅ Saved to ${filePath}`);
        } catch (e) {
            console.log(`   ❌ Failed: ${e.message}`);
        }
    }

    console.log('\n✅ Asset download complete!');
}

downloadAssets().catch(console.error);
