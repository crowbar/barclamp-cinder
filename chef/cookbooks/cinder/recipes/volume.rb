#
# Copyright 2012 Dell, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Cookbook Name:: cinder
# Recipe:: volume
#

include_recipe "#{@cookbook_name}::common"

def volume_exists(volname)
  Kernel.system("vgs #{volname}")
end

def make_eqlx_volumes(node)
  Chef::Log.info("Cinder: Using eqlx volumes.")
  package("python-paramiko")
  #TODO(agordeev): use path_spec not hardcode
  if node[:cinder][:use_gitrepo]
    eqlx_path = "/opt/cinder/cinder/volume/eqlx.py"
  else
    eqlx_path = "/usr/lib/python2.7/dist-packages/cinder/volume/eqlx.py"
  end
  cookbook_file eqlx_path do
    mode "0755"
    source "eqlx.py"
  end
end

def make_loopback_volume(node,volname)
  return if volume_exists(volname)
  Chef::Log.info("Cinder: Using local file volume backing")
  node[:cinder][:volume][:volume_type] = "local"
  fname = node["cinder"]["volume"]["local_file"]
  fdir = ::File.dirname(fname)
  fsize = node["cinder"]["volume"]["local_size"] * 1024 * 1024 * 1024 # Convert from GB to Bytes
  # this code will be executed at compile-time so we have to use ruby block
  # or get fs capacity from parent directory because at compile-time we have
  # no package resources done
  # creating enclosing directory and user/group here bypassing packages looks like
  # a bad idea. I'm not sure about postinstall behavior of cinder package.
  # Cap size at 90% of free space
  encl_dir=fdir
  while not File.directory?(encl_dir)
    encl_dir=encl_dir.sub(/\/[^\/]*$/,'')
  end
  max_fsize = ((`df -Pk #{encl_dir}`.split("\n")[1].split(" ")[3].to_i * 1024) * 0.90).to_i rescue 0
  fsize = max_fsize if fsize > max_fsize

  bash "create local volume file" do
    code "truncate -s #{fsize} #{fname}"
    not_if do
      File.exists?(fname)
    end
  end

  bash "setup loop device for volume" do
    code "losetup -f --show #{fname}"
    not_if "losetup -j #{fname} | grep #{fname}"
  end

  bash "create volume group" do
    code "vgcreate #{volname} `losetup -j #{fname} | cut -f1 -d:`"
    not_if "vgs #{volname}"
  end
end

def make_volume(node,volname,unclaimed_disks,claimed_disks)
  return if volume_exists(volname)
  Chef::Log.info("Cinder: Using raw disks for volume backing.")
  if claimed_disks.empty?
    claimed_disks = if node[:cinder][:volume][:cinder_raw_method] == "first"
                      [unclaimed_disks.first]
                    else
                      unclaimed_disks
                    end.select do |d|
      if d.claim("Cinder")
        Chef::Log.info("Cinder: Claimed #{d.name}")
        true
      else
        Chef::Log.info("Cinder: Ignoring #{d.name}")
        false
      end
    end
  end
  claimed_disks.each do |disk|
    bash "Create physical volume on #{disk.name}" do
      code "pvcreate -f #{disk.name}"
      not_if "pvs #{disk.name}"
    end
  end
  # Make our volume group.
  bash "Create volume group #{volname}" do
    code "vgcreate #{volname} #{claimed_disks.map{|d|d.name}.join(' ')}"
    not_if "vgs #{volname}"
  end
end

volname = node[:cinder][:volume][:volume_name]
unclaimed_disks = BarclampLibrary::Barclamp::Inventory::Disk.unclaimed(node)
claimed_disks = BarclampLibrary::Barclamp::Inventory::Disk.claimed(node,"Cinder")

case
when node[:cinder][:volume][:volume_type] == "eqlx"
  make_eqlx_volumes(node)
when (node[:cinder][:volume][:volume_type] == "local") ||
    (unclaimed_disks.empty? && claimed_disks.empty?)
  make_loopback_volume(node,volname)
when node[:cinder][:volume][:volume_type] == "raw"
  make_volume(node,volname,unclaimed_disks,claimed_disks)
end

package "tgt"
if node[:cinder][:use_gitrepo]
  #TODO(agordeev):
  # tgt will not work with iSCSI targets if it has the same configs in conf.d
  # e.g. cinder_tgt.conf (which comes from packages) and cinder-volume.conf
  # with the same data such as 'include /var/lib/cinder/volumes/*'
  cookbook_file "/etc/tgt/conf.d/cinder-volume.conf" do
    source "cinder-volume.conf"
  end
end

cinder_service("volume")

# Restart doesn't work correct for this service.
bash "restart-tgt_#{@cookbook_name}" do
  code <<-EOH
    stop tgt
    start tgt
EOH
  action :nothing
end

service "tgt" do
  supports :status => true, :restart => true, :reload => true
  action :enable
  notifies :run, "bash[restart-tgt_#{@cookbook_name}]"
end
