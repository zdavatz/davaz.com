#!/usr/bin/env python3
"""
Send email via Gmail API using OAuth2 credentials from old2new.

Usage:
  python3 bin/send_email_gmail.py \
    --to juerg@davaz.com \
    --subject "Subject line" \
    --body-file /path/to/body.txt \
    --client-secret /root/client_secret.json \
    --token /root/youtube_token.json
"""

import argparse
import base64
import sys
from email.mime.text import MIMEText


def send_email(creds, to_email, subject, body_text):
    from googleapiclient.discovery import build

    gmail = build("gmail", "v1", credentials=creds)
    message = MIMEText(body_text, "plain", "utf-8")
    message["to"] = to_email
    message["subject"] = subject
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
    gmail.users().messages().send(
        userId="me", body={"raw": raw}
    ).execute()
    print(f"Email sent to {to_email}")


def main():
    parser = argparse.ArgumentParser(description="Send email via Gmail API")
    parser.add_argument("--to", required=True, help="Recipient email")
    parser.add_argument("--subject", required=True, help="Email subject")
    parser.add_argument("--body", help="Email body text")
    parser.add_argument("--body-file", help="File containing email body")
    parser.add_argument("--client-secret", default="client_secret.json")
    parser.add_argument("--token", default="youtube_token.json")
    args = parser.parse_args()

    if args.body_file:
        with open(args.body_file, "r") as f:
            body = f.read()
    elif args.body:
        body = args.body
    else:
        body = sys.stdin.read()

    # Load credentials (same as old2new/youtube_upload.py)
    from google.oauth2.credentials import Credentials
    from google.auth.transport.requests import Request

    creds = Credentials.from_authorized_user_file(args.token)
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())
        with open(args.token, "w") as f:
            f.write(creds.to_json())

    send_email(creds, args.to, args.subject, body)


if __name__ == "__main__":
    main()
