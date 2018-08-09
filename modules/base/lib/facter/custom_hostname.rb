Facter.add("custom_hostname") do
  setcode do
    hostname = 'undef'
    if ( File.exist? '/etc/build_custom_config' )
      value = open('/etc/build_custom_config').grep(/^HOSTNAME=/)[0]
      if ( ! value.to_s.empty? )
        value = value.split('=')[1].chomp.downcase
        if ( value.split('_')[0] == 'puppet' )
          hostname = value.split('_')[1]
        else
          hostname = value
        end
      end
    end
    hostname
  end
end
