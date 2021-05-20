# Installs restic client/server
class restic (
  Boolean $client                        = $restic::params::client,
  String $client_package_name            = $restic::params::client_package_name,
  String $client_package_ensure          = $restic::params::client_package_ensure,
  Optional[String] $client_repo_password = $restic::params::client_repo_password,
  Boolean $server                        = $restic::params::server,
  Enum['rest'] $server_type              = $restic::params::server_type,
  Boolean $repo_manage                   = $restic::params::repo_manage,
) inherits restic::params {
  contain restic::repo
  if $client {
    contain restic::client
  }
  if $server {
    contain restic::server
  }
}
