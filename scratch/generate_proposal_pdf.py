import os
from fpdf import FPDF
from fpdf.enums import XPos, YPos

# Define the PDF class with the theme
class ProposalPDF(FPDF):
    def __init__(self):
        super().__init__()
        self.logo_path = r"e:\GreenMind al\backend\assets\logo.png"
        self.pert_path = r"e:\GreenMind al\scratch\pert_chart.png"
        
    def header(self):
        # Draw background color on every page
        self.set_fill_color(255, 252, 238)  # #FFFCEE
        self.rect(0, 0, 210, 297, 'F')
        
        # We only draw running headers for Page 2 onwards
        if self.page_no() > 1:
            # Running Header logo
            if os.path.exists(self.logo_path):
                self.image(self.logo_path, 175, 8, 20)
            
            # Running Header text
            self.set_font('Helvetica', 'B', 9)
            self.set_text_color(46, 125, 50)  # Forest Green
            self.cell(0, 10, 'GreenMind AI: Research & Development Proposal', 
                      new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
            
            # Draw a thin horizontal green line under header
            self.set_draw_color(46, 125, 50)
            self.set_line_width(0.3)
            self.line(15, 20, 195, 20)
            self.ln(6)
            
    def footer(self):
        # We only draw running footers for Page 2 onwards
        if self.page_no() > 1:
            self.set_y(-15)
            # Thin gray line above footer
            self.set_draw_color(200, 200, 200)
            self.set_line_width(0.3)
            self.line(15, self.get_y(), 195, self.get_y())
            
            self.set_font('Helvetica', 'I', 8)
            self.set_text_color(128, 128, 128)
            self.cell(0, 10, f'Page {self.page_no()} | GreenMind AI (c) 2026', 
                      new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')

def sanitize_for_pdf(text):
    if not text: return ""
    try:
        text.encode('latin-1')
        return text
    except (UnicodeEncodeError, AttributeError):
        import re
        # Replace common non-latin characters
        text = text.replace('•', '-')
        sanitized = re.sub(r'[^\x00-\xFF]+', '?', str(text))
        return sanitized

def draw_bullet_point(pdf, bold_part, text_part, indent=5):
    # Set text colors
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.set_text_color(46, 125, 50)
    
    # Draw custom small green circle
    cx = pdf.get_x() + indent
    cy = pdf.get_y() + 2.0
    pdf.ellipse(cx, cy, 1.5, 1.5, 'F')
    
    # Write text
    pdf.set_x(cx + 4)
    pdf.write(4.5, bold_part)
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 4.5, text_part, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(1.5)

def build_pdf():
    pdf = ProposalPDF()
    pdf.set_margins(15, 20, 15)
    
    # ---------------- PAGE 1: COVER PAGE ----------------
    pdf.add_page()
    
    # Logo
    if os.path.exists(pdf.logo_path):
        pdf.image(pdf.logo_path, 80, 45, 50)
    
    pdf.ln(90)
    
    # GreenMind AI title banner
    pdf.set_fill_color(46, 125, 50)
    pdf.rect(15, 115, 180, 20, 'F')
    
    pdf.set_font('Helvetica', 'B', 22)
    pdf.set_text_color(255, 255, 255)
    pdf.set_xy(15, 115)
    pdf.cell(180, 20, "GREENMIND AI", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
    
    # Subtitle
    pdf.ln(5)
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 10, "Smart Plant Disease Detection & Botanical Decision Support System", 
             new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
    
    pdf.ln(5)
    pdf.set_font('Helvetica', 'I', 14)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 10, "RESEARCH PROJECT PROPOSAL", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
    
    # Metadata Box at bottom
    pdf.ln(25)
    pdf.set_fill_color(232, 245, 233)  # Light green fill
    pdf.set_draw_color(46, 125, 50)
    pdf.set_line_width(0.5)
    
    # Draw metadata panel
    pdf.rect(30, 205, 150, 50, 'FD')
    
    pdf.set_xy(35, 210)
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(40, 7, "Research Field:", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(50, 50, 50)
    pdf.cell(0, 7, "Agronomic AI, Computer Vision & Expert Systems", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    pdf.set_x(35)
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(40, 7, "Project Duration:", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(50, 50, 50)
    pdf.cell(0, 7, "36 Months (3-Year Phased Timeline)", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    pdf.set_x(35)
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(40, 7, "Proposed For:", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(50, 50, 50)
    pdf.cell(0, 7, "National Agricultural R&D Grant Initiative", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    pdf.set_x(35)
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(40, 7, "Date of Proposal:", new_x=XPos.RIGHT, new_y=YPos.TOP)
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(50, 50, 50)
    pdf.cell(0, 7, "June 11, 2026", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    # ---------------- PAGE 2: INTRODUCTION & REVIEW ----------------
    pdf.add_page()
    
    # Project Title
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 7, "i) Project Title", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    
    pdf.set_font('Helvetica', 'I', 11)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 5, "GreenMind AI: A Hybrid Deep Learning and Generative AI Ecosystem for Real-time Plant Disease Detection and Botanical Decision Support.", new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(3)
    
    # Introduction Header
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 7, "ii) Introduction", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    
    # Sub-heading: Origin of the research problem
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(46, 125, 50)
    pdf.cell(0, 6, "1. Origin of the Research Problem", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    intro_p1 = (
        "Global agricultural production and local home gardening face severe threats from plant pathogens. "
        "According to the FAO, plant diseases and pests destroy 20% to 40% of global crop yields annually, costing "
        "the world economy over $220 billion. Early identification is key to mitigating spread, yet access "
        "to expert botanists or plant pathologists is highly restricted, particularly in rural and developing regions. "
        "Existing mobile plant care applications rely on static databases and stand-alone classification models. "
        "While they can label a disease, they fail to provide customized, context-aware care guidelines or engage "
        "in interactive Q&A. This leads to user frustration, misapplication of chemical treatments, and high "
        "abandonment rates. GreenMind AI originates from the need to bridge this gap by offering a hybrid "
        "framework that pairs instant classification with the deep reasoning of Generative AI."
    )
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(intro_p1), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(2)
    
    # Sub-heading: Interdisciplinary relevance
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(46, 125, 50)
    pdf.cell(0, 6, "2. Interdisciplinary Relevance", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    intro_p2 = (
        "This research is highly interdisciplinary, merging four critical pillars:\n"
        "- Phytopathology: Analyzing crop-specific pathogens, symptoms, and care models.\n"
        "- Computer Vision: Designing and training highly optimized CNNs for leaf disease classification.\n"
        "- Natural Language Processing: Employing Large Language Models to generate tailored botanical care plans.\n"
        "- Systems Engineering: Implementing secure mobile applications and serverless FastAPI backends."
    )
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(intro_p2), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(2)
    
    # Sub-heading: Review of R&D
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(46, 125, 50)
    pdf.cell(0, 6, "3. Review of Research and Development in the Subject", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 5, "   A. International Status", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    intl_status = (
        "Globally, researchers have leveraged deep learning architectures (like ResNet, MobileNet, and EfficientNet) "
        "trained on the public PlantVillage dataset (54,000+ images) to classify crop leaf diseases. International commercial "
        "apps like Plantix have successfully deployed CNN models for remote detection. However, these systems operate as "
        "closed-source diagnostic silos. They do not utilize Generative AI for customized conversation, nor do they "
        "support context-aware parameters such as weather forecasts or custom soil properties during treatment planning."
    )
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(intl_status), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(2)
    
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 5, "   B. National Status", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    nat_status = (
        "In India, digital platforms such as mKisan and e-NAM provide general agricultural advisories, but "
        "lack instant, image-based plant diagnostics. While regional universities have trained CNNs on local crop varieties "
        "(such as paddy, wheat, and cotton), their deployments are often heavy web services with high latencies. There is a "
        "clear absence of mobile-first, low-bandwidth solutions that translate predictions into natural, localized languages "
        "with automated PDF reporting."
    )
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(nat_status), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    pdf.ln(2)
    
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 5, "   C. Significance of the Study", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    significance = (
        "GreenMind AI overcomes these limitations by combining a lightweight convolutional neural network with "
        "generative large language models. The custom model classifies leaf diseases with high speed, and the backend "
        "LLM translates the diagnostic label into a complete treatment plan. The study introduces a fully automated "
        "reporting system that formats plant diagnostics into styled, professional PDFs, making expert agricultural "
        "knowledge accessible to anyone with a smartphone."
    )
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(significance), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    # ---------------- PAGE 3: OBJECTIVES & METHODOLOGY ----------------
    pdf.add_page()
    
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 8, "iii) Objectives of the Project", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.ln(1)
    
    draw_bullet_point(pdf, "O1: Deep Learning Classification: ", "Train and optimize a lightweight CNN model (MobileNetV2 backbone) targeting 38 crop-disease pairs to achieve >92% classification accuracy.")
    draw_bullet_point(pdf, "O2: Hybrid AI Inference: ", "Implement a service-oriented backend that orchestrates image classification via the CNN and feeds the outputs to GPT-4o to construct a tailored care script.")
    draw_bullet_point(pdf, "O3: Cross-platform Mobile Client: ", "Develop a modern, animated Flutter app supporting offline caching, real-time diagnostic history sync, and interactive chat support.")
    draw_bullet_point(pdf, "O4: Automated PDF Dispatch: ", "Build a serverless FPDF2 reporting engine and SMTP mail pipeline to automatically compile and email plant health records to users.")
    draw_bullet_point(pdf, "O5: Scalable Cloud Architecture: ", "Establish a serverless FastAPI backend on Vercel connected to Supabase for secure authentication, history database storage, and file hosting.")
    
    pdf.ln(3)
    
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 8, "iv) Methodology", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.ln(1)
    
    methodology_text = (
        "The project follows a modular, service-oriented system design. The core methodology is split into four phases:\n\n"
        "1. Data Curation & CNN Model Training:\n"
        "Gather and clean agricultural leaf images (PlantVillage dataset + field collections). Conduct augmentations "
        "(rotation, shear, brightness shift) to avoid overfitting. Train a TensorFlow MobileNetV2 classifier. Export "
        "the model to a compact format for fast inference.\n\n"
        "2. Hybrid Inference Pipeline (Dual-Layer Intelligence):\n"
        "When a user uploads a leaf image, the FastAPI backend routes it to the CNN classifier. If the confidence is "
        "above 70%, the backend triggers the GPT-4o API, providing it with the crop name, identified disease, confidence, "
        "and metadata. GPT-4o then compiles the possible cause and detailed treatment plan.\n\n"
        "3. Cross-Platform App & Real-Time Sync:\n"
        "Build a Flutter mobile client incorporating provider-based state management. Store history locally using sqlite "
        "or hive. Synchronize records automatically with Supabase (PostgreSQL) when an active internet connection is detected. "
        "Provide text-to-speech (TTS) features for accessibility.\n\n"
        "4. Automated PDF & SMTP Dispatch:\n"
        "A background task compiles the diagnosis and treatment plan. A class inheriting from FPDF formats the text, "
        "appends branding, and generates a PDF document. The SMTP client then dispatches this PDF directly to the user's email."
    )
    pdf.set_font('Helvetica', '', 9.5)
    pdf.set_text_color(50, 50, 50)
    pdf.multi_cell(0, 4.6, sanitize_for_pdf(methodology_text), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
    
    # ---------------- PAGE 4: PLAN OF WORK & PERT CHART ----------------
    pdf.add_page()
    
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 8, "v) Year wise Plan of Work & Targets", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.ln(1)
    
    # Draw table
    # Column widths: 18, 124, 38
    pdf.set_draw_color(46, 125, 50)
    pdf.set_line_width(0.3)
    
    # Header Row
    pdf.set_fill_color(46, 125, 50)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font('Helvetica', 'B', 9)
    pdf.cell(18, 7, "Task ID", border=1, align='C', fill=True)
    pdf.cell(124, 7, "Milestone / Target Deliverable", border=1, align='L', fill=True)
    pdf.cell(38, 7, "Timeline", border=1, new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C', fill=True)
    
    # Data Rows
    table_data = [
        ("P1.1", "Dataset curation and plant leaf image preprocessing", "Months 1-3"),
        ("P1.2", "CNN model architecture design, training, and testing", "Months 4-7"),
        ("P1.3", "FastAPI backend architecture and Supabase database setup", "Months 8-12"),
        ("P2.1", "Flutter app core UI development and camera module integration", "Months 13-16"),
        ("P2.2", "Hybrid dual-inference engine (CNN + GPT API) integration", "Months 17-20"),
        ("P2.3", "FPDF2-based automated PDF reporting engine and SMTP setup", "Months 21-24"),
        ("P3.1", "End-to-end client-server integration and local testing", "Months 25-28"),
        ("P3.2", "Field trials with local farming cooperatives and users", "Months 29-32"),
        ("P3.3", "Retraining model on field data, security audit, and release", "Months 33-36")
    ]
    
    pdf.set_font('Helvetica', '', 8.5)
    pdf.set_text_color(50, 50, 50)
    for idx, (tid, desc, timeline) in enumerate(table_data):
        # Shading alternate rows
        if idx % 2 == 0:
            pdf.set_fill_color(255, 255, 255)
        else:
            pdf.set_fill_color(232, 245, 233)
            
        pdf.cell(18, 6.0, tid, border=1, align='C', fill=True)
        pdf.cell(124, 6.0, sanitize_for_pdf(desc), border=1, align='L', fill=True)
        pdf.cell(38, 6.0, timeline, border=1, new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C', fill=True)
        
    pdf.ln(4)
    
    # Embed PERT Chart Image
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 7, "PERT Network Diagram (36-Month Project Path)", 
             new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    
    if os.path.exists(pdf.pert_path):
        pdf.image(pdf.pert_path, 15, pdf.get_y() + 1, 180, 85)
    else:
        pdf.set_font('Helvetica', 'I', 10)
        pdf.set_text_color(150, 50, 50)
        pdf.cell(0, 10, "PERT Network Diagram image not found.", 
                 new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
        
    # ---------------- PAGE 5: FINANCIAL ESTIMATES / BUDGET ----------------
    pdf.add_page()
    
    pdf.set_font('Helvetica', 'B', 13)
    pdf.set_text_color(27, 94, 32)
    pdf.cell(0, 8, "vi) Financial Estimates / Budget", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='L')
    pdf.ln(2)
    
    # Draw table headers
    # Column widths: 15, 120, 45 -> total 180 (matches margins of 15 left/right on A4 210 width)
    pdf.set_fill_color(46, 125, 50)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.cell(15, 8, "Sr. No.", border=1, align='C', fill=True)
    pdf.cell(120, 8, "Items", border=1, align='L', fill=True)
    pdf.cell(45, 8, "Est. Expenditure (INR)", border=1, new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C', fill=True)
    
    # Budget data
    budget_data = [
        ("i", "Hiring Services", "0"),
        ("ii", "Field Work & Travel", "7,000"),
        ("iii", "Chemical & Glassware", "0"),
        ("iv", "Contingency (Including special needs)", "10,000"),
        ("v", "Books and Journals", "15,000"),
        ("vi", "Software Licenses / Cloud Services", "8,000"),
        ("vii", "Dataset Collection & Data Annotation", "5,000"),
        ("viii", "Computer Peripherals & Storage Devices", "6,000"),
        ("ix", "Internet & Communication Charges", "3,000"),
        ("x", "Project Demonstration & Prototype Development", "6,000"),
        ("xi", "Miscellaneous (Printing, Documentation)", "5,000"),
    ]
    
    pdf.set_font('Helvetica', '', 9)
    pdf.set_text_color(50, 50, 50)
    for idx, (sr, item, cost) in enumerate(budget_data):
        # Shading alternate rows
        if idx % 2 == 0:
            pdf.set_fill_color(255, 255, 255)
        else:
            pdf.set_fill_color(232, 245, 233)
            
        pdf.cell(15, 6.5, sr, border=1, align='C', fill=True)
        pdf.cell(120, 6.5, sanitize_for_pdf(item), border=1, align='L', fill=True)
        pdf.cell(45, 6.5, cost, border=1, new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C', fill=True)
        
    # Total row
    pdf.set_fill_color(46, 125, 50)
    pdf.set_text_color(255, 255, 255)
    pdf.set_font('Helvetica', 'B', 9.5)
    pdf.cell(15, 7.5, "Total", border=1, align='C', fill=True)
    pdf.cell(120, 7.5, "Total in INR", border=1, align='L', fill=True)
    pdf.cell(45, 7.5, "65,000", border=1, new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C', fill=True)
    
    # Output file path
    output_pdf_path = r"e:\GreenMind al\docs\GreenMind_AI_Research_Proposal.pdf"
    pdf.output(output_pdf_path)
    print(f"Proposal PDF generated successfully at: {output_pdf_path}")

if __name__ == '__main__':
    build_pdf()
