for %%G in (*.sql) do sqlcmd /S DESKTOP-98NIEI1\SQLEXPRESS /d municipalidad -E -i"%%G"
pause