set ipaddr [lindex $parmlist 1]

# Configure IPLSA Entry
if {[catch {cli_open} output]} {
	error $output $errorInfo
} else {
	array set cli_fd $output
}
# enter enable Privlege mode
if {[catch {cli_exec $cli_fd(fd) "enable"} output]} {
	error $output $errorInfo
}
# enter configuration mode
if {[catch {cli_exec $cli_fd(fd) "config terminal"} output]} {
	error $output $errorInfo
}
# delete the IP Sla entry if it exists
if {[catch {cli_exec $cli_fd(fd) "no ip sla 1"} output]} {
	error $output $errorInfo
}
# configure the IP Sla entry
if {[catch {cli_exec $cli_fd(fd) "ip sla 1"} output]} {
	error $output $errorInfo
}
# set the type of measurement to icmp-echo and use the input ip address
if {[catch {cli_exec $cli_fd(fd) "icmp-echo $ipaddr"} output]} {
	error $output $errorInfo
}
# begin measuring now
if {[catch {cli_exec $cli_fd(fd) "ip sla schedule 1 start-time now"} output]} {
	error $output $errorInfo
}
# exit out of configuration mode
if {[catch {cli_exec $cli_fd(fd) "end"} output]} {
	error $output $errorInfo
}
# verify the entry was created for later display on Web Page
if {[catch {cli_exec $cli_fd(fd) "show ip sla configuration 1"} showconfigcmd]} {
	error $showconfigcmd $errorInfo
}
# Close the handle
if {[catch {cli_close $cli_fd(fd) $cli_fd(tty_id)} output]} {
	error $output $errorInfo
}
set ipslaoutput [string map {"\r\n" "\n" "\"" "&#148;"  "<" "&#060;" ">" "&#062;" "'" "&#146;"} $showconfigcmd]

set header "<html>
<head>
<title>IP SLA Measurment Configuration Page</title>
<script>
// clear default value from field when selected
function clear_field(field, value) {if(field.value == value) field.value = '';}
function init_field(field, value) {if(field.value == '') field.value = value;}
</script>
</head>
<body>
IP SLA Measurment Configuration Page<br><br>
We are monitoring : <br>
$ipaddr<br><br>
  <form name='ipslaresult' action='ipslaresult.tcl' method='GET' target='_blank'>
  <input type='submit' value='Get IP Sla Result'>
  </form>
Configuration of IP Sla entry:<br>
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
