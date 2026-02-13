/**
 * PKI Signer Service
 * Digitally signs PDF documents using X.509 certificates
 * 
 * For production: Use a Trusted CA certificate (DigiCert, Certum, GlobalSign)
 * The certificate should be in P12/PFX format stored securely
 */

const fs = require('fs');
const path = require('path');
const forge = require('node-forge');

class PKISignerService {
    constructor() {
        this.certificatePath = process.env.PKI_CERTIFICATE_PATH || null;
        this.certificatePassword = process.env.PKI_CERTIFICATE_PASSWORD || '';
        this.signerName = 'Gokulshree School Of Management And Technology Private Limited';
        this.signerLocation = 'Bahraich, Uttar Pradesh, India';
        this.signerReason = 'Document Authentication';
    }

    /**
     * Generate a self-signed test certificate for development
     * In production, you would load a real CA-issued P12 certificate
     */
    async generateSelfSignedCertificate() {
        console.log('🔐 Generating self-signed certificate for development...');

        // Generate key pair
        const keys = forge.pki.rsa.generateKeyPair(2048);

        // Create certificate
        const cert = forge.pki.createCertificate();
        cert.publicKey = keys.publicKey;
        cert.serialNumber = '01';
        cert.validity.notBefore = new Date();
        cert.validity.notAfter = new Date();
        cert.validity.notAfter.setFullYear(cert.validity.notBefore.getFullYear() + 1);

        const attrs = [
            { name: 'commonName', value: this.signerName },
            { name: 'countryName', value: 'IN' },
            { name: 'stateOrProvinceName', value: 'Uttar Pradesh' },
            { name: 'localityName', value: 'Bahraich' },
            { name: 'organizationName', value: 'Gokulshree School' },
            { shortName: 'OU', value: 'Document Signing' }
        ];

        cert.setSubject(attrs);
        cert.setIssuer(attrs);

        // Extensions
        cert.setExtensions([
            { name: 'basicConstraints', cA: true },
            { name: 'keyUsage', keyCertSign: true, digitalSignature: true, nonRepudiation: true, keyEncipherment: true },
            { name: 'extKeyUsage', serverAuth: true, clientAuth: true, codeSigning: true, emailProtection: true, timeStamping: true },
            { name: 'subjectKeyIdentifier' }
        ]);

        // Self-sign
        cert.sign(keys.privateKey, forge.md.sha256.create());

        // Convert to PEM
        const pemCert = forge.pki.certificateToPem(cert);
        const pemKey = forge.pki.privateKeyToPem(keys.privateKey);

        // Create P12/PFX
        const password = 'test123'; // For development only
        const p12Asn1 = forge.pkcs12.toPkcs12Asn1(keys.privateKey, cert, password);
        const p12Der = forge.asn1.toDer(p12Asn1).getBytes();
        const p12Buffer = Buffer.from(p12Der, 'binary');

        // Save to file
        const certsDir = path.join(__dirname, '../../certs');
        if (!fs.existsSync(certsDir)) {
            fs.mkdirSync(certsDir, { recursive: true });
        }

        fs.writeFileSync(path.join(certsDir, 'dev-certificate.pem'), pemCert);
        fs.writeFileSync(path.join(certsDir, 'dev-private-key.pem'), pemKey);
        fs.writeFileSync(path.join(certsDir, 'dev-certificate.p12'), p12Buffer);

        console.log('✅ Development certificates saved to /certs directory');
        console.log('⚠️  For production, use a Trusted CA certificate!');

        return {
            certificate: pemCert,
            privateKey: pemKey,
            p12Buffer,
            password
        };
    }

    /**
     * Load P12/PFX certificate from file
     */
    loadCertificate(p12Path, password) {
        const p12Buffer = fs.readFileSync(p12Path);
        const p12Der = forge.util.decode64(p12Buffer.toString('base64'));
        const p12Asn1 = forge.asn1.fromDer(p12Der);
        const p12 = forge.pkcs12.pkcs12FromAsn1(p12Asn1, password);

        // Extract certificate and key
        const certBags = p12.getBags({ bagType: forge.pki.oids.certBag })[forge.pki.oids.certBag];
        const keyBags = p12.getBags({ bagType: forge.pki.oids.pkcs8ShroudedKeyBag })[forge.pki.oids.pkcs8ShroudedKeyBag];

        if (!certBags || certBags.length === 0) {
            throw new Error('No certificate found in P12 file');
        }

        return {
            certificate: certBags[0].cert,
            privateKey: keyBags ? keyBags[0].key : null
        };
    }

    /**
     * Create signature placeholder in PDF
     * This adds the necessary structure for PDF signing
     */
    createSignaturePlaceholder(pdfBytes) {
        // Convert Buffer to string for manipulation
        let pdfString = pdfBytes.toString('binary');

        // Find the EOF marker
        const eofIndex = pdfString.lastIndexOf('%%EOF');

        // Create signature dictionary
        const sigDict = {
            Type: '/Sig',
            Filter: '/Adobe.PPKLite',
            SubFilter: '/adbe.pkcs7.detached',
            Name: `(${this.signerName})`,
            Location: `(${this.signerLocation})`,
            Reason: `(${this.signerReason})`,
            M: `(D:${this.formatDate(new Date())})`,
            Contents: '<' + '0'.repeat(8192) + '>',  // Placeholder for actual signature
            ByteRange: '[0 0 0 0]'  // Will be updated with actual byte ranges
        };

        return {
            pdfBytes,
            signatureInfo: sigDict
        };
    }

    /**
     * Format date for PDF signature
     */
    formatDate(date) {
        const y = date.getFullYear();
        const m = String(date.getMonth() + 1).padStart(2, '0');
        const d = String(date.getDate()).padStart(2, '0');
        const h = String(date.getHours()).padStart(2, '0');
        const min = String(date.getMinutes()).padStart(2, '0');
        const s = String(date.getSeconds()).padStart(2, '0');
        return `${y}${m}${d}${h}${min}${s}+05'30'`;
    }

    /**
     * Get certificate info for display
     */
    getCertificateInfo() {
        if (!this.certificatePath) {
            return {
                status: 'development',
                signer: this.signerName,
                warning: 'Using self-signed certificate - documents will show "Validity unknown"',
                recommendation: 'Purchase a Trusted CA certificate for "Signature valid" status'
            };
        }

        try {
            const { certificate } = this.loadCertificate(this.certificatePath, this.certificatePassword);
            return {
                status: 'production',
                signer: certificate.subject.getField('CN').value,
                issuer: certificate.issuer.getField('CN').value,
                validFrom: certificate.validity.notBefore,
                validTo: certificate.validity.notAfter,
                serialNumber: certificate.serialNumber
            };
        } catch (e) {
            return {
                status: 'error',
                error: e.message
            };
        }
    }
}

module.exports = new PKISignerService();
