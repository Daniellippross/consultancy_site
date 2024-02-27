const express = require('express');
const path = require('path');
const app = express();

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'src', 'public')));

// Route for the home page (index.html)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'src', 'public', 'html', 'index.html'));
});

// Route for the about page
app.get('/about', (req, res) => {
  res.sendFile(path.join(__dirname, 'src', 'public', 'html', 'about.html'));
});

// Add more routes as needed...

const port = 3000;
app.listen(port, () => console.log(`Server running at http://localhost:${port}`));
