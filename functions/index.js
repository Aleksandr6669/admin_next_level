const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// To configure, run the following commands in your terminal:
// firebase functions:config:set gmail.email="your_email@gmail.com"
// firebase functions:config:set gmail.password="your_app_password"

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: functions.config().gmail.email,
        pass: functions.config().gmail.password,
    },
});

exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
    const { email, code } = data;

    if (!email || !code) {
        throw new functions.https.HttpsError(
            "invalid-argument", 
            "The function must be called with two arguments 'email' and 'code'."
        );
    }

    const mailOptions = {
        from: `"Your App Name" <${functions.config().gmail.email}>`,
        to: email,
        subject: "Your Verification Code",
        html: `
        <div style="font-family: Arial, sans-serif; text-align: center; color: #333;">
          <h2>Email Verification</h2>
          <p>Hello,</p>
          <p>Your verification code is:</p>
          <p style="font-size: 24px; font-weight: bold; letter-spacing: 4px; background-color: #f2f2f2; padding: 15px; border-radius: 5px;">
            ${code}
          </p>
          <p>This code will expire in 10 minutes.</p>
          <p>If you did not request this, please ignore this email.</p>
          <br>
          <p>Thanks,</p>
          <p><strong>The Your App Team</strong></p>
        </div>
      `,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`Verification email sent to ${email}`);
        return { success: true };
    } catch (error) {
        console.error("Error sending email:", error);
        throw new functions.https.HttpsError(
            "internal", 
            "An error occurred while sending the email.",
            error
        );
    }
});
