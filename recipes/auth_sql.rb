#
# Cookbook:: osl-imap
# Recipe:: auth_sql
#
# Copyright:: 2018, Oregon State University
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

auth_sql = node['osl-imap']['auth_sql']
creds = data_bag_item(auth_sql['data_bag'], auth_sql['data_bag_item'])

# conf.d/auth-sql.conf
%w(userdb passdb).each do |db|
  if auth_sql["enable_#{db}"]
    node.default['dovecot']['auth']['sql'][db]['args'] = '/etc/dovecot/dovecot-sql.conf.ext'
  else
    node.default['dovecot']['auth']['sql'][db] = []
  end
end

# dovecot-sql.conf.ext
node.default['dovecot']['conf']['sql']['default_pass_scheme'] = 'SHA512-CRYPT'

case creds['type']
when 'mysql', 'pgsql'
  node.default['dovecot']['conf']['sql']['driver'] = creds['type']
else
  raise "osl-imap::auth_sql currently only supports database drivers 'mysql' & 'pgsql' in
node['dovecot']['conf']['sql']['driver']. Fix the databag or update the recipe."
end
