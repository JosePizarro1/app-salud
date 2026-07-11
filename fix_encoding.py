import subprocess, os, sys

# Get raw bytes from git ls-tree
result = subprocess.run(['git', 'ls-tree', '-r', 'HEAD', '--name-only'], capture_output=True)
text = result.stdout.decode('utf-8')
all_files = text.strip().split('\n')

problem_files = []
for f in all_files:
    raw = f.encode('utf-8')
    if any(b > 127 for b in raw) or '???' in f:
        problem_files.append(f)

print(f"Found {len(problem_files)} problem files")

for f in problem_files:
    result = subprocess.run(['git', 'show', f'HEAD:{f}'], capture_output=True)
    if result.returncode != 0:
        print(f"GIT FAIL: {f}")
        continue

    try:
        dirpath = os.path.dirname(f)
        if dirpath:
            os.makedirs(dirpath, exist_ok=True)
        encoded_path = f.encode('utf-8')
        with open(encoded_path, 'wb') as out:
            out.write(result.stdout)
        print(f"OK: {f}")
    except Exception as e:
        print(f"WRITE FAIL: {f} -> {e}")
        # Create safe version
        safe = f.replace('\u00d3','O').replace('\u00f3','o').replace('\u00d1','N').replace('\u00f1','n')
        try:
            dirpath = os.path.dirname(safe)
            if dirpath:
                os.makedirs(dirpath, exist_ok=True)
            with open(safe.encode('utf-8'), 'wb') as out:
                out.write(result.stdout)
            print(f"  -> saved as: {safe}")
        except Exception as e2:
            print(f"  -> DOUBLE FAIL: {safe} -> {e2}")

# Now verify what's still missing
print("\n--- Checking remaining missing files ---")
git_result = subprocess.run(['git', 'ls-tree', '-r', 'HEAD', '--name-only'], capture_output=True)
git_text = git_result.stdout.decode('utf-8')
git_files = git_text.strip().split('\n')

missing = []
for f in git_files:
    try:
        if not os.path.exists(f.encode('utf-8')):
            missing.append(f)
    except:
        missing.append(f)

if missing:
    print(f"Still missing {len(missing)} files:")
    for m in missing:
        print(f"  {m}")
else:
    print("All files present!")
