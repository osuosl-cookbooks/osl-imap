#
# Cookbook:: osl-imap-test
# Recipe:: send_test_email
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

execute 'send-email' do
  command <<~EOC
    sendmail foo@foo.org <<< "Subject: IMAP Test Email for Foo
    This test email should be fetchable via IMAP.
    ."
  EOC
  creates '/tmp/test_email_sent'
  notifies :create, 'file[/tmp/test_email_sent]'
end

file '/tmp/test_email_sent' do
  action :nothing
end

execute 'fetchmail -ak && touch /tmp/fetchmail' do
  user 'foo'
  group 'foo'
  login true
  creates '/tmp/fetchmail'
end
