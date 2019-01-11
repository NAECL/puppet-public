Facter.add("custom_resource_group") do
  setcode do
    if File.exist? '/etc/build_custom_config'
      open('/etc/build_custom_config').grep(/^RESOURCE_GROUP=/)[0].split('=')[1].chomp.upcase
    end
  end
end
