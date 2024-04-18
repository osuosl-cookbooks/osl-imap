#
# Cookbook:: osl-imap
# Recipe:: default
#
# Copyright:: 2018-2024, Oregon State University
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

auth_sql    = node['osl-imap']['auth_sql']
auth_system = node['osl-imap']['auth_system']

auth_sql_enabled    = auth_sql['enable_userdb'] || auth_sql['enable_passdb']
auth_system_enabled = auth_system['enable_userdb'] || auth_system['enable_passdb']

creds = auth_sql_enabled ? data_bag_item(auth_sql['data_bag'], auth_sql['data_bag_item']) : {}

# Enable IMAP & POP3
%w(imap pop3).each do |protocol|
  node.default['dovecot']['protocols'][protocol] = {}
end

# Disable non-TLS IMAP and POP3 ports (143 & 110)
%w(imap pop3).each do |protocol|
  node.default['dovecot']['services']["#{protocol}-login"]['listeners'] = [{ "inet:#{protocol}" => { 'port' => 0 } }]
end

# conf.d/10-auth.conf
# Enable plaintext auth mechanisms as defaults, but disallow using them without TLS
node.default['dovecot']['conf']['auth_mechanisms'] = %w(plain login)
node.default['dovecot']['conf']['disable_plaintext_auth'] = true
node.default['dovecot']['conf']['ssl_cipher_list'] = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:!DES-CBC3-SHA:!DSS'
node.default['dovecot']['conf']['ssl_dh_parameters_length'] = '2048'
node.default['dovecot']['conf']['ssl_options'] = 'no_compression no_ticket'
node.default['dovecot']['conf']['ssl_prefer_server_ciphers'] = 'yes'
node.default['dovecot']['conf']['ssl_protocols'] = 'TLSv1.2'

# Authentication socket for use with Postfix
node.default['dovecot']['services']['auth']['listeners'] = [
  {
    'unix:/var/spool/postfix/private/auth' => {
      'mode'  => '0660',
      'user'  => 'postfix',
      'group' => 'postfix',
    },
  },
]

unless node['osl-imap']['letsencrypt']
  # conf.d/10-ssl.conf
  node.default['dovecot']['conf']['ssl'] = 'required'
  node.default['dovecot']['conf']['ssl_cert'] = '</etc/pki/tls/certs/wildcard.pem'
  node.default['dovecot']['conf']['ssl_key']  = '</etc/pki/tls/private/wildcard.key'
  certificate_manage 'wildcard' do
    cert_file 'wildcard.pem'
    key_file 'wildcard.key'
    chain_file 'wildcard-bundle.crt'
    notifies :reload, 'service[dovecot]'
  end
end

osl_firewall_imaps_pop3s 'osl-imap'

include_recipe 'osl-imap::auth_system' if auth_system_enabled
include_recipe 'osl-imap::auth_sql'    if auth_sql_enabled
include_recipe 'osl-imap::lmtp'        if node['osl-imap']['enable_lmtp']
include_recipe 'dovecot::default'

# edit connection info into the template to avoid putting secrets in attributes
edit_resource(:template, '(core) dovecot-sql.conf.ext') do
  cookbook 'osl-imap'
  variables(
    auth: node['dovecot']['auth'].to_hash,
    protocols: node['dovecot']['protocols'].to_hash,
    services: node['dovecot']['services'].to_hash,
    plugins: node['dovecot']['plugins'].to_hash,
    namespaces: node['dovecot']['namespaces'],
    conf: node['dovecot']['conf'],
    connect: %W(
      host=#{creds['host']}
      dbname=#{creds['db']}
      user=#{creds['user']}
      password=#{creds['pass']}
    ),
      sensitive: true
  )
  only_if { auth_sql_enabled }
end
