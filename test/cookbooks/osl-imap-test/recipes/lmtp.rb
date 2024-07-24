# Use LMTP for both local and virtual deliveries
node.default['postfix']['main']['local_transport']   = 'lmtp:unix:private/dovecot-lmtp'
node.default['postfix']['main']['virtual_transport'] = 'lmtp:unix:private/dovecot-lmtp'

include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'lmtp' do
  auth_type :system
  protocols 'imap pop3 lmtp'
  wildcard_cert true
end

user 'foo' do
  password '$1$B7Bo6eja$C5aj4AIKxw437TcwiTWnR1' # "bar"
  home '/home/foo'
  manage_home true
end

include_recipe 'osl-imap-test::send_test_email'
