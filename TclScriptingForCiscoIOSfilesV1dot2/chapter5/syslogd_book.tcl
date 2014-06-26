# Syslog Daemon & socket example

#all incoming connection will be on the socket named "my_sock"
    global my_sock
#all incoming texutal data will be on the socket named "my_sock"
    global my_data
#Listener procedure handles starting and stoping the server 
# as well as calling on_connect procedure for incoming socket connections 
proc Listener {port action} {
# the global variable is known by the procedure also
    global my_sock
    if {$action == "START"} {
	# we are being told to startup, so open a socket and save the 
	# socket handle in my_sock.  Also tell the socket to call
	# on_connect procedure for any incoming connections
      set my_sock [socket -server on_connect $port]
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
    global my_data

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

    # set my_file [ open /var/log/router_tcp.log a ]

    # save the text data into my_data
    set my_data [read -nonewline $f]
    # remove any nonprintable characters using a regular expression
    regsub -all  {<[0-9]+>[0-9]+: } $my_data " " output

    # check if there was text data
    if {[string length $output]} {
	# there was some data to print, show it to the user
	puts stdout "$output"
    }
    # at this point we will wait again for more data
}

# The beginning of the TCL script, so far we have just defined
# procedures above this point

# set the break key to ESC key
exec "term esc 27"
# call the procedure to listen for incoming socket, using tcp port 9500
Listener 9500 START
# wait for any events on the incoming socket connection
vwait my_sock

