" Insert equation as gif file autogenerated by `latex.codecogs.com`.
" Author: HE Chong


if (exists('b:md_equation_insert_loaded'))
    finish
endif

let b:md_equation_insert_loaded = 1

py import vim

" Trim input_string before query
function! s:Input_Process(input_string)
    let l:str = substitute(a:input_string, '\s', '\\ ', 'g')
    return l:str 
endfunction

python<<endOfPython
def md_ee_reverse_escape(input_string):
    output_prepare = input_string.replace(u'\ ', u' ')
    output_prepare = output_prepare.replace(u'\\\\', u'\\')
    return output_prepare

def md_ee_char_escape(input_string):
    output_prepare = input_string.replace(u'\\', u'\\\\')
    output_prepare = output_prepare.replace(u' ', u'\ ')
    return output_prepare

def md_edit_equation():
    web_api = u'http://latex.codecogs.com/gif.latex?'
    cursor = vim.current.window.cursor
    line = vim.current.buffer[cursor[0] - 1].decode(u'utf-8')
    # original format
    old_format = False
    start = line.rfind(u'![](', 0, cursor[1])
    if start == -1:
        start = line.rfind(u'![](', 0, cursor[1] + 4)
    if start != -1:
        old_format = True
    # new format
    if start == -1:
        start = line.rfind(u'![eqn](', 0, cursor[1])
    if start == -1:
        start = line.rfind(u'![eqn](', 0, cursor[1] + 7)
    p_left=1
    end = -1
    if start != -1:
        for char in zip(range(len(line)),line)[start+(4 if old_format else 7):]:
            if char[1]==u'(':
                p_left+=1
            elif char[1]==u')':
                p_left-=1
            if p_left==0:
                end = char[0]
                break
    content = ""
    md_insert_new_equation = False
    if start==-1 or end==-1:
        md_insert_new_equation = True
    else:
        content = md_ee_reverse_escape(line[start+(4 if old_format else 7):end].replace(web_api,''))
    new_equation = vim.eval("input('Type the equation(in latex format):\n', \"{}\")".format(content.replace('\\','\\\\')))
    if md_insert_new_equation:
        if not new_equation:
            return
        vim.command('normal! i![eqn]('+web_api+md_ee_char_escape(new_equation)+')')
    else:
        if not new_equation:
            vim.command('echom "Detect empty equation input, quitting"')
            return
        line=line[:start]+'![eqn]('+web_api+md_ee_char_escape(new_equation)+line[end:]
        vim.current.buffer[cursor[0] - 1] = line
endOfPython


function! s:edit_equation()
    py md_edit_equation()
endfunction

command! EditEquation :call <SID>edit_equation()

nnoremap <unique><silent><buffer> <localleader>ee :call <SID>edit_equation()<CR>
