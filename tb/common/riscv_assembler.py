import re

def parse_register(reg):
    return int(reg.replace('x', ''))

def parse_offset(offset):
    # Parse offset like "8(x13)" to (8, 13)
    match = re.match(r'(-?\d+)\(x(\d+)\)', offset)
    if match:
        return int(match.group(1)), int(match.group(2))
    return None

def generate_r_type(funct7, rs2, rs1, funct3, rd, opcode):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def generate_i_type(imm, rs1, funct3, rd, opcode):
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def generate_s_type(imm, rs2, rs1, funct3, opcode):
    imm_11_5 = (imm & 0xFE0) >> 5
    imm_4_0 = imm & 0x1F
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

def generate_b_type(imm, rs2, rs1, funct3, opcode):
    imm_12 = (imm & 0x1000) >> 12
    imm_11 = (imm & 0x800) >> 11
    imm_10_5 = (imm & 0x7E0) >> 5
    imm_4_1 = (imm & 0x1E) >> 1
    return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
           (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode

def generate_j_type(imm, rd, opcode):
    imm_20 = (imm & 0x100000) >> 20
    imm_19_12 = (imm & 0xFF000) >> 12
    imm_11 = (imm & 0x800) >> 11
    imm_10_1 = (imm & 0x7FE) >> 1
    return (imm_20 << 31) | (imm_10_1 << 21) | (imm_11 << 20) | \
           (imm_19_12 << 12) | (rd << 7) | opcode

# RISC-V Opcodes and Function Codes
OPCODES = {
    'add':  0b0110011,  # R-type
    'sub':  0b0110011,
    'and':  0b0110011,
    'addi': 0b0010011,  # I-type
    'lw':   0b0000011,
    'sw':   0b0100011,  # S-type
    'beq':  0b1100011,  # B-type
    'blt':  0b1100011,
    'jal':  0b1101111,  # J-type
    'nop':  0b0010011,  # addi x0, x0, 0
    'ret':  0b1100111   # jalr x0, x1, 0
}

FUNCT3 = {
    'add':  0b000,
    'sub':  0b000,
    'and':  0b111,
    'addi': 0b000,
    'lw':   0b010,
    'sw':   0b010,
    'beq':  0b000,
    'blt':  0b100,
    'jalr': 0b000
}

FUNCT7 = {
    'add':  0b0000000,
    'sub':  0b0100000,
    'and':  0b0000000
}

class Assembler:
    def __init__(self):
        self.labels = {}
        self.current_address = 0
        self.instructions = []

    def first_pass(self, lines):
        current_address = 0
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#') or line.startswith('.'):
                continue
            if line.endswith(':'):  # Label
                label = line[:-1].strip()
                self.labels[label] = current_address
            else:
                current_address += 4  # Each instruction is 4 bytes

    def assemble_instruction(self, instruction, address):
        parts = instruction.split()
        op = parts[0]
        args = [arg.strip(',') for arg in parts[1:]]

        if op in ['add', 'sub', 'and']:  # R-type
            rd, rs1, rs2 = map(parse_register, args)
            return generate_r_type(FUNCT7[op], rs2, rs1, FUNCT3[op], rd, OPCODES[op])

        elif op in ['addi']:  # I-type
            rd, rs1 = map(parse_register, args[:2])
            imm = int(args[2])
            return generate_i_type(imm, rs1, FUNCT3[op], rd, OPCODES[op])

        elif op == 'lw':  # I-type load
            rd = parse_register(args[0])
            offset, rs1 = parse_offset(args[1])
            return generate_i_type(offset, rs1, FUNCT3[op], rd, OPCODES[op])

        elif op == 'sw':  # S-type
            rs2 = parse_register(args[0])
            offset, rs1 = parse_offset(args[1])
            return generate_s_type(offset, rs2, rs1, FUNCT3[op], OPCODES[op])

        elif op in ['beq', 'blt']:  # B-type
            rs1, rs2 = map(parse_register, args[:2])
            label = args[2]
            imm = self.labels[label] - address
            return generate_b_type(imm, rs2, rs1, FUNCT3[op], OPCODES[op])

        elif op == 'jal':  # J-type
            rd = parse_register(args[0])
            label = args[1]
            imm = self.labels[label] - address
            return generate_j_type(imm, rd, OPCODES[op])

        elif op == 'nop':
            return generate_i_type(0, 0, FUNCT3['addi'], 0, OPCODES['addi'])

        elif op == 'ret':  # Special case - jalr x0, x1, 0
            return generate_i_type(0, 1, FUNCT3['jalr'], 0, OPCODES['ret'])

def generate_memory_file(input_file, output_file):
    assembler = Assembler()
    
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    # First pass: collect labels
    assembler.first_pass(lines)
    
    # Second pass: generate machine code
    machine_code = []
    current_address = 0
    
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#') or line.startswith('.') or line.endswith(':'):
            continue
            
        try:
            instruction = assembler.assemble_instruction(line, current_address)
            machine_code.append((current_address, f"{instruction:032b}"))
            current_address += 4
        except Exception as e:
            print(f"Error assembling instruction: {line}")
            print(f"Error: {str(e)}")
            continue

    # Write memory file
    with open(output_file, 'w') as f:
        for addr, code in machine_code:
            f.write(f"@{addr:08x} {code}\n")

if __name__ == "__main__":
    generate_memory_file('riscv_program_test1.s', 'instruction_memory.mem')