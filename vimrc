" Installed packages:
"	NERDTree - show a traversable project directory
"   syntastic - syntax checking on save,close etc
call pathogen#infect()

" Fix backspace not going over linebreaks or place where indent started
set backspace=indent,eol,start

" Appearance
set rnu
set nu
syntax on
highlight ColorColumn ctermbg=237 guibg=#2c2d27
let &colorcolumn="81"
set background=dark

" Text wrapping, auto indenting
set textwidth=80
set autoindent
set smartindent

" Tab details
set tabstop=4
set softtabstop=4 
set shiftwidth=4
set expandtab 
set fileformat=unix

" Shortcuts
let mapleader = " "
" Movement between panes
nmap <leader>j <C-w><C-j>
nmap <leader>k <C-w><C-k>
nmap <leader>h <C-w><C-h>
nmap <leader>l <C-w><C-l>
nmap <leader>kb :NERDTree<ENTER> 
"	NOW DELETED: YouCompleteMe-specific python shortcuts
"let g:ycm_autoclose_preview_window_after_completion=1
"map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" YouCompleteMe correct virtualenv behaviour (looks for correct package
" autocompletes)
"py << EOF
"import os
"import sys
"if 'VIRTUAL_ENV' in os.environ:
	"project_base_dir = os.environ['VIRTUAL_ENV']
	"activate_this = os.path.join(project_base_dir,
	"'bin/activate_this.py')
	"execfile(activate_this, dict(__file__=activate_this))
"EOF

" Syntactic default settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Load project vimrc if it exists
set exrc
