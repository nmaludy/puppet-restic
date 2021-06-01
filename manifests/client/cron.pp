# creates a backup script and cron job
define restic::client::cron (
  Variant[Array[String], String] $args,
  String $owner = 'root',
  String $group = 'root',
  String $mode  = '0750',
  String $template = 'restic/etc/restic/restic.sh.epp',
  String $dir = $restic::client::config::dir,
  String $log_dir = $restic::client::config::log_dir,
  String $log_path = "${log_dir}/${name}.log",
  String $config_path = $restic::client::config::config_path,
  String $script_path = "${dir}/${name}.sh",
  Boolean $manage_cron = true,
  String $cron_minute  = '0',
  String $cron_hour    = '3',
  String $cron_date    = '*',
  String $cron_month   = '*',
  String $cron_weekday = '*',
  Array[String] $cron_env = [],
) {
  if $args =~ Array[String] {
    $_args = $args.join(' ')
  }
  else {
    $_args = $args
  }

  file { $script_path:
    ensure    => file,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => false,
    content   => epp($template, {
      args        => $_args,
      config_path => $config_path,
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
