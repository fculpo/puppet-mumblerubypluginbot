class mumble_ruby_bot::dependencies {

  $username     = $::mumble_ruby_bot::username
  $celt_version = $::mumble_ruby_bot::celt_version


  $dependencies = [
    'curl', 'git', 'libyaml-dev', 'libopus-dev', 'build-essential', 'zlib1g', 
    'zlib1g-dev', 'libssl-dev', 'mpd', 'mpc', 'tmux', 'automake', 'autoconf',
    'libtool', 'libogg-dev', 'psmisc', 'util-linux', 'dialog', 'unzip',
    'imagemagick', 'libav-tools', 'python'
  ]

  package { $dependencies: ensure => 'installed' }

  service { 'mpd':
    ensure  => stopped,
    enable  => false,
    require => Package['mpd'],
  }

  file { '/usr/bin/ffmpeg':
    ensure => symlink,
    target => '/usr/bin/avconv',
  }

  class { '::rvm': }

}