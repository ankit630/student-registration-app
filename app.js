const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let registrations = [];

app.post('/api/register', (req, res) => {
    const { name, email, course, experience } = req.body;
    registrations.push({ name, email, course, experience });
    res.json({ message: 'Registration successful', id: registrations.length });
});

app.get('/api/registrations', (req, res) => {
    res.json(registrations);
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
