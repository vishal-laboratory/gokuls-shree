/**
 * Setup PKI Infrastructure
 * Generates self-signed certificates for development/testing
 */

require('dotenv').config();
const pkiSignerService = require('./src/services/pki-signer.service');

async function setupPKI() {
    console.log('🛡️ Setting up PKI Infrastructure...');
    try {
        await pkiSignerService.generateSelfSignedCertificate();
        console.log('✅ PKI Setup Complete!');
        console.log('   - Certificate created in /certs');
        console.log('   - Ready for digital signing');
    } catch (error) {
        console.error('❌ PKI Setup Failed:', error.message);
    }
}

setupPKI();
