#
# Cookbook:: .
# Recipe:: dovecot
#
# Copyright:: 2022, The Authors, All Rights Reserved.

dovecot 'dovecot' do
  action :create
end

#template '/etc/dovecot/dovecot.conf' do
#  source 'dovecot.conf.erb'
#end

#directory '/etc/dovecot/conf.d' do
#  recursive true
#  action :delete
#end
