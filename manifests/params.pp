class mumble_ruby_bot::params {

  $dependencies           = [
    'curl', 'git', 'libyaml-dev', 'libopus-dev', 'build-essential', 'zlib1g', 
    'zlib1g-dev', 'libssl-dev', 'mpd', 'mpc', 'tmux', 'automake', 'autoconf',
    'libtool', 'libogg-dev', 'psmisc', 'util-linux', 'dialog', 'unzip',
    'imagemagick', 'libav-tools', 'python'
  ]

	$username               = 'botmaster'
  $ruby_version           = '2.3.0'
  $celt_version           = '0.7.0'
  $celt_rubygem_version   = '0.0.1'
  $mumble_rubygem_version = '1.1.2'
  $opus_rubygem_version   = '1.0.1'

  $quality_bitrate        = 72000

}