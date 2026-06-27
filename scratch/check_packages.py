import sys

packages = ["fpdf", "matplotlib", "PIL", "reportlab", "graphviz", "pandas"]
for pkg in packages:
    try:
        __import__(pkg)
        print(f"Package '{pkg}' is available.")
    except ImportError:
        print(f"Package '{pkg}' is NOT available.")
