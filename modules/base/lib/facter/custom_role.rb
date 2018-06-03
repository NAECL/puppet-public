Facter.add("custom_role") do
  setcode do
    role = 'undef'
    if ( File.exist? '/etc/build_custom_config' )
      value = open('/etc/build_custom_config').grep(/^ROLE=/)[0]
      if ( ! value.to_s.empty? )
        value = value.split('=')[1].chomp.downcase
        if ( value.split('_')[0] == 'puppet' )
          role = value.split('_')[1]
        else
          role = value
        end
      end
    end
    role
  end
end
