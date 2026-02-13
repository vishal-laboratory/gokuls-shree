const axios = require('axios');
const cheerio = require('cheerio');

async function debugForm() {
    try {
        console.log('Fetching login page...');
        const res = await axios.get('https://www.gokulshreeschool.com/new/index.php');
        const $ = cheerio.load(res.data);

        let output = '--- FORM INPUTS ---\\n';
        $('form input').each((i, el) => {
            output += `Input: name="${$(el).attr('name')}" type="${$(el).attr('type')}" value="${$(el).attr('value')}"\\n`;
        });
        require('fs').writeFileSync('form_debug.txt', output);

        $('form select').each((i, el) => {
            console.log(`Select: name="${$(el).attr('name')}"`);
        });

        console.log('--- END ---');
    } catch (e) {
        console.error('Error fetching page:', e.message);
    }
}

debugForm();
