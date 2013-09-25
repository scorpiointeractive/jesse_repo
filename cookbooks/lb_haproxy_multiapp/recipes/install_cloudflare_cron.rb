#
# Cookbook Name:: lb_haproxy_multiapp
#

rightscale_marker

# Installs script that switches cloudflare dns
template "/etc/haproxy/switch_cloudflare.sh" do
  owner "haproxy"
  group "haproxy"
  mode "0755"
  cookbook "lb_haproxy_multiapp"
  source "switch_cloudflare.erb"
  variables(
    :cloudflare_key => node[:scorpio_defaults][:cloudflare_key],
    :cloudflare_user => node[:scorpio_defaults][:cloudflare_user],
    :cloudflare_host => node[:scorpio_defaults][:cloudflare_host],
    :cloudflare_rec_ids => node[:scorpio_defaults][:cloudflare_rec_ids],
    :cloudflare_rec_name => node[:scorpio_defaults][:cloudflare_rec_name],
    :rs_email => node[:scorpio_defaults][:rs_email],
    :rs_pswd => node[:scorpio_defaults][:rs_pswd],
    :rs_id => node[:scorpio_defaults][:rs_id],
    :tag_search => node[:scorpio_defaults][:tag_search],
    :site_name => node[:scorpio_defaults][:site_name],
    :chk_url => node[:scorpio_defaults][:chk_url]
  )
end

# install cron task
cron "switch_cloudflare" do
  command "/etc/haproxy/switch_cloudflare.sh > /dev/null 2>&1"
end
