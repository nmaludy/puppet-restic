# Install and configure restic client
class restic::client (
  String $package_name = $restic::client_package_name,
  String $package_ensure = $restic::client_package_ensure,
  Optional[String] $repo = $restic::client_repo,
  Optional[String] $repo_password = $restic::repo_password,
) inherits restic {
  contain restic::client::install
  contain restic::client::config
}
