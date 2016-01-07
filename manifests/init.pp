class mumble_ruby_bot(
  $username                   = $::mumble_ruby_bot::params::username,
  $ruby_version               = $::mumble_ruby_bot::params::ruby_version,
  $celt_version               = $::mumble_ruby_bot::params::celt_version,
  $celt_rubygem_version       = $::mumble_ruby_bot::params::celt_rubygem_version,
  $mumble_rubygem_version     = $::mumble_ruby_bot::params::mumble_rubygem_version,
  $opus_rubygem_version       = $::mumble_ruby_bot::params::opus_rubygem_version,
  $quality_bitrate            = $::mumble_ruby_bot::params::quality_bitrate,
  $mumbleserver_host          = $::mumble_ruby_bot::params::mumbleserver_host,
  $mumbleserver_port          = $::mumble_ruby_bot::params::mumbleserver_port,
  $mumbleserver_username      = $::mumble_ruby_bot::params::mumbleserver_username,
  $mumbleserver_targetchannel = $::mumble_ruby_bot::params::mumbleserver_targetchannel,
  $mumbleserver_userpassword  = $::mumble_ruby_bot::params::mumbleserver_userpassword
) inherits ::mumble_ruby_bot::params

{
  
  Exec { 
    path => [ '/usr/local/sbin', '/usr/local/bin', '/usr/sbin/', '/usr/bin', '/sbin', '/bin', '/usr/local/rvm/bin', "/home/$username/src/celt-$celt_version" ],
  }

  include mumble_ruby_bot::dependencies
  include mumble_ruby_bot::repos
  include mumble_ruby_bot::build
  include mumble_ruby_bot::config

}
