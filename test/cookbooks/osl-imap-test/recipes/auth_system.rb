include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'default' do
  auth_type :system
  wildcard_cert true
end

user 'foo' do
  password '$1$B7Bo6eja$C5aj4AIKxw437TcwiTWnR1' # "bar"
  home '/home/foo'
  manage_home true
end

include_recipe 'osl-imap-test::send_test_email'
