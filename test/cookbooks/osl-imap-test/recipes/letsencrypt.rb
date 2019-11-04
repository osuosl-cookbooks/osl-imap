include_recipe 'osl-acme::server'
include_recipe 'osl-apache'
include_recipe 'apache2::mod_ssl'
include_recipe 'osl-acme'

cert_path = '/etc/pki/tls/imap.osuosl.org.crt'
key_path = '/etc/pki/tls/imap.osuosl.org.key'

apache_app 'imap.osuosl.org' do
  directory '/var/www/imap.osuosl.org'
  ssl_enable true
  cert_file cert_path
  cert_key key_path
end

acme_selfsigned 'imap.osuosl.org' do
  crt cert_path
  key key_path
  notifies :restart, 'service[apache2]', :immediately
end

acme_certificate 'imap.osuosl.org' do
  crt cert_path
  key key_path
  wwwroot '/var/www/imap.osuosl.org/'
  notifies :restart, 'service[apache2]'
end

node.default['dovecot']['conf']['ssl'] = 'required'
node.default['dovecot']['conf']['ssl_cert'] = '</etc/pki/tls/imap.osuosl.org.crt'
node.default['dovecot']['conf']['ssl_key']  = '</etc/pki/tls/imap.osuosl.org.key'
