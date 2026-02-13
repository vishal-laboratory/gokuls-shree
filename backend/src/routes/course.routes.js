const express = require('express');
const db = require('../config/database');

const router = express.Router();

// Get all courses
router.get('/', async (req, res) => {
    try {
        const { category } = req.query;

        let query = 'SELECT * FROM courses WHERE is_active = true';
        const params = [];

        if (category) {
            query += ' AND category = $1';
            params.push(category);
        }

        query += ' ORDER BY title';

        const result = await db.query(query, params);

        res.json({
            count: result.rows.length,
            courses: result.rows.map(row => ({
                id: row.id.toString(),
                title: row.title,
                category: row.category,
                duration: row.duration,
                eligibility: row.eligibility,
                description: row.description,
                imageUrl: row.image_url,
            })),
        });
    } catch (error) {
        console.error('Get courses error:', error);
        res.status(500).json({ error: 'Failed to fetch courses' });
    }
});

// Get course by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query(
            'SELECT * FROM courses WHERE id = $1 AND is_active = true',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Course not found' });
        }

        const row = result.rows[0];
        res.json({
            id: row.id.toString(),
            title: row.title,
            category: row.category,
            duration: row.duration,
            eligibility: row.eligibility,
            description: row.description,
            imageUrl: row.image_url,
        });
    } catch (error) {
        console.error('Get course error:', error);
        res.status(500).json({ error: 'Failed to fetch course' });
    }
});

// Get course categories
router.get('/meta/categories', async (req, res) => {
    try {
        const result = await db.query(
            'SELECT DISTINCT category FROM courses WHERE is_active = true ORDER BY category'
        );

        res.json({
            categories: result.rows.map(row => row.category),
        });
    } catch (error) {
        console.error('Get categories error:', error);
        res.status(500).json({ error: 'Failed to fetch categories' });
    }
});

module.exports = router;
