package provide square 1.0

# Create the namespace
namespace eval ::square {
    # Export commands
    namespace export square
}

proc ::square::area {height} {
  return [expr $height * $height]
}
