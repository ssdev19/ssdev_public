lookup('classes').include

if $OperatingSystem != 'Linux' {
  $packages = lookup(
    name          => 'packages',
    value_type    => Variant[Array[String], Undef],
    merge         => 'unique',
    default_value => undef,
  )
  if ($packages) {
    ensure_packages($packages)
  }
}
