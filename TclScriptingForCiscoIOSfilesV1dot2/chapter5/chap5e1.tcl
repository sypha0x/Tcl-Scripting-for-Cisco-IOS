set header ""

set middle "<html><body>This web page may be easily customized.  Nearly anything available to the TCL
Interpreter running on Cisco IOS may be easily
displayed.
</body>
</html>
"

set footer ""


set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary

"

puts $httpsock $httpheader$header$middle$footer
