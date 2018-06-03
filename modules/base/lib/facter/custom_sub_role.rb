Facter.add("custom_sub_role") do
  setcode do
    sub_role = 'undef'
    if ( File.exist? '/etc/build_custom_config' )
      value = open('/etc/build_custom_config').grep(/^SUB_ROLE=/)[0]
      if ( ! value.to_s.empty? )
        value = value.split('=')[1].chomp.downcase
        sub_role = value
      end
    end
    sub_role
  end
end
