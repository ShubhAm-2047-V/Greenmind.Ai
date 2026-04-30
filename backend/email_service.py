import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

load_dotenv()

def send_analysis_report(receiver_email, result):
    smtp_server = os.getenv("EMAIL_HOST", "smtp.gmail.com")
    smtp_port = int(os.getenv("EMAIL_PORT", "587"))
    sender_email = os.getenv("EMAIL_USER")
    sender_password = os.getenv("EMAIL_PASSWORD")

    if not sender_email or not sender_password or "your-email" in sender_email:
        print(f"ERROR: Email credentials not fully configured. User: {sender_email}")
        return False

    # Gmail App Passwords usually have spaces, but SMTP needs them stripped
    if sender_password:
        sender_password = sender_password.replace(" ", "")

    plant = result.get("plant", "Unknown Plant")
    disease = result.get("disease", "Unknown Condition")
    confidence = result.get("confidence", "N/A")
    description = result.get("description", "")
    cause = result.get("cause", "")
    solution = result.get("solution", "")
    
    is_healthy = disease.lower() == "healthy"
    status_color = "#2e7d32" if is_healthy else "#d32f2f"
    bg_gradient = "linear-gradient(135deg, #2e7d32 0%, #1b5e20 100%)"

    message = MIMEMultipart("alternative")
    message["Subject"] = f"🌿 Analysis Ready: {plant} ({disease})"
    message["From"] = f"GreenMind AI <{sender_email}>"
    message["To"] = receiver_email

    html_content = f"""
    <html>
    <head>
        <style>
            .card {{
                background: #ffffff;
                border-radius: 16px;
                padding: 24px;
                margin-bottom: 20px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            }}
            .badge {{
                display: inline-block;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: bold;
                text-transform: uppercase;
                letter-spacing: 1px;
            }}
        </style>
    </head>
    <body style="margin: 0; padding: 0; background-color: #f8faf9; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
        <div style="max-width: 600px; margin: 40px auto; overflow: hidden;">
            
            <!-- PREMIUM HEADER -->
            <div style="background: {bg_gradient}; padding: 40px 20px; text-align: center; border-radius: 24px 24px 0 0;">
                <div style="color: rgba(255,255,255,0.8); font-size: 12px; font-weight: bold; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 8px;">GreenMind AI</div>
                <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 300;">Analysis <span style="font-weight: bold;">Report</span></h1>
            </div>

            <!-- CONTENT CONTAINER -->
            <div style="padding: 20px; background: #f8faf9; border-radius: 0 0 24px 24px; border: 1px solid #eee; border-top: none;">
                
                <!-- MAIN STATUS CARD -->
                <div class="card" style="text-align: center; border-top: 4px solid {status_color};">
                    <div style="font-size: 48px; margin-bottom: 10px;">{'🌿' if is_healthy else '⚠️'}</div>
                    <h2 style="margin: 0; color: #1a1a1a; font-size: 22px;">{plant}</h2>
                    <p style="color: {status_color}; font-weight: bold; font-size: 18px; margin: 10px 0;">{disease}</p>
                    <div class="badge" style="background: #e3f2fd; color: #1976d2;">Confidence: {confidence}</div>
                </div>

                <!-- DESCRIPTION SECTION -->
                <div class="card">
                    <h3 style="color: #2e7d32; margin-top: 0; font-size: 16px;">Detailed Findings</h3>
                    <p style="color: #4a4a4a; line-height: 1.6; font-size: 14px; margin-bottom: 0;">{description}</p>
                </div>

                <!-- TWO COLUMN GRID (Mockup for Cause/Solution) -->
                <div class="card" style="background: #fff9c4; border-left: 4px solid #fbc02d;">
                    <h3 style="color: #827717; margin-top: 0; font-size: 14px; text-transform: uppercase;">Possible Cause</h3>
                    <p style="color: #333; font-size: 14px; margin-bottom: 0;">{cause}</p>
                </div>

                <div class="card" style="background: #e8f5e9; border-left: 4px solid #2e7d32;">
                    <h3 style="color: #1b5e20; margin-top: 0; font-size: 14px; text-transform: uppercase;">Treatment Plan</h3>
                    <p style="color: #1b5e20; font-size: 14px; line-height: 1.6; margin-bottom: 0;">{solution}</p>
                </div>

                <!-- FOOTER -->
                <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
                    <p>Designed by GreenMind AI Expert Systems</p>
                    <p>You received this because you requested a plant analysis via our mobile app.</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    """

    part = MIMEText(html_content, "html")
    message.attach(part)

    try:
        print(f"DEBUG: Connecting to SMTP {smtp_server}:{smtp_port}...")
        with smtplib.SMTP(smtp_server, smtp_port, timeout=10) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        print(f"DEBUG: Premium email sent successfully to {receiver_email}")
        return True
    except smtplib.SMTPAuthenticationError:
        print("ERROR: SMTP Authentication failed. Check your EMAIL_USER and EMAIL_PASSWORD (App Password).")
        return False
    except Exception as e:
        print(f"ERROR: Failed to send premium email to {receiver_email}: {type(e).__name__}: {e}")
        return False
