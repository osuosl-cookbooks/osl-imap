include_recipe 'osl-imap-test::default'

db = data_bag_item('sql_creds', 'mysql')

osl_mysql_test db['db'] do
  username db['user']
  password db['pass']
  server_password 'password'
end

cookbook_file '/tmp/dovecot.sql' do
  source 'dovecot.sql'
  sensitive true # just to hide massive wall of text
end

execute 'import sql dump' do
  command 'mysql -u dovecot_user -pdovecot_pass dovecot < /tmp/dovecot.sql && touch /root/.dovecot-imported'
  creates '/root/.dovecot-imported'
end

user 'foo' do
  uid 1234
  home '/home/foo'
  manage_home true
end

osl_imap_dovecot 'sql' do
  auth_type :mysql
  auth_username_format '%Lu'
  wildcard_cert true
  db_host db['host']
  db_user db['user']
  db_pass db['pass']
  db_name db['db']
  iterate_query 'SELECT username, domain FROM users'
  password_query "SELECT username, domain, password FROM users WHERE username = '%n' AND domain = '%d'"
  user_query "SELECT home, uid, gid FROM users WHERE username = '%n' AND domain = '%d'"
end

include_recipe 'osl-imap-test::send_test_email'
