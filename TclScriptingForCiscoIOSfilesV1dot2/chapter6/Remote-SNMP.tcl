# Remote SNMP collection and Graphing written by Ray Blair# This application is used to configure and individual device as an MPLS-VPN P/PE device.# Copyright 2010 Ray Blair. All rights reserved.# Redistribution and use in source and binary forms, with or without modification, are# permitted provided that the following conditions are met:#   1. Redistributions of source code must retain the above copyright notice, this list of#      conditions and the following disclaimer.#   2. Redistributions in binary form must reproduce the above copyright notice, this list#      of conditions and the following disclaimer in the documentation and/or other materials#      provided with the distribution.# THIS SOFTWARE IS PROVIDED BY RAY BLAIR ``AS IS'' AND ANY EXPRESS OR IMPLIED# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RAY BLAIR OR# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.# The views and conclusions contained in the software and documentation are those of the# authors and should not be interpreted as representing official policies, either expressed# or implied, of Ray Blair.# For comments or suggestions please contact the author at rablair@cisco.com 
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
set footer "	<script>		function clear_field(field, value) {if(field.value == value) field.value = '';}		function init_field(field, value) {if(field.value == '') field.value = value;}	</script>"
set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary
"
puts $httpsock $httpheader$header$chart$footer
