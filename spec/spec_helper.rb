require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_7 = {
  platform: 'centos',
  version: '7',
}.freeze

CENTOS_8 = {
  platform: 'centos',
  version: '8',
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
  CENTOS_8,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
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
