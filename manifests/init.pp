# Installs restic client/server
class restic (
  String $repo_password,
  Boolean $client                = $restic::params::client,
  Array[String] $client_excludes = $restic::params::client_excludes,
  String $client_package_name    = $restic::params::client_package_name,
  String $client_package_ensure  = $restic::params::client_package_ensure,
  Optional[String] $client_repo  = $restic::params::client_repo,
  Boolean $server                = $restic::params::server,
  Enum['rest'] $server_type      = $restic::params::server_type,
  String $repo_ensure            = $restic::params::repo_ensure,
  Boolean $repo_manage           = $restic::params::repo_manage,
) inherits restic::params {
  contain restic::repo
  if $client {
    contain restic::client
  }
  if $server {
    contain restic::server
  }
}
