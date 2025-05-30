const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const nodemailer = require('nodemailer');

// Cấu hình SMTP: dùng Gmail làm ví dụ (tạo App Password trong Google Account)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'kimthao12a17@gmail.com',       // Thay bằng email của bạn
    pass: 'uhnf lftt qcez wlqe',     // App password của Gmail (không phải mật khẩu chính)
  },
});

exports.sendOrderStatusEmail = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    console.log("Function sendOrderStatusEmail triggered");

    const before = change.before.data();
    const after = change.after.data();

    console.log("Before:", before);
    console.log("After:", after);

    if (
      before.order_confirmed !== after.order_confirmed ||
      before.order_on_delivery !== after.order_on_delivery ||
      before.order_delivered !== after.order_delivered
    ) {
      // Lấy order_by (user id hoặc user reference) từ đơn hàng
      const userId = after.order_by;

      if (!userId) {
        console.log('Không tìm thấy userId trong đơn hàng');
        return null;
      }

      // Lấy email user từ Firestore
      const userDoc = await admin.firestore().collection('user').doc(userId).get();

      if (!userDoc.exists) {
        console.log('Không tìm thấy user với id:', userId);
        return null;
      }

      const userData = userDoc.data();
      const email = userData?.email;

      console.log("Email lấy từ user:", email);

      if (!email) {
        console.log('User không có email');
        return null;
      }

      const orderCode = after.order_code;

      const mailOptions = {
        from: 'kimthao12a17@gmail.com',
        to: email,
        subject: `Cập nhật trạng thái đơn hàng ${orderCode}`,
        text: `Đơn hàng ${orderCode} đã được cập nhật trạng thái:\n
- Xác nhận: ${after.order_confirmed ? 'Có' : 'Chưa'}\n
- Đang giao: ${after.order_on_delivery ? 'Có' : 'Chưa'}\n
- Đã giao: ${after.order_delivered ? 'Có' : 'Chưa'}`,
      };

      try {
        console.log("Bắt đầu gửi email...");
        await transporter.sendMail(mailOptions);
        console.log('Email gửi thành công đến', email);
      } catch (error) {
        console.error('Lỗi gửi email:', error);
      }
    } else {
      console.log("Trạng thái đơn hàng không thay đổi, không gửi email.");
    }

    return null;
  });


  exports.testSendEmail = functions.https.onRequest(async (req, res) => {
    const mailOptions = {
      from: '6351071066@st.utc2.edu.vn',
      to: 'tranthingoctrinh3012@gmail.com',
      subject: 'Test gửi mail',
      text: 'Đây là email test gửi từ Firebase Functions',
    };
    try {
      await transporter.sendMail(mailOptions);
      res.send('Email đã gửi thành công');
    } catch (e) {
      res.status(500).send('Lỗi gửi mail: ' + e.toString());
    }
  });
