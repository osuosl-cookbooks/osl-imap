include_recipe 'osl-acme::server'
include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'imap.osuosl.org' do
  auth_type :system
  letsencrypt true
  extra_options %w(auth_verbose=yes)
end

include_recipe 'osl-imap-test::user_foo'
include_recipe 'osl-imap-test::send_test_email'
