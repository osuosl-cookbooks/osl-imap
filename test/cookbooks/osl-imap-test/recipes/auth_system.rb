include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'default' do
  auth_type :system
  wildcard_cert true
  extra_options %w(auth_verbose=yes)
end

include_recipe 'osl-imap-test::user_foo'
include_recipe 'osl-imap-test::send_test_email'
