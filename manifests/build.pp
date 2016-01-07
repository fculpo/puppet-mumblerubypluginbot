class mumble_ruby_bot::build {

  $username                  = $::mumble_ruby_bot::username
  $ruby_version              = $::mumble_ruby_bot::ruby_version
  $celt_version              = $::mumble_ruby_bot::celt_version
  $celt_rubygem_version      = $::mumble_ruby_bot::celt_rubygem_version
  $mumble_rubygem_version    = $::mumble_ruby_bot::mumble_rubygem_version
  $opus_rubygem_version      = $::mumble_ruby_bot::opus_rubygem_version

  user { $username:
    ensure           => present,
    home             => "/home/$username",
    password         => '!!',
    managehome       => true,    
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

  rvm::system_user { $username:
    require => User[$username]
  }

  rvm_system_ruby {
    "ruby-2.1.1":
      ensure      => present,
      default_use => false;
    "ruby-$ruby_version":
      ensure      => present,
      default_use => true;
  }

  rvm_gemset { "ruby-$ruby_version@bots":
      ensure  => present,
      require => Rvm_system_ruby["ruby-$ruby_version"]
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
    creates   => "/home/$username/src/celt-ruby/celt-ruby-$celt_rubygem_version.gem",
    require   => [ Vcsrepo['celt-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'celt-ruby':
    ruby_version  => "ruby-$ruby_version@bots",
    source        => "/home/$username/src/celt-ruby/celt-ruby-$celt_rubygem_version.gem",
    name          => 'celt-ruby',
    ensure        => 'present',
    require       => Exec['build_celtruby_gem'],
  }

  exec { 'build_mumbleruby_gem':
    command   => "rvm $ruby_version@bots do gem build mumble-ruby.gemspec",
    cwd       => "/home/$username/src/mumble-ruby",
    user      => $username,
    creates   => "/home/$username/src/mumble-ruby/mumble-ruby-$mumble_rubygem_version.gem",
    require   => [ Vcsrepo['mumble-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'mumble-ruby':
    ruby_version  => "ruby-$ruby_version@bots",
    source        => "/home/$username/src/mumble-ruby/mumble-ruby-$mumble_rubygem_version.gem",
    name          => 'mumble-ruby',
    ensure        => 'present',
    require       => Exec['build_mumbleruby_gem'],
  }

  exec { 'build_opusruby_gem':
    command   => "rvm $ruby_version@bots do gem build opus-ruby.gemspec",
    cwd       => "/home/$username/src/opus-ruby",
    user      => $username,
    creates   => "/home/$username/src/opus-ruby/opus-ruby-$opus_rubygem_version.gem",
    require   => [ Vcsrepo['opus-ruby'], Rvm_gemset["ruby-$ruby_version@bots"]],
  }

  rvm_gem { 'opus-ruby':
    ruby_version => "ruby-$ruby_version@bots",
    source       => "/home/$username/src/opus-ruby/opus-ruby-$opus_rubygem_version.gem",
    name         => 'opus-ruby',
    ensure       => 'present',
    require      => Exec['build_opusruby_gem'],
  }

  rvm_gem { "ruby-$ruby_version@bots/ruby-mpd": }
  rvm_gem { "ruby-$ruby_version@bots/crack": }

  exec { 'youtube-dl':
    command => "wget https://yt-dl.org/downloads/latest/youtube-dl -O /home/$username/src/youtube-dl && chmod u+x /home/$username/src/youtube-dl && /home/$username/src/youtube-dl -U",
    user    => $username,
    creates => "/home/$username/src/youtube-dl",
  }

}