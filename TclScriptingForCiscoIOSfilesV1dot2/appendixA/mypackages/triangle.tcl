package provide triangle 1.0

# Create the namespace
namespace eval ::triangle {
    # Export commands
    namespace export triangle
}

proc ::triangle::area {base height} {
  return [expr 0.5 * $base * $height]
}
