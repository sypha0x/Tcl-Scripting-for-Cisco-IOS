set ipaddr [lindex $parmlist 1]

# Configure IPLSA Entry
if {[catch {cli_open} output]} {
	error $output $errorInfo
} else {
	array set cli_fd $output
}
if {[catch {cli_exec $cli_fd(fd) "enable"} output]} {
	error $output $errorInfo
}
if {[catch {cli_exec $cli_fd(fd) "show ip sla statistics"} ipslashowcmd]} {
	error $iplashowcmd $errorInfo
}
# Close the handle
if {[catch {cli_close $cli_fd(fd) $cli_fd(tty_id)} output]} {
	error $output $errorInfo
}

set ipslaoutput [string map {"\r\n" "\n" "\"" "&#148;"  "<" "&#060;" ">" "&#062;" "'" "&#146;"} $ipslashowcmd]


set header "<html>
<head>
<title>IP SLA Measurment Results Page</title>
<script>
// clear default value from field when selected
function clear_field(field, value) {if(field.value == value) field.value = '';}
function init_field(field, value) {if(field.value == '') field.value = value;}
</script>
</head>
<body>
IP SLA Measurment Results Page<br><br>
We are monitoring : <br>
$ipaddr<br><br>
The latest results:<br>
<textarea name='body' style='WIDTH: 710px; HEIGHT: 465px; color:#000000; font-family: courier; font-size: 8pt'>$ipslaoutput</textarea>
</body>
</html>"

set middle ""

set footer ""

set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary

"

puts $httpsock $httpheader$header$middle$footer
