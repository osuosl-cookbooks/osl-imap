# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
provides :dovecot
unified_mode true

default_action :create

action :create do
  package 'dovecot'

  template '/etc/dovecot/dovecot.conf' do
    source 'dovecot.conf.erb'
  end

  directory '/etc/dovecot/conf.d' do
    recursive true
    action :delete
  end

  service 'dovecot' do
    action [:enable, :start]
  end
end
