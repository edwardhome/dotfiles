" ==============================================================================
" 1. 外掛管理 (vim-plug)
" ==============================================================================
if has('win32') || has('win64')
    " Windows 專用路徑
    call plug#begin(expand('$HOME/vimfiles/plugged'))
else
    " macOS / Linux 路徑
    call plug#begin('~/.vim/plugged')
endif

  " --- 主題與外觀 ---
  Plug 'edwardhome/onedark.vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " --- 導航與搜尋 ---
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " --- 代碼補全與語法 ---
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-surround'
  Plug 'jiangmiao/auto-pairs'

  " --- Git 整合 ---
  Plug 'tpope/vim-fugitive'

  " --- 中文整合相關 mac 專用 ---
  Plug 'rlue/vim-barbaric'

  " 左側檔案總管
  Plug 'preservim/nerdtree'

  " 右側大綱追蹤
  Plug 'preservim/tagbar'

  " OSC 52 跨 SSH 剪貼簿
  Plug 'ojroques/vim-oscyank'

call plug#end()

" ==============================================================================
" 2. 基礎優化與介面設定
" ==============================================================================
set termguicolors
colorscheme onedark
let g:airline#extensions#tabline#enabled = 1     " 開啟上方 Tabline
let g:airline#extensions#tabline#fnamemod = ':t' " 只顯示檔名，不顯示長路徑
let g:airline_theme='onedark'

syntax on                   " 開啟語法高亮
filetype plugin indent on   " 自動識別檔案類型並載入對應插件與縮進
let mapleader = "\<Space>"  " 定義 Leader 鍵

" --- 持久化撤銷 (Undo) 安全檢查 ---
if !isdirectory(expand("~/.vim/undo"))
    call mkdir(expand("~/.vim/undo"), "p")
endif
set undofile
set undodir=~/.vim/undo

" --- 介面與操作優化 ---
set number
set relativenumber          " 相對行號，配合 5j, 10k 使用
set cursorline              " 高亮當前行
set wrap                    " 自動換行
set showcmd                 " 顯示指令
set updatetime=300          " 加速回應
set scrolloff=5             " 捲動時光標上下保留 5 行空間

" --- 縮進與搜尋 ---
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
set ignorecase
set smartcase
" ==============================================================================
" " 3. 剪貼簿與 OSC 52 SSH 穿透設定 (保留 Vim 原生暫存器哲學)
" "
" ==============================================================================
" " 清空 clipboard，維持 Vim 原生暫存器 ("1, "2, "a 等) 不受干擾
set clipboard=
"
"" 避免 system() 生成實體 /tmp 暫存檔改走 Pipe，防止 E282 權限錯誤
set noshelltemp

" 最大允許傳送 100,000 字元
let g:oscyank_max_length = 100000

" ==============================================================================
" 3. 剪貼簿與 OSC 52 SSH 穿透設定 (保留 Vim 原生暫存器哲學)
" ==============================================================================
" 清空 clipboard，確保預設 y, d, c, p 完全使用 Vim 原生暫存器 ("1p, "2p, "ay, "ap)
set clipboard=

" 最大允許傳送 100,000 字元
let g:oscyank_max_length = 100000
let g:oscyank_silent = 1

" --- 精準映射：複製並觸發 OSC 52 穿透 ---
" Visual Mode: 選取後按下 "+y 或 <Leader>y，寫入 + 暫存器並觸發 OSC 52 傳回地端
vnoremap "+y "+y:<C-u>OSCYankVisual<CR>
vnoremap <Leader>y "+y:<C-u>OSCYankVisual<CR>

" Normal Mode: 配合 motion（如 <Leader>yip 複製段落），寫入 + 暫存器並發送 OSC 52
nnoremap "+y "+y:silent! call OSCYank() <CR>
nnoremap <Leader>y "+y:silent! call OSCYank()<CR>

" --- 貼上映射 ---
nnoremap <Leader>p "+p
vnoremap <Leader>p "+p

" ==============================================================================
" 4. 快捷鍵映射
" ==============================================================================
" 清除搜尋高亮：按下兩次 ESC 即可清除高亮
nnoremap <Esc><Esc> :nohlsearch<CR>

" 快速存檔與退出
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" --- 快速導航 (FZF) ---
nnoremap <Leader>f :Files<CR>     " Space + f 找專案內所有檔案
nnoremap <Leader>b :Buffers<CR>   " Space + b 找已經開啟的檔案 (Buffers)
nnoremap <Leader>g :Rg<CR>        " Space + g 搜尋代碼內容 (需安裝 ripgrep)

" 按 Tab / Shift+Tab 切換 Buffer
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" 將終端機固定在下方
set splitbelow

" --- 側邊欄與視窗分割快捷鍵 ---
nnoremap <F2> :NERDTreeToggle<CR>
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.git$', '\.swp$', '\.o$', '\.pyc$']

nnoremap <F3> :TagbarToggle<CR>

" 按 <F4> 開啟終端機
nnoremap <F4> :belowright terminal ++rows=10<CR>
autocmd TerminalOpen * setlocal winfixheight

" 視窗穿梭快捷鍵
tnoremap <C-k> <C-\><C-n><C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ==============================================================================
" 5. 細節體驗與動態相容優化
" ==============================================================================
" 當主編輯區都關閉、只剩 NERDTree 時，自動退出 Vim
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:NERDTreeWinSize = 30
let g:tagbar_width = 30
let g:tagbar_autofocus = 1

" --- 跨平台 Tagbar ctags 動態路徑設定 ---
if has('win32') || has('win64')
    let g:tagbar_ctags_bin = 'ctags.exe'
elseif has('macunix')
    let g:tagbar_ctags_bin = executable('/opt/homebrew/bin/ctags') ? '/opt/homebrew/bin/ctags' : 'ctags'
else
    let g:tagbar_ctags_bin = 'ctags'
endif

" --- 離開 Insert Mode (Esc) 自動切回英文輸入法 ---
if has('win32') || has('win64')
    autocmd InsertLeave * silent! call system('im-select 1033')
elseif has('macunix')
    autocmd InsertLeave * silent! call system('macism com.apple.keylayout.ABC')
else
    autocmd InsertLeave * silent! call system('fcitx-remote -c')
endif
