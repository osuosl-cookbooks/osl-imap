#
# Cookbook:: osl-imap-test
# Recipe:: auth_sql
#
# Copyright:: 2018-2022, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

node.default['dovecot']['conf']['mail_location'] = 'maildir:~/Maildir'
node.default['postfix']['main']['home_mailbox'] = 'Maildir/'
node.default['postfix']['main']['mydestination'] = 'foo.org'

include_recipe 'osl-postfix'

user 'foo' do
  uid 1234
  home '/home/foo'
  manage_home true
end

# Install expect for default suite's tests
package 'expect'

node.default['dovecot']['conf']['sql']['iterate_query'] = 'SELECT username, domain FROM users'
node.default['dovecot']['conf']['sql']['password_query'] = 'SELECT username, domain, password ' \
  "FROM users WHERE username = '%n' AND domain = '%d'"
node.default['dovecot']['conf']['sql']['user_query'] = 'SELECT home, uid, gid FROM users ' \
  "WHERE username = '%n' AND domain = '%d'"

# Set up SQL database containing user and password info for Dovecot SQL auth
node.default['percona']['skip_passwords'] = true

include_recipe 'osl-mysql::server'

db = data_bag_item(node['osl-imap']['auth_sql']['data_bag'],
                   node['osl-imap']['auth_sql']['data_bag_item'])

percona_mysql_user db['user'] do
  database_name db['db']
  password db['pass']
  ctrl_password 'password'
  action [:create, :grant]
end

percona_mysql_database 'test' do
  database_name db['db']
  password 'password'
  sql <<-EOT
    USE #{db['db']};
    CREATE TABLE IF NOT EXISTS users (
      username VARCHAR(128) NOT NULL UNIQUE,
      domain VARCHAR(128) NOT NULL,
      password VARCHAR(120) NOT NULL,
      home VARCHAR(255) NOT NULL,
      uid INTEGER NOT NULL,
      gid INTEGER NOT NULL
    );
  EOT
  action [:create, :query]
end

percona_mysql_database '' do
  database_name db['db']
  password 'password'
  # Note the extra breaks in the password field are needed to make sure mariadb doesn't try to format the numbers after $
  sql "USE #{db['db']}; INSERT IGNORE INTO users VALUES ('foo', 'foo.org', '{SHA512-CRYPT}$' '6' '$.rQ8TNWq1dDlHMF3' '$' 'R4Wb8DaF5TNjeequKpMKHIBKlZIbHvoQwikWTTEMmKO7i8tTmQyVFNoqBUsO2h.1.PkkfaMqbTI88mSSKAU580', '/home/foo', 1234, 100);"
  action :query
end
