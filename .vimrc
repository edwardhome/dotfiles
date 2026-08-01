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
  " -- 代碼補全與語法 ---
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
  " OSC 52 跨 SSH剪貼簿
  Plug 'ojroques/vim-oscyank'
  call plug#end()
  
" 設定配色
set termguicolors
colorscheme onedark
let g:airline#extensions#tabline#enabled = 1  " 開啟上方 Tabline
let g:airline#extensions#tabline#fnamemod = ':t' " 只顯示檔名，不顯示長路徑
let g:airline_theme='onedark'
" --- 基礎優化 ---
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

" --- 快捷鍵映射 ---
" 清除搜尋高亮 按下兩次ESC即可清除高亮
nnoremap <Esc><Esc> :nohlsearch<CR>
" 快速存檔與退出
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
" 系統剪貼簿連動 (需先安裝 vim-gtk3)
vnoremap <Leader>y "+y
nnoremap <Leader>p "+p
" --- 快速導航 ---
" Space + f 找專案內所有檔案
nnoremap <Leader>f :Files<CR>
" Space + b 找已經開啟的檔案 (Buffers)
nnoremap <Leader>b :Buffers<CR>
" Space + g 搜尋代碼內容 (需安裝 ripgrep)
nnoremap <Leader>g :Rg<CR>
" 按 Tab 切換到下一個 Buffer (向右)
nnoremap <Tab> :bnext<CR>
" 按 Shift + Tab 切換到上一個 Buffer (向左)
nnoremap <S-Tab> :bprevious<CR>
" 將終端機固定在下方
set splitbelow
" ==========================================
" 2.快捷鍵設定
" ==========================================
" 按 <F2> 開關左側檔案總管
nnoremap <F2> :NERDTreeToggle<CR>
let NERDTreeShowHidden = 1
" 隱藏特定的隱藏目錄或暫存檔
let NERDTreeIgnore = ['\.git$', '\.swp$', '\.o$', '\.pyc$']
" 按 <F3> 開關右側大綱欄
nnoremap <F3> :TagbarToggle<CR>
" 按 <F4> 開啟終端機
nnoremap <F4> :belowright terminal ++rows=10<CR>
" 當開啟 Terminal 時自動鎖定 10 行高度，不受其他 split 視窗拉扯
autocmd TerminalOpen * setlocal winfixheight

" 在 Terminal 裡面直接按 Ctrl+k 切換回上方編輯區
tnoremap <C-k> <C-\><C-n><C-w>k
" 省去按 Ctrl+w 的步驟，直接用 Ctrl + h/j/k/l 在視窗間穿梭
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" ==========================================
" 3. 細節優化體驗
" ==========================================
" 當主編輯區都關閉、只剩 NERDTree 時，自動退出 Vim，避免手動關側邊欄
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" 設定 NERDTree 視窗寬度
let g:NERDTreeWinSize = 30
" 設定 Tagbar 視窗寬度與自動聚焦
let g:tagbar_width = 30
let g:tagbar_autofocus = 1
" ==========================================
" 跨平台 Tagbar ctags 路徑動態設定
" ==========================================
if has('win32') || has('win64')
    " Windows 平台：自動抓取當前使用者的 $HOME (C:\Users\<Username>\ctags\ctags.exe)
    let g:tagbar_ctags_bin = expand('$HOME/ctags/ctags.exe')
elseif has('macunix')
    " macOS 平台 (Homebrew)
    let g:tagbar_ctags_bin = '/opt/homebrew/bin/ctags'
else
    " Linux / Ubuntu / Synology NAS 平台
    let g:tagbar_ctags_bin = '/usr/bin/ctags'
endif
" OSC52 相關設定 
" 自動化設定：只要在 Normal Mode 複製 (y)，就自動透過 OSC 52 丟回地端剪貼簿
autocmd TextYankPost * if v:event.operator ==# 'y' | execute 'OSCYankRegister "' | endif
" 設定預設複製的 Register 為無名暫存器 (")
let g:oscyank_max_length = 100000 " 允許一次複製最大字元數
" ==========================================
" 離開 Insert Mode (Esc) 自動切回英文輸入法
" ==========================================
if has('win32') || has('win64')
    " Windows: 呼叫 im-select 切回 1033 (US English)
    autocmd InsertLeave * silent! call system('im-select 1033')
elseif has('macunix')
    " macOS: 切回 ABC 英文輸入法
    autocmd InsertLeave * silent! call system('/opt/homebrew/bin/macism com.apple.keylayout.ABC')
else
    " Linux (Fcitx/iBus): 關閉輸入法，切回 Direct Input
    autocmd InsertLeave * silent! call system('fcitx-remote -c')
endif
