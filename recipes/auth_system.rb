#
# Cookbook:: osl-imap
# Recipe:: auth_system
#
# Copyright:: 2018-2021, Oregon State University
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

# conf.d/10-auth.conf
# Authenticate with username only (no domain, passwd doesn't support it)
node.default['dovecot']['conf']['auth_username_format'] = '%n'

# conf.d/auth-system.conf
if node['osl-imap']['auth_system']['enable_passdb']
  node.default['dovecot']['auth']['system']['passdb']['args'] = 'dovecot'
else
  node.default['dovecot']['auth']['system']['passdb'] = []
end

if node['osl-imap']['auth_system']['enable_userdb']
  node.default['dovecot']['auth']['system']['userdb']['driver'] = 'passwd'
else
  node.default['dovecot']['auth']['system']['userdb'] = []
end
