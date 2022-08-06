import sys
import subprocess
import os

win_arcadia_exe_path = 'WinArcadia.exe'
asm32_exe_path = 'asm32.exe'

def main():
    if len(sys.argv) <= 1:
        print('python asm32.py [target_asm_path]')
        exit(-1)
    
    asm_file_path = sys.argv[1]

    if not os.path.exists(asm_file_path):
        print(f'Not found {asm_file_path}')
        exit(-1)

    subprocess.run([asm32_exe_path, sys.argv[1], '-qer'], stdout=subprocess.PIPE )

    lst_file_path = os.path.splitext(os.path.basename(asm_file_path))[0] + ".lst"
    lst_file = open(lst_file_path,'rb').readlines()

    has_error = False

    def normalize(bstr): 
        try:
            return bstr.decode('utf-8').rstrip()
        except UnicodeDecodeError as e:
            bstr = bstr[:e.start] + bstr[e.end:]
            return bstr.decode('utf-8').rstrip()
        except:
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