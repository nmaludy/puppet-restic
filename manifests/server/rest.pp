# Installs the restic REST server
class restic::server::rest (
  String $package_name = 'rest-server',
  String $package_ensure = 'present',
) inherits restic::server {
  if !defined(Package[$package_name]) {
    package { $package_name:
      ensure  => $package_ensure,
      require => Class['restic::repo'],
    }
  }
}
