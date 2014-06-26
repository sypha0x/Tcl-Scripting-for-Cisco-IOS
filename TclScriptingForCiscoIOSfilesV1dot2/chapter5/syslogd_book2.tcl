# Syslog Daemon & socket example

#all incoming connection will be on the socket named "my_sock"
    global my_sock
#all incoming texutal data will be on the socket named "my_sock"
    global my_data
#save the mode of operation : 1 writing to consle or 
#                             2 writing to console and file
    global my_mode
# the file handle
    global my_file
#Listener procedure handles starting and stoping the server 
# as well as calling on_connect procedure for incoming socket connections 
proc Listener {port action filename} {
# the global variable is known by the procedure also
    global my_sock
    global my_file
    global my_mode

    set my_mode 0
    if {$action == "START"} {
	# we are being told to startup, so open a socket and save the 
	# socket handle in my_sock.  Also tell the socket to call
	# on_connect procedure for any incoming connections
	set my_sock [socket -server on_connect $port]
	# keep track that we are only going to write to console only
	set my_mode 1
    } elseif {$action == "STARTWriting"} {
	set my_sock [socket -server on_connect $port]
	set my_file [open $filename WRONLY]
	# keep track that we are only going to write to console and file
	set my_mode 2
    } else {
	# we are being told to shutdown, so close the socket for 
	# cleeanup purposes
      if {[info exists my_sock]} {
	  #if the socket is really there, close it
		puts "Closing my socket"

          close $my_sock
      }
    }
    return $my_sock
}


# Procedure on_connect is called whenever a new socket connection is
# made by a syslog server
proc on_connect {newsock clientAddress clientPort} {
    puts "socket is connected now"
    # configure the socket for noblocking operation
    # this is importand because we don't want to block on any read later
    fconfigure $newsock -blocking 0 
    # if the new socket is readable, then set the procedure handleInput
    # to be called whenever input arrives
    fileevent  $newsock readable [list handleInput $newsock]
}


# Procedure called whenever input arrives on the readable socket 
# connection.
proc handleInput {f} {
#provide access to global variables  even inside the procedures 
# by declaring them global
    global my_data
    global my_file
    global my_mode

    # Delete the handler if the socket was closed for example the 
    # other side closes the socket.  This is important because we would
    # otherwise try to read data from a closed socket
    if {[eof $f]} {
	# we got the End of File character: clean up
	# first, remove the handleInput procedure for incoing events
	# on the socket, set it to an empty list
        fileevent $f readable {}
	# close the socket
        close     $f
	# exit procedure
        return
    }

    # Read and handle the incoming text data

    # save the text data into my_data
    set my_data [read -nonewline $f]
    # remove any nonprintable characters using a regular expression
    regsub -all  {<[0-9]+>[0-9]+: } $my_data " " output

    # check if there was text data
    if {[string length $output]} {
	# there was some data to print, show it to the user
	puts stdout "$output"
	# check if we need to write to the file also
	if {[expr ($my_mode == 2)]} {
	    # write the data to the file
	    puts $my_file $output
	}
    }
    # at this point we will wait again for more data
}

# The beginning of the TCL script, so far we have just defined
# procedures above this point

# Usage guidelines:
# syslogd <port> [filename]
# port is the TCP port to listing for incoming connection
# filename is optional to write the Syslog data

if {$argc == 0} {
    puts "Usage: syslogd port filename"
    puts "port is the TCP port to listing for incoming connection"
    puts "filename is optional parameter to use for writing the Syslog data"
    return
}
set port [lindex $argv 0]
#verfy that the user provided port is a number, by check if the port
# is a digit.  
# if the port is a digit "string is ..." returns us a value of 1
# so compare the value to 1 and terminate the script if it doesn't match
if {[expr (1 != [string is digit $port])]} {
    puts "must provide a numeric port number"
    return
}
if {$argc == 1} {
#user only provides one input parameter, port
    Listener $port START 0
} elseif {$argc == 2} {
#user provides 2 input parameters, port and filename
# save the filename the user provided in my_filename
    set my_filename [lindex $argv 1]
# call the procedure to listen for incoming Syslog connection
# and tell the procedure to also write messages to a file
    Listener $port STARTWriting $my_filename
} else {
#user provided more than 2 input parameters and there is atleast one
# extra arg we don't understand so we remind them of the correct usage
# and end the script 
    puts "Usage: syslogd port filename"
    puts "port is the TCP port to listing for incoming connection"
    puts "filename is optional parameter to use for writing the Syslog data"
    return
}

# set the break key to ESC key
exec "term esc 27"
# call the procedure to listen for incoming socket, using tcp port
# provided by user input
# wait for any events on the incoming socket connection
vwait my_sock
