setlocal shiftwidth=4
setlocal tabstop=4
setlocal softtabstop=4
setlocal expandtab

" Format on save using qmlformat
augroup QmlFormat
    autocmd!
    autocmd BufWritePost *.qml silent! execute '!qmlformat -i %' | edit!
augroup END
