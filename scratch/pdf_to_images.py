import fitz # PyMuPDF
import os

pdf_path = r"e:\GreenMind al\docs\GreenMind_AI_Research_Proposal.pdf"
output_dir = r"e:\GreenMind al\scratch\proposal_pages"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

doc = fitz.open(pdf_path)
print(f"Total pages: {len(doc)}")

for i in range(len(doc)):
    page = doc.load_page(i)
    pix = page.get_pixmap(dpi=150)
    output_path = os.path.join(output_dir, f"page_{i+1}.png")
    pix.save(output_path)
    print(f"Saved page {i+1} to {output_path}")

print("PDF to images conversion completed.")
