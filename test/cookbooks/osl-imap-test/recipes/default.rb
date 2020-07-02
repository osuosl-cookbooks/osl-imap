#
# Cookbook:: osl-imap-test
# Recipe:: default
#
# Copyright:: 2018-2020, Oregon State University
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

# Use PAM to authenticate users
node.default['osl-imap']['auth_system']['enable_userdb'] = true
node.default['osl-imap']['auth_system']['enable_passdb'] = true

user 'foo' do
  password '$1$B7Bo6eja$C5aj4AIKxw437TcwiTWnR1' # "bar"
  home '/home/foo'
  manage_home true
end

# Install expect for default suite's tests
package 'expect'
