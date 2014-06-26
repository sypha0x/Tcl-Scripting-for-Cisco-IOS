set ipaddr [lindex $parmlist 1]

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
$ipaddr
</body>
</html>"

set middle ""

set footer ""

set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary

"

puts $httpsock $httpheader$header$middle$footer
