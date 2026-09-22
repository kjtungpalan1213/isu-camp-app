import os
import unittest
from unittest.mock import Mock, patch

from app.utils.email import send_otp_email


class EmailTests(unittest.TestCase):
    def test_sends_using_configured_smtp(self):
        smtp = Mock()
        smtp.__enter__ = Mock(return_value=smtp)
        smtp.__exit__ = Mock(return_value=None)

        with patch.dict(os.environ, {
            "MAIL_SERVER": "smtp.resend.com",
            "MAIL_PORT": "587",
            "MAIL_USE_TLS": "True",
            "MAIL_USERNAME": "resend",
            "MAIL_PASSWORD": "test-password",
            "MAIL_DEFAULT_SENDER": "no-reply@kumpas.live",
        }, clear=True), patch("app.utils.email.smtplib.SMTP", return_value=smtp) as smtp_factory:
            send_otp_email("student@example.com", "123456")

        smtp_factory.assert_called_once_with("smtp.resend.com", 587)
        smtp.starttls.assert_called_once_with()
        smtp.login.assert_called_once_with("resend", "test-password")
        message = smtp.send_message.call_args.args[0]
        self.assertEqual(message["From"], "no-reply@kumpas.live")
        self.assertEqual(message["To"], "student@example.com")


if __name__ == "__main__":
    unittest.main()
