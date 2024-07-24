require_relative '../../spec_helper'

describe 'osl-imap-test::lmtp' do
  include_context 'dovecot_stubs'

  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.dup.merge(
          step_into: %w(osl_imap_dovecot)
        )).converge(described_recipe)
      end

      include_context 'dovecot_stubs'

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to accept_osl_firewall_imaps_pop3s 'osl-imap' }
      it { is_expected.to install_package 'dovecot' }
      it { is_expected.to_not install_package 'dovecot-mysql' }
      it { is_expected.to_not include_recipe 'osl-apache' }

      it do
        is_expected.to create_certificate_manage('wildcard').with(
          cert_file: 'wildcard.pem',
          key_file: 'wildcard.key',
          chain_file: 'wildcard-bundle.crt',
          nginx_cert: true
        )
      end

      it { expect(chef_run.certificate_manage('wildcard')).to notify('service[dovecot]').to(:reload) }

      it do
        is_expected.to create_template('/etc/dovecot/dovecot.conf').with(
          cookbook: 'osl-imap',
          variables: {
            auth_mechanisms: 'plain login',
            auth_type: 'system',
            auth_username_format: '%n',
            extra_options: %w(auth_verbose=yes),
            mail_location: 'maildir:~/Maildir',
            mbox_write_locks: 'dotlock fcntl',
            protocols: 'imap pop3 lmtp',
            ssl_cert: '/etc/pki/tls/certs/wildcard.pem',
            ssl_key: '/etc/pki/tls/private/wildcard.key',
          }
        )
      end

      it do
        is_expected.to render_file('/etc/dovecot/dovecot.conf').with_content(
          <<~EOF
            # This file was generated by Chef Infra
            # Do NOT modify this file by hand.
            auth_mechanisms = plain login
            auth_username_format = %n
            mail_location = maildir:~/Maildir
            mbox_write_locks = dotlock fcntl

            # System Auth
            passdb {
              args = dovecot
              driver = pam
            }
            userdb {
              driver = passwd
            }

            protocols = imap pop3 lmtp
            service auth {
              unix_listener /var/spool/postfix/private/auth {
                group = postfix
                mode = 0660
                user = postfix
              }
            }
            service lmtp {
              unix_listener /var/spool/postfix/private/dovecot-lmtp {
                group = postfix
                mode = 0600
                user = postfix
              }
            }
            service imap-login {
              inet_listener imap {
                port = 0
              }
            }
            service pop3-login {
              inet_listener pop3 {
                port = 0
              }
            }
            ssl = required
            ssl_cert = </etc/pki/tls/certs/wildcard.pem
            ssl_cipher_list = ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:!DES-CBC3-SHA:!DSS
            ssl_key = </etc/pki/tls/private/wildcard.key
            ssl_options = no_compression no_ticket
            ssl_prefer_server_ciphers = yes
          EOF
        )
      end

      it { expect(chef_run.template('/etc/dovecot/dovecot.conf')).to notify('service[dovecot]').to(:reload) }
      it { is_expected.to_not create_template '/etc/dovecot/dovecot-sql.conf.ext' }
      it { is_expected.to_not create_template '/etc/dovecot/dovecot-ldap.conf.ext' }
      it { is_expected.to enable_service 'dovecot' }
      it { is_expected.to start_service 'dovecot' }
    end
  end
end
