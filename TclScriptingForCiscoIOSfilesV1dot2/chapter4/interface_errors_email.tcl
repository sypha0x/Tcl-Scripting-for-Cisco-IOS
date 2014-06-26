::cisco::eem::event_register_timer cron name crontimer2 cron_entry $_cron_entry maxrun_sec 240
# register for cron timer using user-defined cron entry

# check if all the env variables we need exist
# If any of them doesn't exist, print out an error msg and quit
if {![info exists _email_server]} {
    set result \
	"Policy cannot be run: variable _email_server has not been set"
    error $result $errorInfo
}
if {![info exists _email_from]} {
    set result \
	"Policy cannot be run: variable _email_from has not been set"
    error $result $errorInfo
}
if {![info exists _email_to]} {
    set result \
	"Policy cannot be run: variable _email_to has not been set"
    error $result $errorInfo
}
if {![info exists _email_cc]} {
     #_email_cc is an option, must set to empty string if not set.
     set _email_cc ""
}

if {![info exists _show_cmd]} {
    set result \
        "Policy cannot be run: variable _show_cmd has not been set"
    error $result $errorInfo
}


namespace import ::cisco::eem::*
namespace import ::cisco::lib::*

#query the event info and log a message
array set arr_einfo [event_reqinfo]

if {$_cerrno != 0} {
    set result [format "component=%s; subsys err=%s; posix err=%s;\n%s" \
        $_cerr_sub_num $_cerr_sub_err $_cerr_posix_err $_cerr_str]
    error $result 
}

global timer_type timer_time_sec 
set timer_type $arr_einfo(timer_type)
set timer_time_sec $arr_einfo(timer_time_sec)

#log a message
set msg [format "timer event: timer type %s, time expired %s" \
        $timer_type [clock format $timer_time_sec]]

action_syslog priority info msg $msg
if {$_cerrno != 0} {
    set result [format "component=%s; subsys err=%s; posix err=%s;\n%s" \
	$_cerr_sub_num $_cerr_sub_err $_cerr_posix_err $_cerr_str]
    error $result 
}

# 1. execute the show command
if [catch {cli_open} result] {
    error $result $errorInfo
} else {
    array set cli1 $result
}
if [catch {cli_exec $cli1(fd) "en"} result] {
    error $result $errorInfo
}
if [catch {cli_exec $cli1(fd) $_show_cmd} result] {
    error $result $errorInfo
} else {
    set cmd_output $result
}
if [catch {cli_close $cli1(fd) $cli1(tty_id)} result] {
    error $result $errorInfo
}
 
# 2. log the success of the CLI command 
set msg [format "Command \"%s\" executed successfully" $_show_cmd]
action_syslog priority info msg $msg
if {$_cerrno != 0} {
    set result [format "component=%s; subsys err=%s; posix err=%s;\n%s" \
        $_cerr_sub_num $_cerr_sub_err $_cerr_posix_err $_cerr_str]
    error $result
}

# 3. get input / output errors
set mylist [split $cmd_output " "]
set newlist [split $cmd_output " "]
set inputerror 0
set outputerror 0
set curpos [lsearch $mylist input]
while {$curpos > 0} {
    set prev [expr $curpos - 1]
    set curerror [lindex $mylist $prev]
    if {$curerror > 0} {incr inputerror}
    set newlist [lreplace $newlist $curpos $curpos junk]
    set curpos [lsearch $newlist input]
}
set curpos [lsearch $mylist output]
while {$curpos > 0} {
    set prev [expr $curpos - 1]
    set curerror [lindex $mylist $prev]
    if {$curerror > 0} {incr outputerror}
    set newlist [lreplace $newlist $curpos $curpos junk]
    set curpos [lsearch $newlist output]
}

# 4. check if there were interface errors
if {$inputerror < 1 && $outputerror < 1} {
    set result "no interface errors found"
    error $result 
}

# 5. send the email out 
set routername [info hostname]
if {[string match "" $routername]} {
    error "Host name is not configured"
}

if [catch {smtp_subst [file join $tcl_library email_template_cmd.tm]} result] {
    error $result $errorInfo
}

if [catch {smtp_send_email $result} result] {
    error $result $errorInfo
}
