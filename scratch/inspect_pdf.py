import fitz # PyMuPDF

pdf_path = r"e:\GreenMind al\docs\GreenMind_AI_Research_Proposal.pdf"
doc = fitz.open(pdf_path)

for i in range(len(doc)):
    page = doc.load_page(i)
    text = page.get_text().strip()
    print(f"--- Page {i+1} ---")
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    for line in lines[:8]:
        print(f"  {line}")
    print("  ...")
    for line in lines[-3:]:
        print(f"  {line}")
    print("-" * 20)
