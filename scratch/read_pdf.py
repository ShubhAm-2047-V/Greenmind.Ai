import os

pdf_path = r"e:\GreenMind al\docs\GreenMind_AI_Comprehensive_Full_Report.pdf"
output_path = r"e:\GreenMind al\scratch\extracted_text.txt"

print(f"Checking PDF size: {os.path.getsize(pdf_path)} bytes")

import fitz # PyMuPDF
doc = fitz.open(pdf_path)
text = ""
print(f"Total pages: {len(doc)}")
for i in range(len(doc)):
    page = doc.load_page(i)
    page_text = page.get_text()
    text += f"\n--- Page {i+1} ---\n{page_text}\n"
    
with open(output_path, "w", encoding="utf-8") as f:
    f.write(text)
print("Extracted text successfully using fitz (PyMuPDF)")
