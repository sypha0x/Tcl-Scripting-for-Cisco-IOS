# MPLS-VPN Configuration Application written by Ray Blair# This application is used to configure and individual device as an MPLS-VPN P/PE device.# Copyright 2010 Ray Blair. All rights reserved.# Redistribution and use in source and binary forms, with or without modification, are# permitted provided that the following conditions are met:#   1. Redistributions of source code must retain the above copyright notice, this list of#      conditions and the following disclaimer.#   2. Redistributions in binary form must reproduce the above copyright notice, this list#      of conditions and the following disclaimer in the documentation and/or other materials#      provided with the distribution.# THIS SOFTWARE IS PROVIDED BY RAY BLAIR ``AS IS'' AND ANY EXPRESS OR IMPLIED# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RAY BLAIR OR# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.# The views and conclusions contained in the software and documentation are those of the# authors and should not be interpreted as representing official policies, either expressed# or implied, of Ray Blair.# For comments or suggestions please contact the author at rablair@cisco.com 
# For a complete set of commented code, please see Tcl Scripting for Cisco IOS
# ISBN-10: 1-58705-954-1
# ISBN-13: 978-1-58705-954-4

if [catch {cli_open} RESULT] {
    	error $RESULT $errorInfo
	} else {
    	array set cli1 $RESULT
}

if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    	error $RESULT $errorInfo
}

if [catch {cli_exec $cli1(fd) "show ip vrf detail | include ;" } RESULT] {
    	error $RESULT $errorInfo
	} else {
    	set VRFs $RESULT
}

if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    	error $RESULT $errorInfo
}


set COUNT 1
set ALL_VRF_INFO ""

while {[string length $VRFs]  > 10} {
	set VRF($COUNT) [string range $VRFs [expr [string first "VRF " $VRFs] + 4] [expr [string first "; default RD" $VRFs] - 1]]
	set RD($COUNT)  [string range $VRFs [expr [string first "; default RD " $VRFs] + 12] [expr [string first "; default VPNID" $VRFs] -1]]
        set ITEM "<b>$VRF($COUNT)</b><br /> $RD($COUNT)<br />"	
	set ALL_VRF_INFO [concat $ALL_VRF_INFO $ITEM]
	set VRFs [string range $VRFs [expr [string first "\n" $VRFs] +1] [string length $VRFs]]
	incr COUNT
}
set NUM_OF_VRFS $COUNT
if [catch {cli_open} RESULT] {
    error $RESULT $errorInfo
} else {
    array set cli1 $RESULT
}
if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    error $RESULT $errorInfo
}
if [catch {cli_exec $cli1(fd) "show run" } RESULT] {
    error $RESULT $errorInfo
} else {
    set CONFIG $RESULT
}
if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    error $RESULT $errorInfo
}
set COUNT 1
set IMPORT_EXPORT ""
while {$COUNT < $NUM_OF_VRFS} {	
	set BEGIN [string first "\n" $CONFIG [string first "ip vrf $VRF($COUNT)" $CONFIG]]
	set END [string first "!" $CONFIG $BEGIN]
	set IMP_EXP_STRING [string range $CONFIG [expr $BEGIN +1] [expr $END -1]]
	if {[string first "route-target " $IMP_EXP_STRING]} {
		set BEGIN [string first "route-target " $IMP_EXP_STRING]
		set IMP_EXP_STRING [string range $IMP_EXP_STRING [expr $BEGIN -1] [expr $END -1]]
		regsub -all {route-target } $IMP_EXP_STRING "</b><br />" IMP_EXP_STRING 
		set ITEM "<b> $VRF($COUNT) $IMP_EXP_STRING <br />"	
		set IMPORT_EXPORT [concat $IMPORT_EXPORT $ITEM]
	}
	incr COUNT
}
if [catch {cli_open} RESULT] {
    error $RESULT $errorInfo
} else {
    array set cli1 $RESULT
}
if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    error $RESULT $errorInfo
}
if [catch {cli_exec $cli1(fd) "show ip vrf interfaces" } RESULT] {
    error $RESULT $errorInfo
} else {
    set VRF_INTERFACE_CONFIG $RESULT
}
if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    error $RESULT $errorInfo
}
set VRF_INTERFACE_OUTPUT ""
set COUNT 1
while {$COUNT < $NUM_OF_VRFS} {
	while {[regexp -all $VRF($COUNT) $VRF_INTERFACE_CONFIG] > 0} {	
		set BEGIN [expr [string first "Protocol" $VRF_INTERFACE_CONFIG] + 10]
		set END [expr [string first "\n" $VRF_INTERFACE_CONFIG [expr [string first $VRF($COUNT) $VRF_INTERFACE_CONFIG $BEGIN]]]]
		set VRF_INTERFACES [string range $VRF_INTERFACE_CONFIG [expr $BEGIN -1] $END]		
			regsub -all $VRF($COUNT) $VRF_INTERFACES " " VRF_INTERFACES
			regsub -all {  } $VRF_INTERFACES " " VRF_INTERFACES
			set ITEM "<b> $VRF($COUNT)</b><br /> $VRF_INTERFACES </b><br />"	
			set VRF_INTERFACE_OUTPUT [concat $VRF_INTERFACE_OUTPUT $ITEM]
			set VRF_INTERFACE_CONFIG [string replace $VRF_INTERFACE_CONFIG [expr $BEGIN -1] [expr $END]]
	}
incr COUNT
}
if [catch {cli_open} RESULT] {
    error $RESULT $errorInfo
} else {
    array set cli1 $RESULT
}
if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    error $RESULT $errorInfo
}
if [catch {cli_exec $cli1(fd) "sh mpls interfaces | exc Operational" } RESULT] {
    error $RESULT $errorInfo
} else {
    set LDP_INTERFACE_CONFIG $RESULT
}
if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    error $RESULT $errorInfo
}
set LDP_INTERFACES ""
 
while {[regexp -all {Yes | No} $LDP_INTERFACE_CONFIG] > 0} {			
	set END [string first "\n" $LDP_INTERFACE_CONFIG 12]

	set ITEM [string range $LDP_INTERFACE_CONFIG 0 $END]
		
	if {[expr [string last Yes $ITEM]] > [expr [string last No $ITEM]]} {
		set END [expr [string last Yes $ITEM] - 3] 
		} else {				
		set END [expr [string last No $ITEM] -2 ]
	}
	set ITEM [string replace $ITEM [expr [string first " " $ITEM]] $END]
	set ITEM "$ITEM <br />"		
	set LDP_INTERFACES [concat $LDP_INTERFACES $ITEM]
	set LDP_INTERFACE_CONFIG [string replace $LDP_INTERFACE_CONFIG 0 [string first "\n" $LDP_INTERFACE_CONFIG 3]]
}
if [catch {cli_open} RESULT] {
    error $RESULT $errorInfo
} else {
    array set cli1 $RESULT
}
if [catch {cli_exec $cli1(fd) "en"} RESULT] {
    error $RESULT $errorInfo
}
if [catch {cli_exec $cli1(fd) "show ip bgp vpnv4 all summary" } RESULT] {
    error $RESULT $errorInfo
} else {
    set BGP_NEIGHBORS $RESULT
}
if [catch {cli_close $cli1(fd) $cli1(tty_id)} RESULT] {
    error $RESULT $errorInfo
}
set BGP_NEIGHBOR_OUTPUT ""	
set BEGIN [expr [string first "PfxRcd" $BGP_NEIGHBORS 1] + 8]
while {[regexp -all {.} $BGP_NEIGHBORS] > 0} {
	if {$BEGIN < 10} {
		set BEGIN 0
	}
	if {[string first "\n" $BGP_NEIGHBORS [expr $BEGIN + 20]]} {	
		set END [string first "\n" $BGP_NEIGHBORS [expr $BEGIN + 20]]
		} else {
		set END [expr [string length $BGP_NEIGHBORS] - 1]
	}
	set ITEM [string range $BGP_NEIGHBORS $BEGIN $END]
	if {[string length $ITEM] < 10} {break}
		if {[regexp -all {Active} $ITEM] == 0} {
			set ITEM [string replace $ITEM [expr [string first " " $ITEM]] $END]
			set ITEM "$ITEM UP <br />"
 			set BGP_NEIGHBOR_OUTPUT [concat $BGP_NEIGHBOR_OUTPUT $ITEM]
			} else {
			set ITEM [string replace $ITEM [expr [string first " " $ITEM]] $END]
			set ITEM "$ITEM DOWN <br />"
 			set BGP_NEIGHBOR_OUTPUT [concat $BGP_NEIGHBOR_OUTPUT $ITEM]
		}
	set BGP_NEIGHBORS [string replace $BGP_NEIGHBORS 0 $END]
	set BEGIN -1
}
set BGP_CONFIG $CONFIG
	if {[regexp -all {router bgp} $BGP_CONFIG] > 0} {	
		if {[regexp -all {address-family} $BGP_CONFIG] > 0} {
		set BEGIN [string first "router bgp" $BGP_CONFIG]
		set END [string last exit-address-family $BGP_CONFIG]		
		set BGP_CONFIG_RESULTS [string range $BGP_CONFIG $BEGIN [expr $END + 18]]
		regsub -all  {\n} $BGP_CONFIG_RESULTS {<br />} BGP_CONFIG_RESULTS
		}
		set BGP_AS [string range $BGP_CONFIG_RESULTS 11 [expr [string first "<br" $BGP_CONFIG_RESULTS] - 1]]
	}

set header "<html>
<head>
<title>MPLS-VPN Configuration Application:</title>
</head>

<div align='center'>
<font face='arial' size='6'>MPLS-VPN Configuration Application</font><br />
</div>
</html>
"
set config "
<div align='left' style='color: grey; font-family: arial; font-size: 18pt; MARGIN: 10px 10px'>
  	VRF Information:
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 250px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
	<font face='arial' size='4'>VRF name / RD</font><br />
	<ol>$ALL_VRF_INFO</ol>
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 230px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
  	<font face='arial' size='4'>Import / Export</font><br />
 	<ol>$IMPORT_EXPORT</ol>
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 300px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
	<font face='arial' size='4'>VRF Interface Status</font><br />
  	<ol>$VRF_INTERFACE_OUTPUT</ol>
</div>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<div align='left' style='color: grey; font-family: arial; font-size: 18pt; MARGIN: 10px 10px'>
  	VRF Configuration:
</div>
	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
 
<input type='text' name='VRF_Name' value='VRF_Name' onblur='init_field(this,\"VRF_Name\");' onFocus='clear_field(this,\"VRF_Name\");
' style='WIDTH: 200px; font-family: arial; font-size: 10pt'>
  	<font face='arial' size='4'> 	
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  <input type='text' name='RD' value='RD' onblur='init_field(this,\"RD\");' onFocus='clear_field(this,\"RD\");
' style='WIDTH: 200px; font-family: arial; font-size: 10pt'>
  	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  <input type='text' name='Import' value='Import' onblur='init_field(this,\"Import\");' onFocus='clear_field(this,\"Import\");
' style='WIDTH: 200px; font-family: arial; font-size: 10pt'>
  	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  <input type='text' name='Export' value='Export' onblur='init_field(this,\"Export\");' onFocus='clear_field(this,\"Export\");
' style='WIDTH: 200px; font-family: arial; font-size: 10pt'>
<br />
<div align='left'>
  	<font face='arial' size='4'> 
	<color='black'>
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  <input type='text' name='Interface' value='Interface' onblur='init_field(this,\"Interface\");' onFocus='clear_field(this,\"Interface\");
' style='WIDTH: 250px; font-family: arial; font-size: 10pt'>
  	<font-family: arial; font-size: 18pt> 
	<color='black'>
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  <input type='text' name='IP_Address' value='IP_Address' onblur='init_field(this,\"IP_Address\");' onFocus='clear_field(this,\"IP_Address\");
' style='WIDTH: 250px; color:#000000; font-family: arial; font-size: 10pt'>
  <input type='text' name='Mask' value='Mask' onblur='init_field(this,\"Mask\");' onFocus='clear_field(this,\"Mask\");
' style='WIDTH: 250px; color:#000000; font-family: arial; font-size: 10pt'>
<br />
<div align='left' style='color: black; font-family: arial; font-size: 12pt;
    	MARGIN: 10px 10px'>
	Redistribute Connected:
	<input type='radio' name='Red_Connected' value='yes'  /> yes
	<input type='radio' name='Red_Connected' value='no' checked='checked' /> no
</div>
<br /><br />
<div align='left' style='color: grey; font-family: arial; font-size: 18pt; MARGIN: 10px 10px'>
  	BGP / LDP Information:
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 220px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
	<font face='arial' size='4'>Label Int / Operational</font><br />
  	<ol>$LDP_INTERFACES</ol>
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 220px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
	<font face='arial' size='4'>BGP Neighbors</font><br />
  	<ol>$BGP_NEIGHBOR_OUTPUT</ol>
</div>
<div align='left' style='overflow: scroll; border-right-style: solid; font-family: arial; font-size: 10pt; border-right-width:1px; WIDTH: 340px; FLOAT: left; HEIGHT: 200px; MARGIN: 10px 10px'>
	<font face='arial' size='4'>BGP Configuration</font><br />
  	<ol>$BGP_CONFIG_RESULTS </ol>
</div>
<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
<div align='left' style='color: grey; font-family: arial; font-size: 18pt;
    MARGIN: 10px 10px'>
  BGP Configuration:
</div>
<div align='left'>
  	<font face='arial' size='4'> 	
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
 	 <input type='text' name='BGP_AS' value='$BGP_AS' onblur='init_field(this,\"$BGP_AS\");' onFocus='clear_field(this,\"$BGP_AS\");
	' style='WIDTH: 230px; font-family: arial; font-size: 10pt'>
  	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
 	 <input type='text' name='Neighbor' value='Neighbor' onblur='init_field(this,\"Neighbor\");' onFocus='clear_field(this,\"Neighbor\");
	' style='WIDTH: 230px; font-family: arial; font-size: 10pt'>
  	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
	  <input type='text' name='Source_Int' value='Source_Int' onblur='init_field(this,\"Source_Int\");' onFocus='clear_field(this,\"Source_Int\");
	' style='WIDTH: 250px; font-family: arial; font-size: 10pt'>
</div>

<div align='left' style='color: black; font-family: arial; font-size: 12pt; MARGIN: 10px 10px'>
	Route Reflector Client:
	<input type='radio' name='RR_Client' value='yes'  /> Yes
	<input type='radio' name='RR_Client' value='no' checked='checked' /> No
</div>
<br /><br />
<div align='left' style='color: grey; font-family: arial; font-size: 18pt; MARGIN: 10px 10px'>
  	LDP Configuration:
</div>
<div align='left'>
 	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  	<input type='text' name='Label_Int' value='Label_Int' onblur='init_field(this,\"Label_Int\");' onFocus='clear_field(this,\"Label_Int\"); ' style='WIDTH: 230px; font-family: arial; font-size: 10pt'>
 	<font face='arial' size='4'> 
  	<form name='MPLS-CFG' action='MPLS-CFG.tcl' method='GET' target='_blank'>
  	<input type='text' name='IP_Address' value='IP_Address' onblur='init_field(this,\"IP_Address\");' onFocus='clear_field(this,\"IP_Address\");' style='WIDTH: 230px; font-family: arial; font-size: 10pt'>
  	<input type='text' name='Mask' value='Mask' onblur='init_field(this,\"Mask\");' onFocus='clear_field(this,\"Mask\");' style='WIDTH: 250px; font-family: arial; font-size: 10pt'>
</div>
<br /><br /><br /><br />
<div align='left' style='color: black; font-family: arial; font-size: 14pt; MARGIN: 10px 10px'>
	Configuration:
	<input type='radio' name='ADD_REMOVE' value='yes' checked='checked' /> Add
	<input type='radio' name='ADD_REMOVE' value='no'/> Remove
</div>
<br />
"

set footer "<script>function clear_field(field, value) {if(field.value == value) field.value = '';}function init_field(field, value) {if(field.value == '') field.value = value;}</script><br /><input type='submit' style='color: red value='Deploy Changes'>"

set httpheader "HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: binary
"

puts $httpsock $httpheader$header$config$footer
