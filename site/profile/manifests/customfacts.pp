# Base profile for Windows OS
class profile::customfacts {
  $os = $facts['os']['family']
  if $facts['os']['family'] == 'RedHat' {
    notify { "It is ${os}": }
  } else {
    notify { "This is not Centos but ${os}": }
  }

# if $::pf_svc  {
#   notify{"It does exist ${::pf_svc}":}
#     } else {
#       notify{"file ${::pf_svc} does not exist":}
# }
# if $::hello  {
#   notify{"${::hello} does exist ":}
#     } else {
#       notify{" ${::hello} does not exist":}
# }
# if ($::uptime_hours > 1) {
#   notify{"System has been up for over ${::uptime_hours} hours ":}
#   } else {
#     notify{"System has been up for under ${::uptime_hours} hours ":}
# }
  # notify { "Hardware platform is ${::hardware_platform} . ": }
  notify { "os family is ${::osfamily} . ": }
  notify { "${::users} users logged in": }
}
