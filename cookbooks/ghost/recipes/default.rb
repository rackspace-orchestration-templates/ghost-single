### Setup NodeJS and NPM
node.set[:nodejs][:version] = "0.10.28"
node.set[:nodejs][:checksum] = "abddc6441e0f208f6ed8a045e0293f713ea7f6dfb2d6a9a2024bf8b1b4617710"
node.set[:nodejs][:checksum_linux_x86] = "81ee7f30c35e1743790fd9ca47235bdec4a6c9d2b89a70f33c69e80008cbf422"
node.set[:nodejs][:checksum_linux_x64] = "5f41f4a90861bddaea92addc5dfba5357de40962031c2281b1683277a0f75932"

include_recipe "nodejs::install_from_binary"

package 'unzip'

### Setup User and Install Directory
include_recipe "ghost::user"

extract_dir = "#{node[:ghost][:install_path]}/ghost"
ghost_path = "#{node[:ghost][:install_path]}/ghost/ghost-#{node[:ghost][:ghost_version]}.zip"
ghost_url = "#{node[:ghost][:src_url]}/ghost-#{node[:ghost][:ghost_version]}.zip"

### Create Ghost Site Directory
directory extract_dir do
  owner node[:ghost][:user]
  group node[:ghost][:user]
  mode "0755"
  recursive true
  action :create
end

### Download Ghost Zip File
remote_file ghost_path do
	source "#{ghost_url}"
	owner node[:ghost][:user]
end

### Unzip Ghost File Into Site Directory
bash "unzip_ghost" do
  cwd extract_dir
  code "unzip -q -u -o #{ghost_path} -d #{extract_dir}"
end

### Delete Ghost Zip File
file ghost_path do
  action :delete
end

### Install Dependencies
bash "install_ghost" do
  cwd extract_dir
  code "npm install --production"
end

bash "install_mysql_npm" do
  cwd extract_dir
  code "npm install mysql"
end

### Load Secrets from Databag
if node[:ghost][:databag]
  databag = Chef::EncryptedDataBagItem.load(node[:ghost][:databag], node[:ghost][:databag_item])
  node.set_unless[:ghost][:mail_password] = databag['ghost']['mail_password'] rescue nil
  node.set_unless[:ghost][:db_password] = databag[:ghost]['db_password'] rescue nil
end

### Create Config
template ::File.join(extract_dir, "config.js") do
  source "config.js.erb"
  owner node[:ghost][:user]
  group node[:ghost][:user]
  mode "0660"
  variables(
    :url		=> node[:ghost][:domain],
    :mail_transport     => node[:ghost][:mail_transport].downcase,
    :mail_user  	=> node[:ghost][:mail_user],
    :mail_password 	=> node[:ghost][:mail_password],
    :db_host		=> node[:ghost][:db_host],
    :db_user		=> node[:ghost][:db_user],
    :db_password	=> node[:ghost][:db_password],
    :db_name		=> node[:ghost][:db_name]
  )
end

### Install Themes
node[:ghost][:themes].each do |name,source_url|
  ghost_theme name do
    source source_url
  end
end

### Set File Ownership
bash "set_ownership" do
  cwd node[:ghost][:install_path]
  code "chown -R #{node[:ghost][:user]}:#{node[:ghost][:user]} #{node[:ghost][:install_path]}"
end

### Create Service
case node[:platform]
when "ubuntu"
  if node["platform_version"].to_f >= 9.10
    template "/etc/init/ghost.conf" do
      source "ghost.conf.erb"
      mode "0644"
      variables(
        :user		=> node[:ghost][:user],
        :dir		=> extract_dir
      )
    end
  end
end

service "ghost" do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [ :enable, :start ]
end
