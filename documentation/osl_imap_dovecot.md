# osl_imap_dovecot

## Action

- `:create`: Creates dovecot services

## Properties

## Global properties

| Property               | Type    | Default             | Required | Description                                                    |
|------------------------|---------|---------------------|----------|----------------------------------------------------------------|
| `auth_mechanisms`      | String  | `plain login`       |          | Authentication mechanisms                                      |
| `auth_type`            | Symbol  |                     | yes      | Authentication type                                            |
| `auth_username_format` | String  | `%n`                |          | Username formatting                                            |
| `letsencrypt`          | Boolean | `false`             |          | Setup SSL using LetsEncrypt                                    |
| `mail_location`        | String  | `maildir:~/Maildir` |          | Location for users' mailboxes                                  |
| `mbox_write_locks`     | String  | `dotlock fcntl`     |          | Which locking methods to use for locking mbox                  |
| `protocols`            | String  | `imap pop3`         |          | Protocols we want to be serving                                |
| `ssl_cert`             | String  |                     |          | Path of SSL cert (automatically set when using wildcard or LE) |
| `ssl_key`              | String  |                     |          | Path of SSL Key (automatically set when using wildcard or LE)  |
| `wildcard_cert`        | Boolean |                     |          | Use wildcard SSL cert                                          |


### MySQL Authentication properties

These properties are only used with MySQL authentication.

| Property              | Type   | Default        | Description                                     |
|-----------------------|--------|----------------|-------------------------------------------------|
| `db_host`             | String |                | Database host                                   |
| `db_name`             | String |                | Database name                                   |
| `db_pass`             | String |                | Database password                               |
| `db_user`             | String |                | Database username                               |
| `default_pass_scheme` | String | `SHA512-CRYPT` | Default password scheme                         |
| `iterate_query`       | String |                | Query to get a list of all usernames            |
| `password_query`      | String |                | `passdb` query to retrieve the password         |
| `user_query`          | String |                | `userdb` query to retrieve the user information |


### LDAP Authentication properties
| Property    | Type   | Description      |
|-------------|--------|------------------|
| `ldap_base` | String | LDAP base        |
| `ldap_uris` | String | LDAP URIs to use |

## Examples

```ruby
# Use system auth
osl_imap_dovecot 'default' do
  auth_type :system
  wildcard_cert true
end

# Use LDAP auth
osl_imap_dovecot 'ldap' do
  auth_type :ldap
  wildcard_cert true
  auth_username_format '%Lu'
  ldap_uris 'ldaps://ldap.osuosl.org'
  ldap_base 'ou=People,dc=osuosl,dc=org'
end

# Use MySQL auth
osl_imap_dovecot 'sql' do
  auth_type :mysql
  auth_username_format '%Lu'
  wildcard_cert true
  db_host 'hostname'
  db_user 'username'
  db_pass 'password'
  db_name 'database'
  iterate_query 'SELECT username, domain FROM users'
  password_query "SELECT username, domain, password FROM users WHERE username = '%n' AND domain = '%d'"
  user_query "SELECT home, uid, gid FROM users WHERE username = '%n' AND domain = '%d'"
end

# Enable LMTP service
osl_imap_dovecot 'lmtp' do
  auth_type :system
  protocols 'imap pop3 lmtp'
  wildcard_cert true
end

# Use LetsEncrypt
osl_imap_dovecot 'imap.osuosl.org' do
  auth_type :system
  letsencrypt true
end
```
