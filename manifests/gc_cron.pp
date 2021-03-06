# @summary Schedule PuppetDB (PostgreSQL data) garbage collection via cron
#
# Manage Schedule (PostgreSQL data) garbage collection via cron
#
# @example
#   puppetdb_gc::gc_cron { 'namevar': }
define puppetdb_gc::gc_cron (
  Enum['absent', 'present'] $gc_cron_ensure               = 'present',
  Boolean                   $use_ssl                      = true,
  String                    $puppetdb_host                = $use_ssl ? {
                                                              true  => $facts['networking']['fqdn'],
                                                              false => '127.0.0.1',
                                                            },
  Integer                   $puppetdb_port                = $use_ssl ? {
                                                              true  => 8081,
                                                              false => 8080,
                                                            },
  String                    $api_command                  = 'clean',
  Integer                   $api_version                  = 1,
  String                    $api_payload                  = $title,
  Optional[Variant[Integer, Array[Integer], Enum['absent']]] $cron_minute = undef,
  Optional[Variant[Integer, Array[Integer], Enum['absent']]] $cron_hour   = undef,
  Optional[Variant[Integer, Array[Integer], Enum['absent']]] $cron_day    = undef,
  String                    $postgresql_host              = $puppetdb_host,
  Boolean                   $vacuum_reports               = false,
)
{
  cron { "puppet_db_gc_${title}" :
    ensure   => $gc_cron_ensure,
    command  => epp('puppetdb_gc/puppetdb_cmd_curl.epp',
                  {
                    use_ssl         => $use_ssl,
                    puppetdb_host   => $puppetdb_host,
                    puppetdb_port   => $puppetdb_port,
                    api_command     => $api_command,
                    api_version     => $api_version,
                    api_payload     => $api_payload,
                    postgresql_host => $postgresql_host,
                    vacuum_reports  => $vacuum_reports,
                  }
                ),
    user     => 'root',
    minute   => $cron_minute,
    hour     => $cron_hour,
    monthday => $cron_day,
  }
}
