class mumble_ruby_bot::config {
  
  $username                   = $::mumble_ruby_bot::username
  $mumbleserver_host          = $::mumble_ruby_bot::mumbleserver_host
  $mumbleserver_port          = $::mumble_ruby_bot::mumbleserver_port
  $mumbleserver_username      = $::mumble_ruby_bot::mumbleserver_username
  $mumbleserver_targetchannel = $::mumble_ruby_bot::mumbleserver_targetchannel
  $mumbleserver_userpassword  = $::mumble_ruby_bot::mumbleserver_userpassword
  $quality_bitrate            = $::mumble_ruby_bot::quality_bitrate

  file { "/home/$username/mpd1/mpd.conf":
    ensure  => file,
    content => template('mumble_ruby_bot/mpd.conf.erb'),
    owner   => $username,
    group   => $username,
  }

  file { "/home/$username/src/bot1_conf.rb":
    ensure  => file,
    content => template('mumble_ruby_bot/bot_conf.rb.erb'),
    owner   => $username,
    group   => $username,
  }

  file { [ "/home/$username/src/mumble-ruby-pluginbot/scripts/start.sh", "/home/$username/src/mumble-ruby-pluginbot/scripts/updater.sh" ]:
    mode    => '0755',
    require => Vcsrepo['mumble-ruby-pluginbot']
  }

  file { '/etc/systemd/system/mumblerubypluginbot.service':
    ensure  => file,
    content => template('mumble_ruby_bot/mumblerubypluginbot.service.erb'),
    require => Vcsrepo['mumble-ruby-pluginbot'],
  }

  file { "/home/$username/src/mumble-ruby-pluginbot/scripts/puppetstart.sh":
    ensure  => file,
    content => template('mumble_ruby_bot/start.sh.erb'),
    mode    => '0755',
    owner   => $username,
    group   => $username,
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