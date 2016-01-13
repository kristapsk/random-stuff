silent! execute pathogen#infect()

set nocp
set expandtab
set shiftwidth=4
set tabstop=4
set autoindent

silent! colorscheme darkblue

if has("gui_running")
    set number
endif

set noswapfile

set visualbell

cnoremap sudow w !sudo tee % >/dev/null

