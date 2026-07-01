# pad_hex.py
original = "program.hex"
padded = "padded_program.hex"
target_size = 65536  # 64KB memory

with open(original, 'r') as f:
    lines = [l.strip() for l in f if l.strip()]

with open(padded, 'w') as f:
    # Write original program
    for line in lines:
        f.write(line.split('//')[0].strip() + '\n')  # Remove comments
    # Pad with zeros
    for _ in range(len(lines), target_size):
        f.write("0000\n")
print(f"Created {padded} with {target_size} lines")