for %%G in (*.sql) do sqlcmd /S HUSTLEBONES\SQLEXPRESS /d municipalidad -E -i"%%G"
pause