# Installs restic client/server
class restic (
  Boolean $client = true,
  String $client_package_name = 'restic',
  String $client_package_ensure = 'present',
  Optional[String] $client_repo_password = undef,
  Boolean $server = false,
  Enum['rest'] $server_type = 'rest',
  Boolean $repo_manage = true,
) {
  contain restic::repo
  if $client {
    contain restic::client
  }
  if $server {
    contain restic::server
  }
}
