#make a copy of the original format into var called text
set text $::format
#creat a pointer that points to the first msg_arg in the list we created
set listp 0
#loop until we point past the last item in the list we created
while {$listp < [llength $::msg_args]} {
    # point to the beginning of the first 
    set beg [string first %s $text]
    # point end to the end of the first occurance of "%s" in text
    set end $beg
    incr end
    # using the msg_arg we are pointing at in msg_args, replace the "%s" with
    # the actual msg_arg it should be, and save this back into var called text
    set text [string replace $text $beg $end [lindex $msg_args $listp]]
    # point to the next item in  the list we created
    incr listp
}
# now return the original SYSLOG message just like it was originally, out
# of its' component parts
return "$buginfseq$timestamp: %$facility-$severity-$mnemonic: $text"
