import os

def fix_encoding(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".py"):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'rb') as f:
                        content = f.read()
                    if b'\x00' in content:
                        print(f"Fixing {filepath}")
                        # Decode as utf-16le and encode as utf-8
                        # Replace error character to avoid crashing
                        text = content.decode('utf-16le', errors='replace')
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(text)
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")

if __name__ == "__main__":
    fix_encoding("app")
    fix_encoding(".") # Also check main.py just in case
