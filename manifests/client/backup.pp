# creates a backup script and cron job
define restic::client::backup (
  String $path,
  String $owner = 'root',
  String $group = 'root',
  String $mode  = '0750',
  String $template = 'restic/etc/restic/backup.sh.epp',
  String $dir = $restic::client::config::dir,
  String $log_dir = $restic::client::config::log_dir,
  String $log_path = "${log_dir}/${name}.log",
  String $config_path = $restic::client::config::config_path,
  String $excludes_path = $restic::client::config::excludes_path,
  Optional[String] $cache_dir = $restic::client::config::cache_dir,
  String $script_path = "${dir}/${name}.sh",
  Optional[Variant[Array[String], String]] $extra_args = undef,
  Boolean $manage_cron = true,
  String $cron_minute  = '0',
  String $cron_hour    = '3',
  String $cron_date    = '*',
  String $cron_month   = '*',
  String $cron_weekday = '*',
  Array[String] $cron_env = [],
) {
  if $extra_args =~ Array[String] {
    $_extra_args = $extra_args.join(' ')
  }
  else {
    $_extra_args = $extra_args
  }

  file { $script_path:
    ensure    => file,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => false,
    content   => epp($template, {
      backup_path   => $path,
      config_path   => $config_path,
      extra_args    => $_extra_args,
      excludes_path => $excludes_path,
      cache_dir     => $cache_dir,
    }),
  }

  if $manage_cron {
    cron::job { "restic_${name}":
      ensure      => present,
      command     => "${script_path} 2>&1 | tee -a ${log_path}",
      environment => $cron_env,
      minute      => $cron_minute,
      hour        => $cron_hour,
      date        => $cron_date,
      month       => $cron_month,
      weekday     => $cron_weekday,
    }
  }
}
