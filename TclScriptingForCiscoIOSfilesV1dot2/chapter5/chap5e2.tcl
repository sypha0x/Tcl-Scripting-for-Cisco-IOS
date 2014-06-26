# Run CLI commands
if {[catch {cli_open} output]} {
    error $output $errorInfo
} else {
    array set cli_fd $output
}
#enter Enable privelege mode
if {[catch {cli_exec $cli_fd(fd) "enable"} output]} {
error $output $errorInfo
}
# Issue the "show clock" command to get the current time in clock_output 
# variable
if {[catch {cli_exec $cli_fd(fd) "show clock"} clock_output]} {
error $output $errorInfo
}
#close the handle used for CLI commands
if {[catch {cli_close $cli_fd(fd) $cli_fd(tty_id)} output]} {
    error $output $errorInfo
}

set header "<html><body>The time is now: $clock_output<br>
</body>
</html>
"

set middle "<html><body>This web page may be easily customized.  Nearly anything available to the TCL
Interpreter running on Cisco IOS may be easily
displayed.<br>
</body>
</html>
"

set footer ""


set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary

"

puts $httpsock $httpheader$header$middle$footer
