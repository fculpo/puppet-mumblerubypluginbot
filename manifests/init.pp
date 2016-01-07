class mumble_ruby_bot(
  $username                  = $::mumble_ruby_bot::params::username,
  $ruby_version              = $::mumble_ruby_bot::params::ruby_version,
  $celt_version              = $::mumble_ruby_bot::params::celt_version,
  $celt_rubygem_version      = $::mumble_ruby_bot::params::celt_rubygem_version,
  $mumble_rubygem_version    = $::mumble_ruby_bot::params::mumble_rubygem_version,
  $opus_rubygem_version      = $::mumble_ruby_bot::params::opus_rubygem_version,
  $quality_bitrate           = $::mumble_ruby_bot::params::quality_bitrate,
) inherits ::mumble_ruby_bot::params

{  
  include mumble_ruby_bot::dependencies
  include mumble_ruby_bot::repos
  include mumble_ruby_bot::build
  include mumble_ruby_bot::config

}
