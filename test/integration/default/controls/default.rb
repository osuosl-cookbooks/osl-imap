wildcard = input('wildcard')
lmtp = input('lmtp')
auth_username_format = input('auth_username_format')

require_controls 'osuosl-baseline' do
  control 'ssl-baseline'
end

control 'default' do
  describe package 'dovecot' do
    it { should be_installed }
  end

  describe service 'dovecot' do
    it { should be_enabled }
    it { should be_running }
  end

  %w(993 995).each do |p|
    describe port p do
      it { should be_listening }
    end
  end

  %w(110 143).each do |num|
    describe port num do
      it { should_not be_listening }
    end
  end

  describe command 'doveconf -S' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/^auth_mechanisms=plain login$/) }
    its('stdout') { should match(/^auth_username_format=#{auth_username_format}$/) }
    its('stdout') { should match(%r{mail_location=maildir:~/Maildir}) }
    its('stdout') { should match(/^mbox_write_locks=dotlock fcntl$/) }
    if lmtp
      its('stdout') { should match(/^protocols=imap pop3 lmtp$/) }
    else
      its('stdout') { should match(/^protocols=imap pop3$/) }
    end
    its('stdout') { should match %r{service/auth/unix_listener=login\\slogin token-login\\stokenlogin auth-login auth-client auth-userdb auth-master \\svar\\sspool\\spostfix\\sprivate\\sauth} }
    its('stdout') { should match %r{service/auth/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sauth/mode=0660} }
    its('stdout') { should match %r{service/auth/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sauth/user=postfix} }
    its('stdout') { should match %r{service/auth/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sauth/group=postfix} }
    its('stdout') { should match(%r{service/imap-login/inet_listener/imap/port=0$}) }
    its('stdout') { should match(%r{service/pop3-login/inet_listener/pop3/port=0$}) }
    its('stdout') { should match(/^ssl=required$/) }
    its('stdout') { should match(/^ssl_cipher_list=ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:!DES-CBC3-SHA:!DSS$/) }
    its('stdout') { should match(/^ssl_options=no_compression no_ticket$/) }
    its('stdout') { should match(/^ssl_prefer_server_ciphers=yes$/) }
    if wildcard
      its('stdout') { should match %r{^ssl_cert=</etc/pki/tls/certs/wildcard\.pem$} }
      its('stdout') { should match %r{^ssl_key=</etc/pki/tls/private/wildcard\.key$} }
    end
  end

  describe file '/var/spool/postfix/private/auth' do
    it { should be_socket }
    its('mode') { should cmp '0660' }
    its('owner') { should eq 'postfix' }
    its('group') { should eq 'postfix' }
  end

  %w(
    /etc/pki/tls/certs/wildcard.pem
    /etc/pki/tls/private/wildcard.key
  ).each do |f|
    describe file f do
      it { should exist }
    end
  end if wildcard
end
