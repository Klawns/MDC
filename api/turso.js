export default async function handler(req, res) {
  // CORS configurations for seamless requests
  res.setHeader('Access-Control-Allow-Credentials', true)
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT')
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version')

  if (req.method === 'OPTIONS') {
    res.status(200).end()
    return
  }

  const urlStr = process.env.TURSO_URL;
  const token = process.env.TURSO_AUTH_TOKEN;

  if (!urlStr || !token) {
    return res.status(500).json({ error: "Missing Turso credentials in Vercel environment." });
  }

  const finalUrl = urlStr.replace('libsql://', 'https://') + '/v2/pipeline';

  const bodyData = typeof req.body === 'string' ? req.body : JSON.stringify(req.body);

  try {
    const fetchRes = await fetch(finalUrl, {
      method: req.method,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: bodyData
    });

    const textRes = await fetchRes.text();
    let data;
    try {
      if (textRes) {
        data = JSON.parse(textRes);
      } else {
        data = { error: "Empty response from Turso" };
      }
    } catch (e) {
      data = { error: textRes || "Unknown Turso Error" };
    }
    return res.status(fetchRes.status).json(data);
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
}
