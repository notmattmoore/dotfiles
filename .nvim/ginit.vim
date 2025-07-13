" options for the GUI

if has('nvim')
  GuiFont DejaVu\ Sans\ Mono:h9
else
  set guifont="DejaVu\ Sans\ Mono 9"  " a nice monospaced font
  set guioptions+=c                   " prefer console dialogs
  set guioptions-=L                   " no left scrollbars
  set guioptions-=R                   " no right scrollbars
  set guioptions-=T                   " no toolbar
  set guioptions-=b                   " no bottom scrollbars
  set guioptions-=l                   " no left scrollbars
  set guioptions-=m                   " no menubar
  set guioptions-=r                   " no right scrollbars
  set visualbell t_vb=                " no visualbells
endif
