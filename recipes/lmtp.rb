#
# Cookbook:: osl-imap
# Recipe:: lmtp
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

# Reference: https://wiki2.dovecot.org/HowTo/PostfixDovecotLMTP

# Enable LMTP protocol
node.default['dovecot']['protocols']['lmtp'] = {}

node.default['dovecot']['services']['lmtp']['listeners'] = [
  {
    'unix:/var/spool/postfix/private/dovecot-lmtp' => {
      'mode'  => '0600',
      'user'  => 'postfix',
      'group' => 'postfix',
    },
  },
]

# Use LMTP for both local and virtual deliveries
node.default['postfix']['main']['local_transport']   = 'lmtp:unix:private/dovecot-lmtp'
node.default['postfix']['main']['virtual_transport'] = 'lmtp:unix:private/dovecot-lmtp'
