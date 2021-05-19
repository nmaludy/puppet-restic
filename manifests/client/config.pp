class restic::client::config (
  String $dir = '/etc/restic',
  String $dir_mode = '0750',
  String $config_path = "${dir}/restic.conf",
  String $password_file_path = "${dir}/restic.pass",
  String $template = 'restic/etc/restic.conf.epp',
  String $mode = '0600',
  String $owner = 'root',
  String $group = 'root',
  Optional[String] $password = undef,
  Optional[String] $default_repo = undef,
) {
  file { $dir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $dir_mode,
  }

  file { $config_path:
    ensure => file,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    content => epp($template, {
      variables => {
        'RESTIC_REPOSITORY' => $default_repo,
        'RESTIC_PASSWORD_FILE' => $password_file_path,
      },
    }),
  }

  file { $password_file_path:
    ensure    => file,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => false,
    content   => "$password\n",
  }
}