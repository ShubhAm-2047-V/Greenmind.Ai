const https = require('https');
const fs = require('fs');

let supabaseUrl = '';
let supabaseKey = '';

try {
  const envContent = fs.readFileSync('.env', 'utf8');
  const lines = envContent.split('\n');
  for (const line of lines) {
    if (line.startsWith('SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].trim();
    }
    if (line.startsWith('SUPABASE_KEY=')) {
      supabaseKey = line.split('=')[1].trim();
    }
  }
} catch (e) {
  console.log("Error reading .env", e);
}

if (!supabaseUrl || !supabaseKey) {
  // Hardcoded fallback from what we saw
  supabaseUrl = "https://zsfzuxwvobtggkrgpsls.supabase.co";
  supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzZnp1eHd2b2J0Z2drcmdwc2xzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NjIzODgsImV4cCI6MjA5MzAzODM4OH0.oS9dhlAlso5SnDkPs0ZkzRphkoh65yLO5IVvyDG2Gs4";
}

const url = `${supabaseUrl}/rest/v1/scans?limit=1`;
console.log("Querying Supabase URL:", url);

const options = {
  headers: {
    'apikey': supabaseKey,
    'Authorization': `Bearer ${supabaseKey}`
  }
};

https.get(url, options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      if (json && json.length > 0) {
        console.log("SUCCESS! Row columns:", Object.keys(json[0]));
        console.log("Sample row:", json[0]);
      } else {
        console.log("SUCCESS! No rows returned, but response is:", json);
      }
    } catch (e) {
      console.log("Failed to parse JSON response:", e);
      console.log("Raw response:", data);
    }
  });
}).on('error', (err) => {
  console.error("HTTP request error:", err);
});
