class mumble_ruby_bot::config {
  
  $username                  = $::mumble_ruby_bot::username
  $ruby_version              = $::mumble_ruby_bot::ruby_version
  $celt_version              = $::mumble_ruby_bot::celt_version
  $celt_rubygem_version      = $::mumble_ruby_bot::celt_rubygem_version
  $mumble_rubygem_version    = $::mumble_ruby_bot::mumble_rubygem_version
  $opus_rubygem_version      = $::mumble_ruby_bot::opus_rubygem_version

  file { "/home/$username/mpd1/mpd.conf":
    ensure  => file,
    content => template('mumble_ruby_bot/mpd.conf.erb'),
  }

  file { "/home/$username/src/bot1_conf.rb":
    ensure  => file,
    content => template('mumble_ruby_bot/bot_conf.rb.erb'),
  }

  file { [ "/home/$username/src/mumble-ruby-pluginbot/scripts/start.sh", "/home/$username/src/mumble-ruby-pluginbot/scripts/updater.sh" ]:
    mode    => '0755',
    require => Vcsrepo['mumble-ruby-pluginbot']
  }

  file { '/etc/systemd/system/mumblerubypluginbot.service':
    ensure  => symlink,
    target  => "/home/$username/src/mumble-ruby-pluginbot/scripts/mumblerubypluginbot.service",
    require => Vcsrepo['mumble-ruby-pluginbot'],
  }

  file { [ "/home/$username/.rvm", '/root/.rvm' ]:
    ensure  => symlink,
    target  => '/usr/local/rvm',
    require => User[$username],
  }

  service { 'mumblerubypluginbot':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/mumblerubypluginbot.service'],
  }    
}