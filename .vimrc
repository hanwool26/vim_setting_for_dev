if has("syntax")
	syntax on
endif

set hlsearch
set nu
set autoindent
set ts=4
set sts=4
set cindent
set laststatus=2
set shiftwidth=4
set showmatch
set smartcase
set smarttab
set smartindent
set ruler
set fileencodings=utf8,euc-kr

let Tlist_Use_Left_Window = 1
map <F7> :Tlist<CR>

let NERDTreeWinPos = "right"
nmap <F8> :NERDTreeToggle<CR>

nmap<F4> yiw:Rg <C-R>"<CR>

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'preservim/nerdtree'
	Plugin 'morhetz/gruvbox'
	Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plugin 'junegunn/fzf.vim'
	Plugin 'ludovicchabant/vim-gutentags'   " 자동 tags 생성
call vundle#end()

" 파일 타입 감지 및 플러그인 로드 다시 활성화
filetype plugin indent on

" fzf로 파일을 열 때 syntax 활성화
augroup fzf_syntax
  autocmd!
  autocmd BufReadPost * :syntax on
  autocmd BufEnter * :syntax on
augroup END

" viminfo 설정 - 세션 정보 저장 (커서 위치, 히스토리 등)
" '100 : 100줄까지 마크 저장
" <50 : 50개 파일까지 마크 저장  
" h : viminfo를 비휘발성 메모리에 저장 (원격 사이트에 저장 안함)
" s10 : 10KB보다 작은 버퍼만 레지스터에 저장
" % : 버퍼 목록 저장
" :50 : 50개 명령 히스토리
" /50 : 50개 검색 히스토리
" n~/.vim/viminfo : viminfo 파일 위치
set viminfo='100,<50,h,s10,%,:50,/50,n~/.vim/viminfo

set background=dark
" colorscheme 적용 - Vim 시작 시
autocmd vimenter * ++nested colorscheme gruvbox

" 파일 이동 시에도 colorscheme 유지
augroup maintain_colorscheme
  autocmd!
  " 버퍼 변경 시 colorscheme 유지 (fzf, diff 제외)
  autocmd BufEnter * 
    \ if &filetype !=# 'fzf' && &filetype !=# 'diff' && 
    \    (!exists('g:colors_name') || g:colors_name !=# 'gruvbox') | 
    \    colorscheme gruvbox | 
    \ endif
  " 윈도우 변경 시 colorscheme 유지
  autocmd WinEnter * 
    \ if &filetype !=# 'fzf' && &filetype !=# 'diff' && 
    \    (!exists('g:colors_name') || g:colors_name !=# 'gruvbox') | 
    \    colorscheme gruvbox | 
    \ endif
augroup END

if has('autocmd')
  augroup restore_cursor
    autocmd!
    autocmd BufReadPost *
          \ if line("'\"") > 1 && line("'\"") <= line("$") |
          \   execute "normal! g'\"" |
          \ endif
  augroup END
endif

" 창 너비 조절: Ctrl + 방향키
" Ctrl + → : 창 너비 증가
" Ctrl + ← : 창 너비 감소
noremap <C-Right> <C-W>>
noremap <C-Left> <C-W><

" 메인 창 종료 시 플러그인 창도 함께 닫기
augroup close_plugins_on_quit
  autocmd!
  autocmd QuitPre * call s:ClosePluginWindows()
augroup END

function! s:ClosePluginWindows()
  " NERDTree 닫기
  if exists(':NERDTreeClose') == 2
    try
      NERDTreeClose
    catch
    endtry
  endif
  
  " Taglist 닫기
  if exists(':TlistClose') == 2
    try
      TlistClose
    catch
    endtry
  endif
  
  " 모든 플러그인 윈도우 닫기 (안전장치)
  " 역순으로 닫아서 윈도우 번호 변경에 영향 받지 않도록 함
  let win_count = winnr('$')
  let plugin_wins = []
  let i = 1
  while i <= win_count
    let bufname = bufname(winbufnr(i))
    if bufname =~ 'NERD_tree' || bufname =~ '__Tag_List__'
      call add(plugin_wins, i)
    endif
    let i += 1
  endwhile
  
  " 역순으로 닫기
  for win_num in reverse(plugin_wins)
    try
      execute win_num . 'wincmd w'
      close
    catch
    endtry
  endfor
endfunction