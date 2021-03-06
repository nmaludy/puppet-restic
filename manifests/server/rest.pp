# Installs the restic REST server
class restic::server::rest (
  String $package_name = $restic::params::server_rest_package_name,
  String $package_ensure = $restic::params::server_rest_package_ensure,
  String $service_name = $restic::params::server_rest_service_name,
  String $service_ensure = $restic::params::server_rest_service_ensure,
  Boolean $service_enable = $restic::params::server_rest_service_enable,
  String $user = $restic::params::server_rest_user,
  String $group = $restic::params::server_rest_group,
  String $config_path = $restic::params::server_rest_config_path,
  String $config_owner = $user,
  String $config_group = $group,
  String $config_mode = $restic::params::server_rest_config_mode,
  String $config_template = $restic::params::server_rest_config_template,
  String $path_mode = $restic::params::server_rest_path_mode,
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
  Optional[String] $path = $restic::params::server_rest_path,
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
  Boolean $firewall_manage = $restic::params::server_rest_firewall_manage,
  String $firewall_service = $restic::params::server_rest_firewall_service,
  String $firewall_ensure = $restic::params::server_rest_firewall_ensure,
  String $firewall_zone = $restic::params::server_rest_firewall_zone,
  # user => password
  Hash $users = {},
  String $htpasswd_package = $restic::params::server_rest_htpasswd_package,
  String $htpasswd_file_path = "${path}/.htpasswd",
  String $htpasswd_file_mode = $config_mode,
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

  # create the share directory
  if $path {
    file { $path:
      ensure => directory,
      owner  => $config_owner,
      group  => $config_group,
      mode   => $path_mode,
      notify => Service[$service_name],
    }

    # initialize the restic repo
    exec { "restic - init ${path}":
      command  => '. /etc/restic/restic.env && restic init',
      path     => ['/usr/bin', '/sbin', '/bin'],
      creates  => "${path}/config",
      provider => shell,
      require  => [
        File[$path],
        File['/etc/restic/restic.env'],
      ],
      notify   => Service[$service_name],
    }
  }

  if !defined(Service[$service_name]) {
    service { $service_name:
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package[$package_name],
      subscribe => File[$config_path],
    }
  }

  if $firewall_manage {
    firewalld_service { $firewall_service:
      ensure => $firewall_ensure,
      zone   => $firewall_zone,
    }
  }

  if !defined(Package[$htpasswd_package]) {
    package { $htpasswd_package:
      ensure  => $package_ensure,
      require => Class['restic::repo'],
    }
  }

  file { $htpasswd_file_path:
    ensure => file,
    owner  => $config_owner,
    group  => $config_group,
    mode   => $htpasswd_file_mode,
  }
  $users.each |$u, $p| {
    # -c  Create a new file.
    # -n  Don't update file; display results on stdout.
    # -b  Use the password from the command line rather than prompting for it.
    # -i  Read password from stdin without verification (for script usage).
    # -m  Force MD5 encryption of the password (default).
    # -2  Force SHA-256 crypt() hash of the password (secure).
    # -5  Force SHA-512 crypt() hash of the password (secure).
    # -B  Force bcrypt aencryption of the password (very secure).
    # -C  Set the computing time used for the bcrypt algorithm
    #     (higher is more secure but slower, default: 5, valid: 4 to 31).
    # -r  Set the number of rounds used for the SHA-256, SHA-512 algorithms
    #     (higher is more secure but slower, default: 5000).
    # -d  Force CRYPT encryption of the password (8 chars max, insecure).
    # -s  Force SHA-1 encryption of the password (insecure).
    # -p  Do not encrypt the password (plaintext, insecure).
    # -D  Delete the specified user.
    # -v  Verify password for the specified user.
    exec { "restic REST server user: $u":
      path    => ['/usr/bin', '/sbin', '/bin'],
      command => "htpasswd -B -b '${htpasswd_file_path}' '${u}' '${p}'",
      unless  => "htpasswd -B -b -v '${htpasswd_file_path}' '${u}' '${p}'",
      require => [
        Package[$htpasswd_package],
        File[$htpasswd_file_path],
      ]
    }
  }
}
