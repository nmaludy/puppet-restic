class restic::repo (
  Boolean $manage = $restic::repo_manage,
) inherits restic {
  if $manage and $facts['os']['family'] == 'RedHat' {
    $repo_path = '/etc/yum.repos.d/copart-restic-epel.repo'
    $repo_section = 'copr:copr.fedorainfracloud.org:copart:restic'
    $os_maj = $facts['os']['release']['major']
    # file { $repo_path:
    #   ensure  => file,
    #   owner   => 'root',
    #   group   => 'root',
    #   mode    => '0644',
    # }

    yumrepo { 'copart-restic-epel':
      descr               => 'Copr repo for restic owned by copart',
      baseurl             => "https://download.copr.fedorainfracloud.org/results/copart/restic/epel-${os_maj}-\$basearch/",
      type                => 'rpm-md',
      skip_if_unavailable => 'True',
      gpgcheck            => '1',
      gpgkey              => 'https://download.copr.fedorainfracloud.org/results/copart/restic/pubkey.gpg',
      repo_gpgcheck       => '0',
      enabled             => '1',
      enabled_metadata    => '1',
    }
    # $settings_hash = {
    #   'name' => ,
    # }
    # $settings_hash.each |$setting, $value| {
    #   ini_setting { "${repo_path}:${repo_section}:${setting}":
    #     ensure  => present,
    #     path    => $repo_path,
    #     section => $repo_section,
    #     setting => $setting,
    #     value   => $value,
    #   }
    # }
  }
}
