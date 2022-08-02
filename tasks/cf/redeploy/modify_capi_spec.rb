#!/usr/bin/env ruby
# encoding: utf-8
# run as STACK=cflinuxfs4 ./add_lc_bundle.rb
# modified from https://github.com/cloudfoundry/buildpacks-ci/blob/be1f4156078576c8180cb3f625ea71a763f55371/tasks/create-capi-release-with-rootfs/run.rb
require 'yaml'
require 'fileutils'
require 'bundler/setup'
stack = ENV.fetch('STACK')

%w[cc_deployment_updater cloud_controller_clock cloud_controller_ng cloud_controller_worker].each do |job|
  puts "handling #{job}"
  specfile = "./capi-release/jobs/#{job}/spec"
  spec = YAML.safe_load(File.read(specfile))
  if spec['properties']['cc.diego.lifecycle_bundles']['default'].keys.grep(/#{stack}/).none?
    spec['properties']['cc.diego.lifecycle_bundles']['default']["buildpack/#{stack}"] = 'buildpack_app_lifecycle/buildpack_app_lifecycle.tgz'
  end
  File.write(specfile, YAML.dump(spec))
end
