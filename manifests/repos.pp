class mumble_ruby_bot::repos {

  $celt_version = $::mumble_ruby_bot::celt_version

  vcsrepo { 'mumble-ruby':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/mumble-ruby",
    user     => $username,
    source   => 'https://github.com/dafoxia/mumble-ruby.git',
    revision => 'master',
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
    revision => 'master',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'celt-ruby':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/celt-ruby",
    user     => $username,
    source   => 'https://github.com/dafoxia/celt-ruby.git',
    revision => 'master',
    require  => File["/home/$username/src"],
  }

  vcsrepo { 'celt':
    ensure   => latest,
    provider => git,
    path     => "/home/$username/src/celt-$celt_version",
    user     => $username,
    source   => "https://github.com/mumble-voip/celt-$celt_version.git",
    revision => 'master',
    require  => File["/home/$username/src"],
  }

}