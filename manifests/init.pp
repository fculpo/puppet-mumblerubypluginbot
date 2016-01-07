class mumble_ruby_bot(
  $username            = 'botmaster',
  $ruby_version        = '2.2.4',
  $celt_version        = '0.7.0',
  $celt_ruby_version   = '0.0.1',
  $mumble_ruby_version = '1.1.2',
  $opus_ruby_version   = '1.0.1',
) 
{  
  package { 'curl':               ensure => 'installed', }
  package { 'git':                ensure => 'installed', }
  package { 'libyaml-dev':		    ensure => 'installed', }
  package { 'libopus-dev':		    ensure => 'installed', }
  package { 'build-essential':		ensure => 'installed', }
  package { 'zlib1g':			        ensure => 'installed', }
  package { 'zlib1g-dev':		      ensure => 'installed', }
  package { 'libssl-dev':		      ensure => 'installed', }
  package { 'mpd':			          ensure => 'installed', }
  package { 'mpc':			          ensure => 'installed', }
  package { 'tmux':			          ensure => 'installed', }
  package { 'automake':			      ensure => 'installed', }
  package { 'autoconf':			      ensure => 'installed', }
  package { 'libtool'	:		        ensure => 'installed', }
  package { 'libogg-dev':		      ensure => 'installed', }
  package { 'psmisc':			        ensure => 'installed', }
  package { 'util-linux':		      ensure => 'installed', }
  package { 'dialog':			        ensure => 'installed', }
  package { 'unzip':			        ensure => 'installed', }
  package { 'imagemagick':		    ensure => 'installed', }
  package { 'libav-tools':		    ensure => 'installed', }
  package { 'python':			        ensure => 'installed', }

  service { 'mpd':
    ensure  => stopped,
    enable  => false,
    require => Package['mpd'],
  }

  file { '/usr/bin/ffmpeg':
    ensure => symlink,
    target => '/usr/bin/avconv',
  }

  Exec { 
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/rvm/bin', "/home/$username/src/celt-$celt_version"  ],
  }

  class { '::rvm': }
  rvm::system_user { $username:
    require => User[$username]
  }

  rvm_system_ruby {
    "ruby-$ruby_version":
      ensure	    => 'present',
      default_use => true;
  }

  rvm_gemset { "ruby-$ruby_version@bots":
      ensure  => present,
      require => Rvm_system_ruby["ruby-$ruby_version"];
  }

  user { $username:
    ensure           => 'present',
    home             => "/home/$username",
    password         => '!!',
    managehome	     => true,    
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    uid              => '1001',
  }->
  file { [ "/home/$username/src", "/home/$username/src/certs", "/home/$username/music", "/home/$username/temp", "/home/$username/mpd1", "/home/$username/mpd1/playlists" ] :
    ensure => 'directory',
    owner  => $username,
    group  => $username,
    mode   => '0755', 
  }   
  
  vcsrepo { 'mumble-ruby':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/mumble-ruby",
    user     => $username,
    source   => 'https://github.com/dafoxia/mumble-ruby.git',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'opus-ruby':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/opus-ruby",
    user     => $username,
    revision => 'master',
    source   => 'https://github.com/dafoxia/opus-ruby.git',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'mumble-ruby-related':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/mumble-ruby-related",
    user     => $username,
    revision => 'master',
    source   => 'https://github.com/Natenom/mumble-ruby-related.git',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'mumble-ruby-pluginbot':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/mumble-ruby-pluginbot",
    user     => $username,
    source   => 'https://github.com/Natenom/mumble-ruby-pluginbot.git',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'celt-ruby':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/celt-ruby",
    user     => $username,
    source   => 'https://github.com/dafoxia/celt-ruby.git',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'celt':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/celt-$celt_version",
    user     => $username,
    source   => "https://github.com/mumble-voip/celt-$celt_version.git",
    require  => File["/home/$username/src"],
  }

  exec { 'compile_celt':
    command => "./autogen.sh && ./configure --prefix=/home/$username/src/celt && make && make install",
    cwd     => "/home/$username/src/celt-$celt_version",
    require => Vcsrepo['celt'],
    creates => '/home/botmaster/src/celt/bin/celtdec',
  }

  exec { 'build_celtruby_gem':
    command   => "rvm $ruby_version@bots do gem build celt-ruby.gemspec",
    cwd       => '/home/botmaster/src/celt-ruby',
    user      => $username,
    creates   => "/home/$username/src/celt-ruby/celt-ruby-$celt_ruby_version.gem",
    require   => [ Vcsrepo['celt-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'celt-ruby':
    ruby_version  => "ruby-$ruby_version@bots",
    source 	      => "/home/$username/src/celt-ruby/celt-ruby-$celt_ruby_version.gem",
    name	        => 'celt-ruby',
    ensure 	      => 'present',
    require	      => Exec['build_celtruby_gem'],
  }

  exec { 'build_mumbleruby_gem':
    command   => "rvm $ruby_version@bots do gem build mumble-ruby.gemspec",
    cwd       => "/home/$username/src/mumble-ruby",
    user      => $username,
    creates   => "/home/$username/src/mumble-ruby/mumble-ruby-$mumble_ruby_version.gem",
    require   => [ Vcsrepo['mumble-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'mumble-ruby':
    ruby_version  => "ruby-$ruby_version@bots",
    source 	      => "/home/$username/src/mumble-ruby/mumble-ruby-$mumble_ruby_version.gem",
    name	        => 'mumble-ruby',
    ensure 	      => 'present',
    require	      => Exec['build_mumbleruby_gem'],
  }

  exec { 'build_opusruby_gem':
    command   => "rvm $ruby_version@bots do gem build opus-ruby.gemspec",
    cwd       => "/home/$username/src/opus-ruby",
    user      => $username,
    creates   => "/home/$username/src/opus-ruby/opus-ruby-$opus_ruby_version.gem",
    require   => [ Vcsrepo['opus-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'opus-ruby':
    ruby_version => "ruby-$ruby_version@bots",
    source 	     => "/home/$username/src/opus-ruby/opus-ruby-$opus_ruby_version.gem",
    name	       => 'opus-ruby',
    ensure 	     => 'present',
    require	     => Exec['build_opusruby_gem'],
  }

  rvm_gem { "ruby-$ruby_version@bots/ruby-mpd": }
  rvm_gem { "ruby-$ruby_version@bots/crack": }

  file { "/home/$username/mpd1/mpd.conf":
    ensure => symlink,
    target => "/home/$username/src/mumble-ruby-related/configs/mpd.conf",
  } 

  file { [ "/home/$username/src/mumble-ruby-pluginbot/scripts/start.sh", "/home/$username/src/mumble-ruby-pluginbot/scripts/updater.sh" ]:
    mode    => '0755',
    require => Vcsrepo['mumble-ruby-pluginbot']
  }

  exec { 'youtube-dl':
    command => "wget https://yt-dl.org/downloads/latest/youtube-dl -O /home/$username/src/youtube-dl && chmod u+x /home/$username/src/youtube-dl && /home/$username/src/youtube-dl -U",
    user    => $username,
    creates => "/home/$username/src/youtube-dl",
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
