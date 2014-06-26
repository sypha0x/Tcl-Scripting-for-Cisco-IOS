if [string match "*by console" $::orig_msg] {
    return ""
} else {
    return $::orig_msg
}
