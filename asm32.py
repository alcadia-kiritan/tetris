import sys
import subprocess
import os
import re

win_arcadia_exe_path = 'WinArcadia.exe'
asm32_exe_path = 'asm32.exe'

def check_asm_file( asm_file_path ):
    asm_file = open(asm_file_path,'rb').readlines()

    def remove_comment( line ):
        semicolon = line.find(b';')
        if semicolon >= 0:
            return line[0:semicolon].strip()
        return line

    for index in range(len(asm_file)):
        line = asm_file[index]

        code = remove_comment(line.strip().lower())
        if len(code) <= 0:
            continue
        
        mnemonics = [ x.strip() for x in re.split(b'[,\s\t]', code) ]
        mnemonics = [ x for x in mnemonics if len(x) > 0 ]

        position = F'** WARNING ** file: {asm_file_path} line:{index+1} '

        #命令本体とパラメータが３つ以上(オフセットの指定がある)
        #命令の末尾がa (=メモリアクセスを伴う)
        #パラメータの１個目がr0以外
        #equを使った定数定義ではない
        if len(mnemonics) >= 4 and mnemonics[0][-1:] == b'a' and mnemonics[1] != b'r0' and \
            mnemonics[1] != b'equ':

            print(position + 'オフセット付きのメモリアクセス命令の第1引数がr0以外です.')
            print('>>' + line.decode('utf-8'))
        
        #includeで存在しないファイルを指定していないかチェック.
        elif len(mnemonics) >= 2 and mnemonics[0] == b'include':
            
            include_path = mnemonics[1][1:-1]
            
            if os.path.exists(include_path):
                #再帰的にチェック
                check_asm_file(include_path)
            else:
                #ファイルが存在しない. 警告表示
                print(position + 'include対象のファイルがありません.')
                print('>>' + line.decode('utf-8'))

        #bsxa/bxa命令のパラメータ省略に対して警告を出す
        elif len(mnemonics) == 2 and ( mnemonics[0] == b'bsxa' or mnemonics[0] == b'bxa' ):
            print(position + 'bsxa/bxa命令にオフセット指定がありません. r3が使われます.')
            print('>>' + line.decode('utf-8'))
    
    return

def main():
    if len(sys.argv) <= 1:
        print('python asm32.py [target_asm_path]')
        exit(-1)
    
    asm_file_path = sys.argv[1]

    if not os.path.exists(asm_file_path):
        print(f'Not found {asm_file_path}')
        exit(-1)

    check_asm_file(asm_file_path)

    subprocess.run([asm32_exe_path, asm_file_path, '-qer'], stdout=subprocess.PIPE )

    lst_file_path = os.path.splitext(os.path.basename(asm_file_path))[0] + ".lst"
    lst_file = open(lst_file_path,'rb').readlines()

    has_error = False

    def normalize(bstr): 
        try:
            return bstr.decode('utf-8').rstrip()
        except UnicodeDecodeError as e:
            bstr = bstr[:e.start] + bstr[e.end:]
            try:
                return bstr.decode('utf-8').rstrip()
            except:
                pass
        return str(bstr)[2:-1]

    def print_line():
        print()
        prev = normalize(lst_file[index-1][0:-1])
        if '  -->' in prev:  
            #制御文字が混じってると余分な行が混じるのでそれを含めて表示
            print(normalize(lst_file[index-2][0:-1]))
        print(prev)
        print(normalize(line[0:-1]))

    for index in range(len(lst_file)):
        line = lst_file[index]

        if b'Error(s) in ' in line:
            print(normalize(line[0:-1]))
        
        if b'** ERROR **' in line:
            print_line()
            has_error = True

        if b'** WARNING **' in line:
            print_line()
        
        if b'Errors,' in line and b'Warnings.' in line:
            print(normalize(line[0:-1]))

    if has_error:
        exit(-1)

    print('Build completed!')
    
    if len(sys.argv) <= 2:
        bin_file_path = os.path.splitext(os.path.basename(asm_file_path))[0] + ".bin"
        print(f'Run {win_arcadia_exe_path} {bin_file_path}')
        subprocess.Popen([win_arcadia_exe_path, bin_file_path], stdout=subprocess.PIPE )
    
    

if __name__ == '__main__':
    main()