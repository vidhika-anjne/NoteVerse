const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const cloudinary = require("cloudinary").v2;

admin.initializeApp();

function cors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

async function verifyAuth(req) {
  const authHeader = req.get("Authorization") || "";
  const match = authHeader.match(/^Bearer\s+(.+)$/);
  if (!match) throw new Error("Missing Authorization Bearer token");
  const decoded = await admin.auth().verifyIdToken(match[1]);
  return decoded;
}

function readJsonBody(req) {
  if (!req.body || typeof req.body !== "object") {
    throw new Error("Invalid JSON body");
  }
  return req.body;
}

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`${name} not configured`);
  return v;
}

function setupCloudinary() {
  cloudinary.config({
    cloud_name: requireEnv("CLOUDINARY_CLOUD_NAME"),
    api_key: requireEnv("CLOUDINARY_API_KEY"),
    api_secret: requireEnv("CLOUDINARY_API_SECRET"),
  });
}

exports.uploadFile = onRequest(
  { secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"] },
  async (req, res) => {
    cors(res);
    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).json({ success: false, error: "Method not allowed" });

    try {
      await verifyAuth(req);
      setupCloudinary();

      const { fileData, fileName } = readJsonBody(req);
      if (!fileData || !fileName) throw new Error("fileData and fileName are required");

      const result = await new Promise((resolve, reject) => {
        cloudinary.uploader
          .upload_stream(
            { resource_type: "raw", folder: "noteverse_files", public_id: `${Date.now()}_${fileName}` },
            (error, uploadResult) => (error ? reject(error) : resolve(uploadResult))
          )
          .end(Buffer.from(fileData, "base64"));
      });

      return res.json({ success: true, url: result.secure_url, publicId: result.public_id });
    } catch (e) {
      logger.error("uploadFile error", e);
      return res.status(400).json({ success: false, error: e.message || String(e) });
    }
  }
);

exports.uploadImage = onRequest(
  { secrets: ["CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"] },
  async (req, res) => {
    cors(res);
    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).json({ success: false, error: "Method not allowed" });

    try {
      const decoded = await verifyAuth(req);
      setupCloudinary();

      const { imageData } = readJsonBody(req);
      if (!imageData) throw new Error("imageData is required");

      const result = await new Promise((resolve, reject) => {
        cloudinary.uploader
          .upload_stream(
            {
              resource_type: "image",
              folder: "noteverse_profiles",
              public_id: `profile_${decoded.uid}_${Date.now()}`,
              transformation: [{ width: 400, height: 400, crop: "fill" }, { quality: "auto" }],
            },
            (error, uploadResult) => (error ? reject(error) : resolve(uploadResult))
          )
          .end(Buffer.from(imageData, "base64"));
      });

      return res.json({ success: true, url: result.secure_url, publicId: result.public_id });
    } catch (e) {
      logger.error("uploadImage error", e);
      return res.status(400).json({ success: false, error: e.message || String(e) });
    }
  }
);

exports.summarizeText = onRequest(
  { secrets: ["GEMINI_API_KEY"] },
  async (req, res) => {
    cors(res);
    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).json({ success: false, error: "Method not allowed" });

    try {
      await verifyAuth(req);
      const { text } = readJsonBody(req);
      if (!text || !String(text).trim()) throw new Error("text is required");

      const apiKey = requireEnv("GEMINI_API_KEY");
      const url =
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

      const r = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text:
                    "Read and summarize the contents of the file for study notes to be understood and learnt easily.\n" +
                    "Output only plain text without any Markdown formatting, headings, or special symbols:\n" +
                    text,
                },
              ],
            },
          ],
        }),
      });

      if (!r.ok) throw new Error(`Gemini API error: ${r.status}`);
      const data = await r.json();
      const summary = data?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!summary) throw new Error("No summary generated");

      return res.json({ success: true, summary });
    } catch (e) {
      logger.error("summarizeText error", e);
      return res.status(400).json({ success: false, error: e.message || String(e) });
    }
  }
);
