control 'lmtp' do
  describe command 'doveconf -S' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match %r{service/lmtp/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sdovecot-lmtp/path=/var/spool/postfix/private/dovecot-lmtp} }
    its('stdout') { should match %r{service/lmtp/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sdovecot-lmtp/mode=0600} }
    its('stdout') { should match %r{service/lmtp/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sdovecot-lmtp/user=postfix} }
    its('stdout') { should match %r{service/lmtp/unix_listener/\\svar\\sspool\\spostfix\\sprivate\\sdovecot-lmtp/group=postfix} }
    its('stdout') { should match %r{userdb/0/auth_verbose=yes} }
  end

  describe file '/var/spool/postfix/private/dovecot-lmtp' do
    it { should be_socket }
    its('owner') { should eq 'postfix' }
    its('group') { should eq 'postfix' }
    its('mode') { should cmp 0600 }
  end

  describe command 'postconf local_transport virtual_transport' do
    its('stdout') { should match %r{^local_transport = lmtp:unix:private/dovecot-lmtp$} }
    its('stdout') { should match %r{^virtual_transport = lmtp:unix:private/dovecot-lmtp$} }
  end

  # Log in and fetch mail via IMAPS port
  describe command 'grep -r ^Subject: /tmp/Maildir' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Subject: IMAP Test Email for Foo/) }
  end
end
