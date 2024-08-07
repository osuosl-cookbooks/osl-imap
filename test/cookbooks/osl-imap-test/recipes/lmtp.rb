# Use LMTP for both local and virtual deliveries
node.default['postfix']['main']['local_transport']   = 'lmtp:unix:private/dovecot-lmtp'
node.default['postfix']['main']['virtual_transport'] = 'lmtp:unix:private/dovecot-lmtp'

include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'lmtp' do
  auth_type :system
  protocols 'imap pop3 lmtp'
  wildcard_cert true
  userdb [
    'driver = passwd',
    'auth_verbose = yes',
  ]
  extra_options %w(auth_verbose=yes)
end

include_recipe 'osl-imap-test::user_foo'
include_recipe 'osl-imap-test::send_test_email'
