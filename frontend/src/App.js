import React, { useState } from 'react';
import axios from 'axios';

function App() {
  const [originalUrl, setOriginalUrl] = useState('');
  const [alias, setAlias] = useState('');
  const [shortenedUrl, setShortenedUrl] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:8000/shorten', {
        original_url: originalUrl,
        alias: alias,
      });
      setShortenedUrl(response.data.shortened_url);
    } catch (error) {
      console.error('Error shortening URL:', error);
      alert('Failed to shorten the URL. Please try again.');
    }
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
      <h1>URL Shortener</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <input
            type="text"
            placeholder="Enter original URL"
            value={originalUrl}
            onChange={(e) => setOriginalUrl(e.target.value)}
            required
            style={{ padding: '10px', width: '300px' }}
          />
        </div>
        <div style={{ marginTop: '10px' }}>
          <input
            type="text"
            placeholder="Enter alias (optional)"
            value={alias}
            onChange={(e) => setAlias(e.target.value)}
            style={{ padding: '10px', width: '300px' }}
          />
        </div>
        <button type="submit" style={{ marginTop: '20px', padding: '10px 20px' }}>
          Shorten URL
        </button>
      </form>
      {shortenedUrl && (
        <div style={{ marginTop: '20px' }}>
          <h2>Your shortened URL:</h2>
          <a href={shortenedUrl} target="_blank" rel="noopener noreferrer">
            {shortenedUrl}
          </a>
        </div>
      )}
    </div>
  );
}

export default App;
