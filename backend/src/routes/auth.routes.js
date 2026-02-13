const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');

const router = express.Router();

// Login
router.post('/login', [
    body('registrationNumber').notEmpty().withMessage('Registration number is required'),
    body('password').notEmpty().withMessage('Password is required'),
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { registrationNumber, password } = req.body;

        // Find student
        const result = await db.query(
            'SELECT * FROM students WHERE registration_number = $1 AND is_active = true',
            [registrationNumber]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const student = result.rows[0];

        // Verify password
        const isValidPassword = await bcrypt.compare(password, student.password_hash);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Get course info
        let courseName = null;
        if (student.course_id) {
            const courseResult = await db.query('SELECT title FROM courses WHERE id = $1', [student.course_id]);
            if (courseResult.rows.length > 0) {
                courseName = courseResult.rows[0].title;
            }
        }

        // Generate JWT
        const token = jwt.sign(
            {
                id: student.id,
                registrationNumber: student.registration_number,
                name: student.name
            },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        );

        res.json({
            message: 'Login successful',
            token,
            user: {
                id: student.id.toString(),
                registrationNumber: student.registration_number,
                name: student.name,
                email: student.email,
                phone: student.phone,
                courseName,
                sessionYear: student.session_year,
                photoUrl: student.photo_url,
            },
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

// Register (simplified for demo)
router.post('/register', [
    body('registrationNumber').notEmpty(),
    body('name').notEmpty(),
    body('password').isLength({ min: 4 }),
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { registrationNumber, name, email, phone, password, courseId, sessionYear } = req.body;

        // Check if already exists
        const existing = await db.query(
            'SELECT id FROM students WHERE registration_number = $1',
            [registrationNumber]
        );

        if (existing.rows.length > 0) {
            return res.status(409).json({ error: 'Registration number already exists' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert student
        const result = await db.query(
            `INSERT INTO students (registration_number, name, email, phone, password_hash, course_id, session_year)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
            [registrationNumber, name, email, phone, hashedPassword, courseId, sessionYear]
        );

        res.status(201).json({
            message: 'Registration successful',
            studentId: result.rows[0].id,
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

// Verify Token
router.get('/verify', require('../middleware/auth.middleware').authMiddleware, (req, res) => {
    res.json({ valid: true, user: req.user });
});

module.exports = router;
