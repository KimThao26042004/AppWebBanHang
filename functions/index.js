// functions/index.js
const { onRequest } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

admin.initializeApp();

const { user, pass } = functions.config().smtp;
const transporter = nodemailer.createTransport({
  service: "Gmail",
  auth: { user, pass },
});

exports.sendResetCode = onRequest((req, res) => {
  // 1) CORS preflight
  if (req.method === "OPTIONS") {
    res
      .status(204)
      .set("Access-Control-Allow-Origin", "*")
      .set("Access-Control-Allow-Methods", "POST, OPTIONS")
      .set("Access-Control-Allow-Headers", "Content-Type")
      .send("");
    return;
  }

  // 2) Always allow from any origin
  res.set("Access-Control-Allow-Origin", "*");

  // 3) Health‐check GET
  if (req.method === "GET") {
    return res.status(200).send("OK");
  }

  if (req.method !== "POST") {
    return res.status(405).send({ error: "Method not allowed" });
  }

  // 4) Xử lý POST gửi mail
  (async () => {
    try {
      const { adminEmail: email } = req.body || {};
      if (!email) {
        return res.status(400).json({ error: "Email không được để trống" });
      }

      const code = Math.floor(100000 + Math.random() * 900000).toString();
      const db = getFirestore();
      await db.collection("resetCodes").doc(email).set({
        code,
        createdAt: FieldValue.serverTimestamp(),
      });

      await transporter.sendMail({
        from: `YourApp <${user}>`,
        to: email,
        subject: "Mã xác thực quên mật khẩu",
        text: `Mã của bạn là: ${code}`,
      });

      return res.json({ success: true, code });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: err.message });
    }
  })();
});
