# Installs restic client/server
class restic (
  Boolean $client = true,
  String $client_package_name = 'restic',
  String $client_package_ensure = 'present',
  Boolean $server = false,
) {
  if $client {
    contain restic::client
  }
  if $server {
    contain restic::server
  }
}
