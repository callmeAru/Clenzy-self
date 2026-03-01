def test_url_transformation(url):
    if url.startswith("postgres://"):
        transformed = url.replace("postgres://", "postgresql://", 1)
        return transformed
    return url

# Test cases
urls = [
    "postgres://user:pass@host:5432/db",
    "postgresql://user:pass@host:5432/db",
    "http://example.com"
]

for u in urls:
    print(f"Original: {u}")
    print(f"Transformed: {test_url_transformation(u)}")
    print("-" * 20)
