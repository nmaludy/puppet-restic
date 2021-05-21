# Sets up a config file with environment variables for some common restic options
#
# Also configures the restic password file that will be used for authenticated repositories.
#
class restic::client::config (
  String $dir = '/etc/restic',
  String $dir_mode = '0755',
  String $pre_dir = "${dir}/pre.d",
  String $post_dir = "${dir}/post.d",
  String $config_path = "${dir}/restic.env",
  String $template = 'restic/etc/restic/restic.env.epp',
  String $password_file_path = "${dir}/restic.pass",
  String $mode = '0600',
  String $owner = 'root',
  String $group = 'root',
  Optional[String] $password = undef,
  Optional[String] $repo = $restic::client::repo,
  Optional[String] $repo_password = $restic::client::repo_password,
  String $excludes_path = "${dir}/excludes.txt",
  String $excludes_template = 'restic/etc/restic/excludes.txt.epp',
  Array[String] $excludes = $restic::client::excludes,
  String $log_dir = '/var/log/restic',
  String $logrotate_path = '/etc/logrotate.d/restic',
  String $logrotate_template = 'restic/etc/logrotate.d/restic.epp',
) inherits restic::client {
  file { [$dir, $log_dir, $pre_dir, $post_dir]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $dir_mode,
  }

  file { $config_path:
    ensure    => file,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => false,
    content   => epp($template, {
      variables => {
        'RESTIC_REPOSITORY' => $repo,
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
    content   => "$repo_password\n",
  }

  file { $excludes_path:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => epp($excludes_template, { excludes => $excludes }),
  }

  file { $logrotate_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp($logrotate_template),
  }
}
