# Vim 환경 설정 이관 가이드 (이 서버 기준)

이 문서는 **현재 서버의 Vim 설정**(`~/.vimrc`, `~/.vim/`)을 **다른 서버로 동일하게 이관/재현**하기 위한 가이드입니다.

## 현재 서버 구성 요약

- **Vim**: `vim 9.1` (Huge, no GUI)
- **플러그인 매니저**: **Vundle** (`~/.vim/bundle/Vundle.vim`)
- **플러그인 설치 위치**: `~/.vim/bundle/`
- **주요 외부 의존성(확인됨)**:
  - **ctags**: Universal Ctags `5.9.0` (gutentags에 필요)
  - **ripgrep**: `rg 14.1.0` (F4 매핑 `:Rg`에 필요)
  - **fzf**: `0.44.1` (fzf 플러그인/바이너리)

## 설치된 플러그인 목록 (이 서버 `~/.vim/bundle/` 기준)

`~/.vimrc`에 선언되어 있고 `~/.vim/bundle/`에 존재하는 플러그인:

- `VundleVim/Vundle.vim`
- `preservim/nerdtree` (F8 토글)
- `morhetz/gruvbox` (colorscheme)
- `junegunn/fzf` (설치 훅: `fzf#install()`)
- `junegunn/fzf.vim`
- `ludovicchabant/vim-gutentags` (자동 tags 생성)

## 주의 사항 (Taglist 관련)

`~/.vimrc`에는 아래 설정이 있으나, 이 서버의 `~/.vim/bundle/`에는 **Taglist 플러그인이 존재하지 않습니다.**

- `let Tlist_Use_Left_Window = 1`
- `<F7>` 매핑: `:Tlist`
- 종료 시 `:TlistClose` 호출

즉, 다른 서버에서도 Taglist를 쓰려면 **별도로 설치가 필요**합니다(아래 “선택: Taglist 설치” 참고).

> 참고: 복사 방식은 가장 확실하지만, 운영 정책상 홈 디렉토리 내용을 통째로 옮기기 어렵다면 방식 B를 권장합니다.

---

### 방식 B) “선언(.vimrc) 기반 재설치” (정석, 깔끔)

대상 서버에서 **Vundle을 설치**한 뒤 `~/.vimrc` 기반으로 플러그인을 설치합니다.

#### 1) 필수 패키지 설치

Debian/Ubuntu 기준:

```bash
sudo apt update
sudo apt install -y vim git curl ripgrep fzf universal-ctags
```

RHEL/CentOS/Rocky 계열(예시, 배포판/레포에 따라 패키지명이 다를 수 있음):

```bash
sudo yum install -y vim git curl ripgrep fzf ctags
```

#### 2) `~/.vimrc` 복사

원본 서버의 `~/.vimrc`를 대상 서버에 동일하게 배치합니다.

```bash
scp <USER>@<SOURCE>:/home/<USER>/.vimrc ~/.vimrc
```

#### 3) Vundle 설치

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

#### 4) 플러그인 설치

```bash
vim +PluginInstall +qall
```

#### 5) `junegunn/fzf` 설치 훅 참고

이 환경은 Vundle 설정에서 `junegunn/fzf`에 대해 `fzf#install()` 훅을 사용합니다.
대부분 `PluginInstall` 과정에서 처리되지만, 문제가 있으면 아래를 확인하세요:

- `fzf` 바이너리가 설치되어 있는지: `fzf --version`
- 플러그인 디렉토리 존재 여부: `~/.vim/bundle/fzf`

## 주요 키 매핑/동작 (현재 .vimrc 기준)

- **검색 하이라이트**: `set hlsearch`
- **라인 번호**: `set nu`
- **인코딩 후보**: `utf8,euc-kr`
- **NERDTree 토글**: `F8`
- **현재 단어 ripgrep 검색**: `F4` → `:Rg <word>`
- **colorscheme**: `gruvbox` (시작/버퍼/윈도우 진입 시 유지하도록 autocmd 구성)
- **창 너비 조절**: `Ctrl+Right`, `Ctrl+Left`
- **gutentags**: 자동 tags 생성(외부 `ctags` 필요)

## 검증 체크리스트 (대상 서버)

아래 항목이 모두 통과하면 동일 환경 재현이 완료된 것입니다.

```bash
vim --version | head -n 2
ctags --version | head -n 2
rg --version | head -n 1
fzf --version
```

Vim 안에서:

- `:echo has("syntax")` → `1` 기대
- `:colorscheme gruvbox` 실행 시 에러 없음
- `:NERDTreeToggle` 동작 (F8도 동일)
- 임의 파일에서 단어 위에 커서 두고 `F4` → `Rg` 검색 UI 동작
- `:echo exists(":GutentagsUpdate")` → `2` 기대

## 선택: Taglist 설치(현재 .vimrc의 F7 사용 시)

현재 서버 `~/.vim/bundle/`에는 Taglist가 없어서, 대상 서버에서 `F7`(Tlist)을 쓰려면 아래 중 하나로 설치하세요.

### (권장) Vundle에 Taglist 추가

`~/.vimrc`의 Vundle 블록에 아래 줄을 추가:

```vim
Plugin 'vim-scripts/taglist.vim'
```

그 다음:

```bash
vim +PluginInstall +qall
```

### (대안) Taglist를 제거(사용하지 않을 경우)

Taglist를 안 쓰면 `~/.vimrc`에서 아래 항목을 제거/주석 처리하세요.

- `let Tlist_Use_Left_Window = 1`
- `map <F7> :Tlist<CR>`
- 종료 시 `TlistClose` 관련 로직(함수 `s:ClosePluginWindows()` 안)

## 문제 해결

- **`:PluginInstall`이 실패**:
  - `git` 설치 여부 확인
  - 네트워크/프록시 환경 확인
  - `~/.vim/bundle/` 권한 확인
- **`F4`에서 `:Rg` 명령이 없다고 나옴**:
  - `rg` 설치 확인 (`ripgrep`)
  - `fzf.vim`가 정상 설치됐는지 `~/.vim/bundle/fzf.vim` 확인
- **`gruvbox` 적용 에러**:
  - `~/.vim/bundle/gruvbox` 존재 확인
  - 터미널이 256color 지원하는지 확인(`TERM=xterm-256color` 등)
