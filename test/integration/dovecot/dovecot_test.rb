# Chef InSpec test for recipe .::dovecot

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe service('dovecot') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
