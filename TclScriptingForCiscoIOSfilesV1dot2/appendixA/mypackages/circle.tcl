package provide circle 1.0

# Create the namespace
namespace eval ::circle {
    # Export commands
    namespace export circle
}

proc ::circle::area {radius} {
  set pi 3.14159265
  return [expr $pi * $radius * $radius]
}
