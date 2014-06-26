# Remote SNMP collection and Graphing written by Ray Blair
# For a complete set of commented code, please see Tcl Scripting for Cisco IOS
# ISBN-10: 1-58705-954-1
# ISBN-13: 978-1-58705-954-4

set SNMP_SERVER 192.168.0.190
set SNMP_STRING Public
set COUNT 0 
set XML_Data "<graph caption='Interface Statistics' xAxisName='Time' yAxisName='PPS' showNames='1' decimalPrecision='0' formatNumberScale='0'> \n"
file delete -force flash:/TCL/Data.xml
while {$COUNT < 13} {
	if [catch {cli_open} RESULT] {
    		error $RESULT $errorInfo
		} else {
    		array set cli1 $RESULT
	}
	if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    		error $RESULT $errorInfo
	}
	if [catch {cli_exec $cli1(fd) "snmp get v2c $SNMP_SERVER $SNMP_STRING timeout 1 oid ifOutUcastPkts.2" } RESULT] {
    		error $RESULT $errorInfo
		} else {
    		set OUT_Packets $RESULT
	}
	if [catch {cli_exec $cli1(fd) "show clock" } RESULT] {
    		error $RESULT $errorInfo
		} else {
    		set CLOCK $RESULT
	}
	if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    		error $RESULT $errorInfo
	}
	set CLOCK [string range $CLOCK 2 9]
	if {$COUNT == 0} {
		set OUT_Packets_Current [string range $OUT_Packets [expr [string first "= " $OUT_Packets] + 2] [expr [string first "\n" $OUT_Packets [expr [string first "= " $OUT_Packets] + 2]] - 1]]
		} else {
		set OUT_Packets_Base $OUT_Packets_Current
		set OUT_Packets_Current [string range $OUT_Packets [expr [string first "= " $OUT_Packets] + 2] [expr [string first "\n" $OUT_Packets [expr [string first "= " $OUT_Packets] + 2]] - 1]]
		set OUT_Packets_Graph [expr  $OUT_Packets_Current - $OUT_Packets_Base]	
		set XML_Data [concat $XML_Data "<set name='$CLOCK' value='$OUT_Packets_Graph' color='black' /> \n"]
	}
	incr COUNT
	after 4950
}
set XML_Data [concat $XML_Data "</graph>"]
set FILE [open flash:/TCL/Data.xml RDWR]
puts $FILE $XML_Data
close $FILE
set chart "<html>
   	<head>
      		<title>SNMP Remote Collection of Interface Statistics</title>
   	</head>
  	<body bgcolor='ffffff'>
      	<OBJECT classid='clsid:D27CDB6E-AE6D-11cf-96B8-444553540000' codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0' width='900' height='500' id='Column3D' >
         	<param name='movie' value='FCF_Line.swf' />
         	<param name='FlashVars' value='&dataURL=Data.xml&chartWidth=600&chartHeight=500'>
         	<param name='quality' value='high' />
         	<embed src='FCF_Line.swf' flashVars='&dataURL=Data.xml&chartWidth=900&chartHeight=500' type='application/x-shockwave-flash' pluginspage='http://www.macromedia.com/go/getflashplayer' />
      	</object>
	</body>
</html>
"
set header "<html>
	<head>
		<title>SNMP Remote Collection of Interface Statistics</title>
	</head>
	<div align='left'>
	<font face='arial' size='6'>SNMP Remote Collection of Interface Statistics</font><br />
	</div>
</html>
"
set footer "
set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary
"
puts $httpsock $httpheader$header$chart$footer