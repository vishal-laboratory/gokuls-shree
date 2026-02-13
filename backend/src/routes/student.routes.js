const express = require('express');
const db = require('../config/database');
const { authMiddleware } = require('../middleware/auth.middleware');

const router = express.Router();

// Get student profile (protected)
router.get('/profile', authMiddleware, async (req, res) => {
    try {
        const result = await db.query(
            `SELECT s.*, c.title as course_name 
       FROM students s 
       LEFT JOIN courses c ON s.course_id = c.id 
       WHERE s.id = $1`,
            [req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Student not found' });
        }

        const student = result.rows[0];
        res.json({
            id: student.id.toString(),
            registrationNumber: student.registration_number,
            name: student.name,
            email: student.email,
            phone: student.phone,
            courseName: student.course_name,
            sessionYear: student.session_year,
            photoUrl: student.photo_url,
        });
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({ error: 'Failed to fetch profile' });
    }
});

// Get student results (protected)
router.get('/results', authMiddleware, async (req, res) => {
    try {
        const result = await db.query(
            `SELECT * FROM results WHERE student_id = $1 ORDER BY exam_date DESC`,
            [req.user.id]
        );

        res.json({
            count: result.rows.length,
            results: result.rows.map(row => ({
                id: row.id.toString(),
                examName: row.exam_name,
                examDate: row.exam_date,
                totalMarks: row.total_marks,
                obtainedMarks: row.obtained_marks,
                percentage: row.percentage,
                grade: row.grade,
                status: row.status,
            })),
        });
    } catch (error) {
        console.error('Get results error:', error);
        res.status(500).json({ error: 'Failed to fetch results' });
    }
});

// Get admit cards (protected)
router.get('/admit-cards', authMiddleware, async (req, res) => {
    try {
        const result = await db.query(
            `SELECT * FROM admit_cards WHERE student_id = $1 ORDER BY exam_date DESC`,
            [req.user.id]
        );

        res.json({
            count: result.rows.length,
            admitCards: result.rows.map(row => ({
                id: row.id.toString(),
                examName: row.exam_name,
                examDate: row.exam_date,
                examVenue: row.exam_venue,
                reportingTime: row.reporting_time,
                isDownloaded: row.is_downloaded,
            })),
        });
    } catch (error) {
        console.error('Get admit cards error:', error);
        res.status(500).json({ error: 'Failed to fetch admit cards' });
    }
});

// Verify student (public - for certificate verification)
router.post('/verify', async (req, res) => {
    try {
        const { registrationNumber, name } = req.body;

        const result = await db.query(
            `SELECT s.registration_number, s.name, c.title as course_name, s.session_year
       FROM students s
       LEFT JOIN courses c ON s.course_id = c.id
       WHERE s.registration_number = $1 AND LOWER(s.name) LIKE LOWER($2)`,
            [registrationNumber, `%${name}%`]
        );

        if (result.rows.length === 0) {
            return res.json({ verified: false, message: 'Student not found' });
        }

        const student = result.rows[0];
        res.json({
            verified: true,
            student: {
                registrationNumber: student.registration_number,
                name: student.name,
                courseName: student.course_name,
                sessionYear: student.session_year,
            },
        });
    } catch (error) {
        console.error('Verify student error:', error);
        res.status(500).json({ error: 'Verification failed' });
    }
});

module.exports = router;
