import sys
import subprocess
import os
import re

win_arcadia_exe_path = 'WinArcadia.exe'
asm32_exe_path = 'asm32.exe'

asm_files = {}
branch_instructions = {}

def load_asm_file( asm_file_path ):

    global asm_files

    if asm_file_path in asm_files:
        #既に読んだファイル
        return
        
    asm_file = open(asm_file_path,'rb').readlines()

    asm_files[asm_file_path] = asm_file
    branch_instructions[asm_file_path] = []

    def remove_comment( line ):
        semicolon = line.find(b';')
        if semicolon >= 0:
            return line[0:semicolon].strip()
        return line

    prev_mnemonics = None
    prev_mnemonics_line = None

    remove_line_indices = []

    for index in range(len(asm_file)):
        line = asm_file[index]

        code = remove_comment(line.strip().lower())
        if len(code) <= 0:
            continue
        
        mnemonics = [ x.strip() for x in re.split(b'[,\s\t]', code) ]
        mnemonics = [ x for x in mnemonics if len(x) > 0 ]

        if len(mnemonics) >= 2 and mnemonics[0] == b'include':
            
            include_path = mnemonics[1][1:-1]
            
            if os.path.exists(include_path):
                #再帰的にチェック
                load_asm_file(include_path)

        if len(mnemonics) >= 2 and len(mnemonics[0]) == 4 and \
            has_instruction_with_relative_and_absolute(mnemonics[0][0:3]) and\
            mnemonics[0][-1:].lower() == b'a':
            #絶対アドレスの分岐命令
            branch_instructions[asm_file_path].append(index)

        #lodi,r0 0 があったらeorz r0に修正
        if len(mnemonics) >= 3 and \
            mnemonics[0].lower() == b'lodi' and mnemonics[1].lower() == b'r0' and \
            (mnemonics[2] == b'0' or mnemonics[2].lower() == b'0h' or mnemonics[2].lower() == b'$0'):
            i = line.lower().index(b'l')
            e = b'eorz r0'
            c = line.find(b';')
            last = b'\r\n' if c < 0 else (b' ' * (c-i-len(e)) + line[c:])
            asm_file[index] = line[0:i] + e + last

        #条件なしのretcの手前に条件なしのbsxx命令がある. retcを消して,bsをbcに変更する
        if b'retc,un' in line.lower() and prev_mnemonics is not None and \
           prev_mnemonics[0][0:2].lower() == b'bs' and prev_mnemonics[1].lower() == b'un':

           remove_line_indices.append(index)

           prev = bytearray(asm_file[prev_mnemonics_line])
           prev[prev.lower().index(b'bs')+1] += ord(b'c') - ord(b's')
           asm_file[prev_mnemonics_line] = bytes(prev)
           
        prev_mnemonics_line = index
        prev_mnemonics = mnemonics

    for i in reversed(remove_line_indices):
        asm_file.pop(i)
    
    return

def get_count_error( asm_file_path ):

    subprocess.run([asm32_exe_path, asm_file_path, '-qer'], stdout=subprocess.PIPE )

    lst_file_path = os.path.splitext(os.path.basename(asm_file_path))[0] + ".lst"
    lst_file = open(lst_file_path,'rb').readlines()

    errors = 0

    for index in range(len(lst_file)):
        line = lst_file[index]
        if b'** ERROR **' in line or b'** WARNING **' in line:
            errors += 1

    return errors

def is_r(i):
    return ord('r') == i or ord('R') == i

def is_a(i):
    return ord('a') == i or ord('A') == i

relative_and_absolute_instructions = set([
    b'lod',
    b'str',
    b'add',
    b'sub',
    b'ior',
    b'eor',
    b'and',
    b'bct',
    b'bcf',
    b'brn',
    b'bir',
    b'bdr',
    b'bst',
    b'bsf',
    b'bsn',
    b'com',
])

def has_instruction_with_relative_and_absolute( line ):
    line = line.strip().lower()
    return len(line) >= 3 and bytes(line[0:3]) in relative_and_absolute_instructions

def r_to_a( line ):
    line = bytearray(line)
    for i in range(len(line)-3):
        if has_instruction_with_relative_and_absolute(line[i:i+3]) and is_r(line[i+3]):
            line[i+3] += ord('a') - ord('r')
            break
    return bytes(line)

def a_to_r( line ):
    line = bytearray(line)
    for i in range(len(line)-3):
        if has_instruction_with_relative_and_absolute(line[i:i+3]) and is_a(line[i+3]):
            line[i+3] += ord('r') - ord('a')
            break
    return bytes(line)

def optimize( main_asm_file_path, target_asm_file_path ):

    lines = asm_files[target_asm_file_path]

    #命令末尾のaをrに変更してコンパイルしてみる
    for branch_index in branch_instructions[target_asm_file_path]:
        #相対分岐に直す
        lines[branch_index] = a_to_r(lines[branch_index])
        open(target_asm_file_path,'wb').writelines(lines)

        if get_count_error(main_asm_file_path) > 0:
            #エラーになったので元に戻す
            lines[branch_index] = r_to_a(lines[branch_index])
            open(target_asm_file_path,'wb').writelines(lines)

def main():
    if len(sys.argv) <= 1:
        print('python optasm.py [target_asm_path]')
        print('!!! .asmファイルを上書きするので取り扱い注意 !!!')
        exit(-1)
    
    asm_file_path = sys.argv[1]

    if not os.path.exists(asm_file_path):
        print(f'Not found {asm_file_path}')
        exit(-1)

    load_asm_file(asm_file_path)

    if get_count_error(asm_file_path) > 0:
        print('初期状態でエラーがあります.')
        exit(-2)
    
    for opt_asm_file_path in asm_files:
        #continue
        optimize(asm_file_path, opt_asm_file_path)

if __name__ == '__main__':
    main()