class restic::repo (
  String $ensure = $restic::repo_ensure,
  Boolean $manage = $restic::repo_manage,
) inherits restic {
  if $manage and $facts['os']['family'] == 'RedHat' {
    $repo_name = 'copart-restic-epel'
    $repo_path = "/etc/yum.repos.d/${repo_name}.repo"
    $os_maj = $facts['os']['release']['major']

    yumrepo { $repo_name:
      ensure              => $ensure,
      descr               => 'Copr repo for restic owned by copart',
      baseurl             => "https://download.copr.fedorainfracloud.org/results/copart/restic/epel-${os_maj}-\$basearch/",
      skip_if_unavailable => 'true',
      gpgcheck            => '1',
      gpgkey              => 'https://download.copr.fedorainfracloud.org/results/copart/restic/pubkey.gpg',
      repo_gpgcheck       => '0',
      enabled             => '1',
    }

    # yumrepo doesn't support all of the settings we need for this repo, add the extra settings
    # by themselves
    $settings_hash = {
      'type'             => 'rpm-md',
      'enabled_metadata' => '1',
    }
    $settings_hash.each |$setting, $value| {
      ini_setting { "${repo_path}:${repo_name}:${setting}":
        ensure            => $ensure,
        path              => $repo_path,
        section           => $repo_name,
        setting           => $setting,
        value             => $value,
        key_val_separator => '=',
        require           => Yumrepo[$repo_name],
      }
    }
  }
}
