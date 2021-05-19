# Install restic client
class restic::client::install (
  String $package_name = $restic::client::package_name,
  String $package_ensure = $restic::client::package_ensure,
) inherits restic::client {
  if !defined(Package[$package_name]) {
    package { $package_name:
      ensure => $package_ensure,
    }
  }
}
