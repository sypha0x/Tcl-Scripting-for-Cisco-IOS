set mybuffer [exec "show ip interface brief"]
set foundposition [string first "10.0.0." $mybuffer]
if {$foundposition > -1} {
    puts "We found the 10.0.0.* network!"
}
