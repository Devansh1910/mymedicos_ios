const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure your email service (e.g., Gmail using nodemailer)
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'your-email@gmail.com',
        pass: 'your-email-password',
    },
});

exports.sendOTP = functions.https.onCall(async (data, context) => {
    const email = data.email;
    const otp = Math.floor(100000 + Math.random() * 900000).toString(); // Generate a 6-digit OTP

    // Store the OTP temporarily in Firestore
    await admin.firestore().collection('otps').doc(email).set({ otp, timestamp: admin.firestore.FieldValue.serverTimestamp() });

    const mailOptions = {
        from: 'your-email@gmail.com',
        to: email,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}`,
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true };
    } catch (error) {
        console.error('Error sending OTP email:', error);
        throw new functions.https.HttpsError('internal', 'Failed to send OTP');
    }
});
