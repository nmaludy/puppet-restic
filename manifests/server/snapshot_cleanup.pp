# creates a backup script and cron job
define restic::server::snapshot_cleanup (
  Optional[Integer] $keep_last     = undef,
  Optional[Integer] $keep_hourly   = undef,
  Optional[Integer] $keep_daily    = undef,
  Optional[Integer] $keep_weekly   = undef,
  Optional[Integer] $keep_monthly  = undef,
  Optional[Integer] $keep_yearly   = undef,
  Optional[String]  $keep_within   = undef,
  Optional[String]  $keep_tag      = undef,
  Optional[String]  $repo          = undef,
  Optional[Variant[Array[String], String]] $global_args = undef,
  Optional[Variant[Array[String], String]] $extra_args = undef,
  Boolean $prune          = true,
  String $owner           = 'root',
  String $group           = 'root',
  String $mode            = '0750',
  String $template        = 'restic/etc/restic/snapshot_cleanup.sh.epp',
  String $dir             = $restic::client::config::dir,
  String $log_dir         = $restic::client::config::log_dir,
  String $log_path        = "${log_dir}/snapshot_cleanup_${name}.log",
  String $config_path     = $restic::client::config::config_path,
  String $script_path     = "${dir}/snapshot_cleanup_${name}.sh",
  Boolean $manage_cron    = true,
  String $cron_minute     = '0',
  String $cron_hour       = '4',
  String $cron_date       = '*',
  String $cron_month      = '*',
  String $cron_weekday    = '*',
  Array[String] $cron_env = [],
) {
  if $global_args =~ Array[String] {
    $_global_args = $global_args.join(' ')
  }
  else {
    $_global_args = $global_args
  }
  if $extra_args =~ Array[String] {
    $_extra_args = $extra_args.join(' ')
  }
  else {
    $_extra_args = $extra_args
  }

  $global_args_hash = {
    '--repo' => $repo,
  }
  $args_hash = {
    '--keep-last'    => $keep_last,
    '--keep-hourly'  => $keep_hourly,
    '--keep-daily'   => $keep_daily,
    '--keep-weekly'  => $keep_weekly,
    '--keep-monthly' => $keep_monthly,
    '--keep-yearly'  => $keep_yearly,
    '--keep-within'  => $keep_within,
    '--keep-tag'     => $keep_tag,
  }

  $global_args_arr = $global_args_hash.reduce([]) |$memo, $a| {
    $flag = $a[0]
    $value = $a[1]
    if $value {
      $memo + [$flag, $value]
    }
    else {
      $memo
    }
  }
  $args_arr = $args_hash.reduce([]) |$memo, $a| {
    $flag = $a[0]
    $value = $a[1]
    if $value {
      $memo + [$flag, $value]
    }
    else {
      $memo
    }
  }
  $args_str = ($args_arr + $global_args_arr + [$_global_args, $_extra_args]).join(' ')
  $prune_args_str = ($global_args_arr + [$_global_args]).join(' ')

  file { $script_path:
    ensure    => file,
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    show_diff => false,
    content   => epp($template, {
      args        => $args_str,
      config_path => $config_path,
      prune       => $prune,
      prune_args  => $prune_args_str,
    }),
  }

  if $manage_cron {
    cron::job { "restic_snapshot_cleanup_${name}":
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
