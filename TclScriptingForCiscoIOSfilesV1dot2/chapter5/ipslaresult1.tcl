# Open the handle to enter show commands
if {[catch {cli_open} output]} {
	error $output $errorInfo
} else {
	array set cli_fd $output
}
# enter enable Privlege mode
if {[catch {cli_exec $cli_fd(fd) "enable"} output]} {
	error $output $errorInfo
}
# Get the results of the latest Echo Request for display on Web Page
if {[catch {cli_exec $cli_fd(fd) "show ip sla statistics 1"} ipslacmd]} {
	error $ipslacmd $errorInfo
}
# Close the handle
if {[catch {cli_close $cli_fd(fd) $cli_fd(tty_id)} output]} {
	error $output $errorInfo
}
set ipslaoutput [string map {"\r\n" "\n" "\"" "&#148;"  "<" "&#060;" ">" "&#062;" "'" "&#146;"} $ipslacmd]

set header "<html>
<head>
<title>IP SLA Measurment Result Page with AutoReload</title>
</head>
<script type='text/javascript'> 
<!--      
  var timer = setInterval('autoRefresh()', 1000 * 60);
  function autoRefresh(){self.location.reload(true);}
//--> 
</script>
<body>
IP SLA Measurment Result Page with AutoReload<br><br>

Results of the Latest IP Sla entry:<br>
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
