control 'auth_system' do
  describe command 'doveconf -S userdb passdb auth_verbose' do
    its('stdout') { should match %r{^passdb/0/driver=pam$} }
    its('stdout') { should match %r{^passdb/0/args=dovecot$} }
    its('stdout') { should match %r{^userdb/0/driver=passwd$} }
    its('stdout') { should match /^auth_verbose=yes$/ }
    its('exit_status') { should eq 0 }
  end

  # Log in and fetch mail via IMAPS port
  describe command 'grep -r ^Subject: /tmp/Maildir' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Subject: IMAP Test Email for Foo/) }
  end
end
