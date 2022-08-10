# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
provides :dovecot
unified_mode true

default_action :create

action :create do
  package 'dovecot'

  service 'dovecot' do
    action [:enable, :start]
  end
end
