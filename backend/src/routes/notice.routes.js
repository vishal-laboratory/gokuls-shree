const express = require('express');
const db = require('../config/database');

const router = express.Router();

// Get all notices
router.get('/', async (req, res) => {
    try {
        const { category, limit } = req.query;

        let query = 'SELECT * FROM notices WHERE is_active = true';
        const params = [];
        let paramIndex = 1;

        if (category) {
            query += ` AND category = $${paramIndex}`;
            params.push(category);
            paramIndex++;
        }

        query += ' ORDER BY published_at DESC';

        if (limit) {
            query += ` LIMIT $${paramIndex}`;
            params.push(parseInt(limit));
        }

        const result = await db.query(query, params);

        res.json({
            count: result.rows.length,
            notices: result.rows.map(row => ({
                id: row.id.toString(),
                title: row.title,
                content: row.content,
                category: row.category,
                attachmentUrl: row.attachment_url,
                publishedAt: row.published_at,
            })),
        });
    } catch (error) {
        console.error('Get notices error:', error);
        res.status(500).json({ error: 'Failed to fetch notices' });
    }
});

// Get notice by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query(
            'SELECT * FROM notices WHERE id = $1 AND is_active = true',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Notice not found' });
        }

        const row = result.rows[0];
        res.json({
            id: row.id.toString(),
            title: row.title,
            content: row.content,
            category: row.category,
            attachmentUrl: row.attachment_url,
            publishedAt: row.published_at,
        });
    } catch (error) {
        console.error('Get notice error:', error);
        res.status(500).json({ error: 'Failed to fetch notice' });
    }
});

module.exports = router;
