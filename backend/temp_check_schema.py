import os
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)

try:
    res = supabase.table("scans").select("*").limit(1).execute()
    if res.data:
        print("Record columns:", list(res.data[0].keys()))
        print("Sample data:", res.data[0])
    else:
        print("No scans found in database, table is empty.")
except Exception as e:
    print("Error querying scans table:", e)
