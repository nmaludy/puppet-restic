# Installs and configures different kinds of restic servers
#
# Currently on the Restic REST server is supported.
# In the future might be handy to setup a SFTP/SSH server.
class restic::server (
  # TODO implement 'local' and 'sftp' as well
  Enum['rest'] $server_type = $restic::server_type,
) inherits restic {
  case $server_type {
    'rest': { contain restic::server::rest }
    default: {}
  }
}
