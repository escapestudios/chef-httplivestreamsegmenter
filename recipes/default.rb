#
# Cookbook Name:: chef-httplivestreamsegmenter
# Recipe:: default
#
# Copyright 2012, Escape Studios
#

include_recipe "build-essential"
include_recipe "git"

git "#{Chef::Config[:file_cache_path]}/http-live-stream-segmenter" do
  repository node[:httplivestreamsegmenter][:git_repository]
  reference node[:httplivestreamsegmenter][:git_revision]
  action :sync
  notifies :run, "bash[compile_httplivestreamsegmenter]"
end

# Write the flags used to compile the application to Disk. If the flags
# do not match those that are in the compiled_flags attribute - we recompile
template "#{Chef::Config[:file_cache_path]}/httplivestreamsegmenter-compiled_with_flags" do
	source "compiled_with_flags.erb"
	owner "root"
	group "root"
	mode 0600
	variables(
		:compile_flags => node[:httplivestreamsegmenter][:compile_flags]
	)
	notifies :run, "bash[compile_httplivestreamsegmenter]"
end

bash "make_httplivestreamsegmenter" do
	cwd "#{Chef::Config[:file_cache_path]}/httplivestreamsegmenter"
	code <<-EOH
		./configure --prefix=#{node[:httplivestreamsegmenter][:prefix]} #{node[:httplivestreamsegmenter][:compile_flags].join(' ')}
		make clean && make && make install
	EOH
end