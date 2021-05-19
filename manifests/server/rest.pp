# Installs the restic REST server
class restic::server::rest (
  String $package_name = 'rest-server',
  String $package_ensure = 'present',
  String $service_name = 'rest-server',
  String $service_ensure = 'running',
  Boolean $service_enabl = true,
  String $config_path = '/etc/sysconfig/rest-server',
  String $config_owner = 'root',
  String $config_group = 'root',
  String $config_mode = '0644',
  String $config_template = 'restic/etc/sysconfig/rest-server.epp',
  # --append-only enable append only mode
  Optional[Boolean] $append_only = undef,
  # --cpu-profile write CPU profile to file
  Optional[String] $cpu_profile =  undef,
  # --debug                output debug messages
  Optional[Boolean] $debug =  undef,
  # --listen                listen address (default ":8000")
  Optional[String] $listen =  undef,
  # --log                log HTTP requests in the combined log format
  Optional[String] $log =  undef,
  # --max-size                the maximum size of the repository in bytes
  Optional[Integer] $max_size =  undef,
  # --no-auth              disable .htpasswd authentication
  Optional[Boolean] $no_auth =  undef,
  # --path              data directory (default "/tmp/restic")
  Optional[String] $path = '/tmp/restic',
  # --private-repos        users can only access their private repo
  Optional[Boolean] $private_repos = undef,
  # --prometheus           enable Prometheus metrics
  Optional[Boolean] $prometheus = undef,
  # --tls                  turn on TLS support
  Optional[Boolean] $tls = undef,
  # --tls-cert string      TLS certificate path
  Optional[String] $tls_cert = undef,
  # --tls-key string       TLS key path
  Optional[String] $tls_key = undef,
  # override or add additional arguments
  # format is '--arg-name' => 'value'
  Hash $extra_args = {},
) inherits restic::server {
  if !defined(Package[$package_name]) {
    package { $package_name:
      ensure  => $package_ensure,
      require => Class['restic::repo'],
    }
  }

  $args = {
    '--append-only' => $append_only,
    '--cpu-profile' => $cpu_profile,
    '--debug' => $debug,
    '--listen' => $listen,
    '--log' => $log,
    '--max-size' => $max_size,
    '--no-auth' => $no_auth,
    '--path' => $path,
    '--private-repos' => $private_repos,
    '--prometheus' => $prometheus,
    '--tls' => $tls,
    '--tls-cert' => $tls_cert,
    '--tls-key' => $tls_key,
  }

  # hash merge, right most wins
  $set_args = ($args + $extra_args).filter |$k, $v| {
    # only allow boolean flags through if they are set to true
    if $v =~ Boolean {
      $v != undef and $v == true
    }
    else {
      $v != undef
    }
  }
  # convert to argument strings and join with space
  $server_args = $set_args.map |$k, $v| { "$k $v" }.join(' ')
  file { $config_path:
    ensure => file,
    owner  => $config_owner,
    group  => $config_group,
    mode   => $config_mode,
    content => epp($config_template, {
      server_args => $server_args,
    }),
  }

  if !defined(Service[$service_name]) {
    service { $service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package[$package_name],
      subscribe => File[$config_path],
    }
  }
}
