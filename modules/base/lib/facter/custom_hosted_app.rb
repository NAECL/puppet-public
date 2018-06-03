Facter.add("custom_hosted_app") do
  setcode do
    hosted_app = 'undef'
    if ( File.exist? '/etc/build_custom_config' )
      value = open('/etc/build_custom_config').grep(/^HOSTED_APP=/)[0]
      if ( ! value.to_s.empty? )
        value = value.split('=')[1].chomp.downcase
        hosted_app = value
      end
    end
    hosted_app
  end
end
