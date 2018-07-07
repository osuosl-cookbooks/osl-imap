require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-imap' }

CENTOS_7 = {
  platform: 'centos',
  version: '7.2.1511',
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end

shared_context 'dovecot_stubs' do
  before do
    stub_data_bag_item(nil, nil).and_return(
      id: 'test_item',
      host: 'sql.foo.bar',
      db: 'dovecot_db',
      type: 'mysql',
      user: 'dovecot',
      pass: 'test password'
    )
  end
end
