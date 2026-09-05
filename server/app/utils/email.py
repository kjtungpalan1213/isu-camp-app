import os
import smtplib
from email.message import EmailMessage

from dotenv import load_dotenv

load_dotenv()


def send_otp_email(recipient: str, otp: str):
    sender = os.getenv("EMAIL_USERNAME")
    password = os.getenv("EMAIL_PASSWORD")

    message = EmailMessage()
    message["Subject"] = "ISU-CAMP Email Verification"
    message["From"] = sender
    message["To"] = recipient

    message.set_content(
        f"""Hello,

Your ISU-CAMP verification code is:

{otp}

This code will expire in 5 minutes.

If you did not request this code, please ignore this email.

ISU-CAMP Team
"""
    )

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender, password)
        server.send_message(message)