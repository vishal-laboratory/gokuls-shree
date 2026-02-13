/**
 * Document Routes - Generate digitally signed marksheets and certificates
 */

const express = require('express');
const router = express.Router();
const documentService = require('../services/document.service');
const pkiSignerService = require('../services/pki-signer.service');
const syncService = require('../services/sync.service');
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * GET /api/documents/marksheet/:regNo
 * Generate a digitally signed marksheet PDF
 */
router.get('/marksheet/:regNo', async (req, res) => {
    try {
        const { regNo } = req.params;

        // Get student data from database or sync service
        const studentResult = await pool.query(
            'SELECT * FROM students WHERE reg_no = $1',
            [regNo]
        );

        if (studentResult.rows.length === 0) {
            return res.status(404).json({ error: 'Student not found' });
        }

        const student = studentResult.rows[0];

        // Get marksheet data from sync
        const marksheets = await syncService.getMarksheets();
        const marksheet = marksheets.find(m => m.regNo === regNo);

        if (!marksheet) {
            return res.status(404).json({ error: 'Marksheet not found for this student' });
        }

        // Prepare student data for PDF generation
        const studentData = {
            regNo: regNo,
            name: student.name || marksheet.studentName,
            fatherName: student.father_name || marksheet.fatherName,
            course: student.course || marksheet.course,
            courseDuration: marksheet.session ? `January-${marksheet.session} To December-${marksheet.session}` : null,
            session: marksheet.session,
            centre: 'Sanjeet Jaiswal Computer Training Centre',
            subjects: marksheet.subjects || [],
            issueDate: marksheet.issueDate || new Date().toLocaleDateString(),
            marksheetNo: marksheet.marksheetNo
        };

        // Generate PDF
        const { pdfBytes, documentId, metadata } = await documentService.generateMarksheet(studentData);

        // Store document info in database for verification
        await pool.query(`
            INSERT INTO document_verifications (document_id, document_type, reg_no, student_name, issue_date, metadata)
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (document_id) DO UPDATE SET metadata = $6
        `, [documentId, 'marksheet', regNo, studentData.name, new Date(), JSON.stringify(metadata)]);

        // Send PDF
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename="Marksheet_${regNo}.pdf"`);
        res.send(Buffer.from(pdfBytes));

    } catch (error) {
        console.error('Marksheet generation error:', error);
        res.status(500).json({ error: 'Failed to generate marksheet', details: error.message });
    }
});

/**
 * GET /api/documents/certificate/:regNo
 * Generate a digitally signed certificate PDF
 */
router.get('/certificate/:regNo', async (req, res) => {
    try {
        const { regNo } = req.params;

        // Get student data
        const studentResult = await pool.query(
            'SELECT * FROM students WHERE reg_no = $1',
            [regNo]
        );

        if (studentResult.rows.length === 0) {
            return res.status(404).json({ error: 'Student not found' });
        }

        const student = studentResult.rows[0];

        // Get marksheet for grades
        const marksheets = await syncService.getMarksheets();
        const marksheet = marksheets.find(m => m.regNo === regNo);

        // Calculate percentage and grade from marksheet
        let percentage = '83.8';
        let grade = 'A';
        if (marksheet && marksheet.subjects) {
            const totalMarks = marksheet.subjects.reduce((sum, s) => sum + parseInt(s.marks || 0), 0);
            const maxMarks = marksheet.subjects.length * 100;
            percentage = ((totalMarks / maxMarks) * 100).toFixed(1);
            grade = documentService.calculateGrade(parseFloat(percentage));
        }

        const studentData = {
            regNo,
            name: student.name,
            fatherName: student.father_name,
            course: student.course,
            courseDuration: marksheet?.session ? `January-${marksheet.session} To December-${marksheet.session}` : null,
            session: marksheet?.session,
            centre: 'Sanjeet Jaiswal Computer Training Centre',
            percentage,
            grade,
            issueDate: marksheet?.issueDate || new Date().toLocaleDateString(),
            certificateNo: marksheet?.certificateNo
        };

        // Generate PDF
        const { pdfBytes, documentId, metadata } = await documentService.generateCertificate(studentData);

        // Store for verification
        await pool.query(`
            INSERT INTO document_verifications (document_id, document_type, reg_no, student_name, issue_date, metadata)
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (document_id) DO UPDATE SET metadata = $6
        `, [documentId, 'certificate', regNo, studentData.name, new Date(), JSON.stringify(metadata)]);

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename="Certificate_${regNo}.pdf"`);
        res.send(Buffer.from(pdfBytes));

    } catch (error) {
        console.error('Certificate generation error:', error);
        res.status(500).json({ error: 'Failed to generate certificate', details: error.message });
    }
});

/**
 * GET /api/documents/verify/:documentId
 * Verify document authenticity
 */
router.get('/verify/:documentId', async (req, res) => {
    try {
        const { documentId } = req.params;

        const result = await pool.query(
            'SELECT * FROM document_verifications WHERE document_id = $1',
            [documentId]
        );

        if (result.rows.length === 0) {
            return res.json({
                valid: false,
                error: 'Document not found in verification database'
            });
        }

        const doc = result.rows[0];
        const metadata = JSON.parse(doc.metadata || '{}');

        res.json({
            valid: true,
            documentType: doc.document_type,
            studentName: doc.student_name,
            regNo: doc.reg_no,
            issueDate: doc.issue_date,
            course: metadata.course,
            grade: metadata.grade,
            percentage: metadata.percentage,
            result: metadata.result,
            signedBy: metadata.signedBy || 'Gokulshree School Of Management And Technology Private Limited',
            verifiedAt: new Date().toISOString()
        });

    } catch (error) {
        console.error('Verification error:', error);
        res.status(500).json({ valid: false, error: 'Verification failed' });
    }
});

/**
 * GET /api/documents/certificate-info
 * Get PKI certificate status
 */
router.get('/certificate-info', (req, res) => {
    res.json(pkiSignerService.getCertificateInfo());
});

/**
 * POST /api/documents/generate-dev-cert
 * Generate development certificate (for testing)
 */
router.post('/generate-dev-cert', async (req, res) => {
    try {
        await pkiSignerService.generateSelfSignedCertificate();
        res.json({ success: true, message: 'Development certificate generated in /certs directory' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
