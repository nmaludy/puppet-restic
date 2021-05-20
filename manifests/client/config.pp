# Sets up a config file with environment variables for some common restic options
#
# Also configures the restic password file that will be used for authenticated repositories.
#
class restic::client::config (
  String $dir = '/etc/restic',
  String $dir_mode = '0750',
  String $config_path = "${dir}/restic.env",
  String $password_file_path = "${dir}/restic.pass",
  String $template = 'restic/etc/restic/restic.env.epp',
  String $mode = '0600',
  String $owner = 'root',
  String $group = 'root',
  Optional[String] $password = undef,
  Optional[String] $repo = $restic::client::repo,
  Optional[String] $repo_password = $restic::client::repo_password,
) inherits restic::client {
  file { $dir:
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
}
