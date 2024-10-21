require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALMA_9 = {
  platform: 'almalinux',
  version: '9',
}.freeze

ALL_PLATFORMS = [
  ALMA_8,
  ALMA_9,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

shared_context 'dovecot_stubs' do
  before do
    stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix')
  end
end
