set runconfig [exec "show running-config"]
set foundposition [string first "clock timezone" $runconfig]
set cutoff [string length "clock timezone"]
if {$foundposition > -1} {
    set begin [expr $foundposition + $cutoff]
    set end [expr $begin + 7]
    set timezone [string range $runconfig $begin $end]
    puts "We found the timezone!"
    puts -nonewline "The current timezone is"
    puts $timezone
}
