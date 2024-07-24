user 'foo' do
  password '$1$B7Bo6eja$C5aj4AIKxw437TcwiTWnR1' # "bar"
  home '/home/foo'
  manage_home true
end

cookbook_file '/home/foo/.procmailrc' do
  owner 'foo'
  group 'foo'
  source 'procmailrc'
end

cookbook_file '/home/foo/.fetchmailrc' do
  owner 'foo'
  group 'foo'
  mode '0700'
  source 'fetchmailrc'
end

directory '/tmp/Maildir' do
  owner 'foo'
  group 'foo'
end
