# common parameters
class restic::params {
  # yum/deb repo
  # we don't need custom repo for RHEL, since it uses EPEL
  $repo_manage = false
  $repo_ensure = 'present'

  # client
  $client = true
  $client_package_name = 'restic'
  $client_package_ensure = 'present'
  $client_repo = undef
  $client_repo_password = undef
  $client_excludes = []
  $client_cache_dir = undef # defaults to ~/.cache/restic

  # server
  $server = false
  $server_type = 'rest'

  # server - rest
  $server_rest_package_name = 'rest-server'
  $server_rest_package_ensure = 'present'
  $server_rest_service_name = 'rest-server'
  $server_rest_service_ensure = 'running'
  $server_rest_service_enable = true
  $server_rest_user = 'restsvr'
  $server_rest_group = 'restsvr'
  $server_rest_config_path = '/etc/sysconfig/rest-server'
  $server_rest_config_mode = '0600'
  $server_rest_config_template = 'restic/etc/sysconfig/rest-server.epp'
  $server_rest_path_mode = '0750'
  $server_rest_path = '/tmp/restic'
  $server_rest_firewall_manage = true
  $server_rest_firewall_service = 'rest-server'
  $server_rest_firewall_ensure = 'present'
  $server_rest_firewall_zone = 'public'
  $server_rest_htpasswd_package = 'httpd-tools'
}
