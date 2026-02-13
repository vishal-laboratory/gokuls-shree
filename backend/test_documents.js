/**
 * Test Document Generation
 * Generates sample marksheet and certificate PDFs
 */

require('dotenv').config();
const documentService = require('./src/services/document.service');
const fs = require('fs');
const path = require('path');

async function testDocumentGeneration() {
    console.log('🧪 Testing Document Generation...\n');

    // Sample student data
    const studentData = {
        regNo: 'GO100110020241750126',
        name: 'Pragya Singh',
        fatherName: 'Pankaj Singh',
        course: 'Advance Diploma In Computer Application (ADCA)',
        courseDuration: 'January-2025 To December-2025',
        session: '2025',
        centre: '(GO10011002024) Sanjeet Jaiswal Computer Training Centre',
        marksheetNo: '2K26J1MN10002',
        certificateNo: '2K26J1CN10002',
        issueDate: '07-Jan-2026',
        subjects: [
            { subject: 'Computer Concept & Fundamentals', marks: '78' },
            { subject: 'OS (Dos, Windows)', marks: '86' },
            { subject: 'Computer English Typing', marks: '94' },
            { subject: 'MS Office(Word, Adv.Excel, Access, PowerPoint)', marks: '88' },
            { subject: 'Tally Erp9', marks: '78' },
            { subject: 'Programming In C', marks: '88' },
            { subject: 'Page Maker', marks: '86' },
            { subject: 'Internet Technology & E-Mail', marks: '72' },
            { subject: 'HTML', marks: '84' },
            { subject: 'Project & Practical.', marks: '84' }
        ]
    };

    // Create output directory
    const outputDir = path.join(__dirname, 'generated_documents');
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    // Generate Marksheet
    console.log('📄 Generating Marksheet...');
    try {
        const marksheet = await documentService.generateMarksheet(studentData);
        const marksheetPath = path.join(outputDir, `Marksheet_${studentData.regNo}.pdf`);
        fs.writeFileSync(marksheetPath, marksheet.pdfBytes);
        console.log(`   ✅ Marksheet saved: ${marksheetPath}`);
        console.log(`   📋 Document ID: ${marksheet.documentId}`);
        console.log(`   📊 Metadata:`, marksheet.metadata);
    } catch (error) {
        console.error('   ❌ Marksheet error:', error.message);
    }

    // Generate Certificate
    console.log('\n📄 Generating Certificate...');
    try {
        const certificate = await documentService.generateCertificate({
            ...studentData,
            percentage: '83.8',
            grade: 'A'
        });
        const certificatePath = path.join(outputDir, `Certificate_${studentData.regNo}.pdf`);
        fs.writeFileSync(certificatePath, certificate.pdfBytes);
        console.log(`   ✅ Certificate saved: ${certificatePath}`);
        console.log(`   📋 Document ID: ${certificate.documentId}`);
        console.log(`   📊 Metadata:`, certificate.metadata);
    } catch (error) {
        console.error('   ❌ Certificate error:', error.message);
    }

    console.log('\n🎉 Document generation test complete!');
    console.log(`📁 Check generated PDFs in: ${outputDir}`);
}

testDocumentGeneration().catch(console.error);
