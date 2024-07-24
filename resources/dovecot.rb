resource_name :osl_imap_dovecot
provides :osl_imap_dovecot
default_action :create
unified_mode true

property :auth_mechanisms, String, default: 'plain login'
property :auth_type, Symbol, equal_to: [:system, :mysql, :ldap], required: true
property :auth_username_format, String, default: '%n'
property :db_host, String, sensitive: true
property :db_name, String, sensitive: true
property :db_pass, String, sensitive: true
property :db_user, String, sensitive: true
property :default_pass_scheme, String, default: 'SHA512-CRYPT'
property :extra_ldap_options, Array, default: []
property :extra_options, Array, default: []
property :iterate_query, String
property :ldap_base, String
property :ldap_uris, String
property :letsencrypt, [true, false], default: false
property :mail_location, String, default: 'maildir:~/Maildir'
property :mbox_write_locks, String, default: 'dotlock fcntl'
property :password_query, String
property :protocols, String, default: 'imap pop3'
property :ssl_cert, String
property :ssl_key, String
property :user_query, String
property :wildcard_cert, [true, false], default: false

action :create do
  if new_resource.letsencrypt
    ssl_cert = "/etc/pki/tls/#{new_resource.name}.crt"
    ssl_key = "/etc/pki/tls/#{new_resource.name}.key"
  elsif new_resource.wildcard_cert
    ssl_cert = '/etc/pki/tls/certs/wildcard.pem'
    ssl_key = '/etc/pki/tls/private/wildcard.key'
  else
    ssl_cert = new_resource.ssl_cert
    ssl_key = new_resource.ssl_key
  end

  osl_firewall_imaps_pop3s 'osl-imap'

  package 'dovecot'
  package 'dovecot-mysql' if new_resource.auth_type == :mysql

  certificate_manage 'wildcard' do
    cert_file 'wildcard.pem'
    key_file 'wildcard.key'
    chain_file 'wildcard-bundle.crt'
    nginx_cert true
    notifies :reload, 'service[dovecot]'
  end if new_resource.wildcard_cert

  if new_resource.letsencrypt
    include_recipe 'osl-apache'
    include_recipe 'osl-apache::mod_ssl'
    include_recipe 'osl-acme'

    acme_selfsigned new_resource.name do
      crt ssl_cert
      key ssl_key
      notifies :restart, 'apache2_service[osuosl]', :immediately
    end

    apache_app new_resource.name do
      directory "/var/www/#{new_resource.name}"
      ssl_enable true
      cert_file ssl_cert
      cert_key ssl_key
    end

    acme_certificate new_resource.name do
      crt ssl_cert
      key ssl_key
      wwwroot "/var/www/#{new_resource.name}/"
      notifies :restart, 'apache2_service[osuosl]'
    end
  end

  template '/etc/dovecot/dovecot.conf' do
    cookbook 'osl-imap'
    variables(
      auth_mechanisms: new_resource.auth_mechanisms,
      auth_type: new_resource.auth_type.to_s,
      auth_username_format: new_resource.auth_username_format,
      extra_options: new_resource.extra_options,
      mail_location: new_resource.mail_location,
      mbox_write_locks: new_resource.mbox_write_locks,
      protocols: new_resource.protocols,
      ssl_cert: ssl_cert,
      ssl_key: ssl_key
    )
    notifies :reload, 'service[dovecot]'
  end

  template '/etc/dovecot/dovecot-sql.conf.ext' do
    cookbook 'osl-imap'
    mode '0640'
    group 'dovecot'
    sensitive true
    variables(
      auth_type: new_resource.auth_type.to_s,
      db_host: new_resource.db_host,
      db_name: new_resource.db_name,
      db_pass: new_resource.db_pass,
      db_user: new_resource.db_user,
      default_pass_scheme: new_resource.default_pass_scheme,
      iterate_query: new_resource.iterate_query,
      password_query: new_resource.password_query,
      user_query: new_resource.user_query
    )
    notifies :reload, 'service[dovecot]'
  end if new_resource.auth_type == :mysql

  template '/etc/dovecot/dovecot-ldap.conf.ext' do
    cookbook 'osl-imap'
    mode '0640'
    group 'dovecot'
    sensitive true
    variables(
      auth_type: new_resource.auth_type.to_s,
      extra_options: new_resource.extra_ldap_options,
      ldap_base: new_resource.ldap_base,
      ldap_uris: new_resource.ldap_uris
    )
    notifies :reload, 'service[dovecot]'
  end if new_resource.auth_type == :ldap

  service 'dovecot' do
    action [:enable, :start]
  end
end

action :reload do
  service 'dovecot' do
    action :reload
  end
end
