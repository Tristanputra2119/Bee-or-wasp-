

import zipfile
import json
from pathlib import Path

MODEL_PATH = Path(__file__).parent.parent / "model" / "model_serangga.keras"

print("Extracting model configuration...")
with zipfile.ZipFile(MODEL_PATH, 'r') as zip_ref:
    # Read config.json
    with zip_ref.open('config.json') as f:
        config = json.load(f)
    
    # Read metadata.json  
    with zip_ref.open('metadata.json') as f:
        metadata = json.load(f)

print("\n=== METADATA ===")
print(json.dumps(metadata, indent=2))

print("\n=== MODEL CONFIG ===")
print(json.dumps(config, indent=2))
