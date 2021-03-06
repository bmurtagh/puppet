
node default {

  # install java
  class { 'java':
    package => 'java-1.8.0-openjdk-devel',
  }

  # install tomcat 8 using provided source
  tomcat::install { '/opt/tomcat':
    source_url => 'https://www-us.apache.org/dist/tomcat/tomcat-8/v8.0.39/bin/apache-tomcat-8.0.39.tar.gz',
  } ->

  # declare a tomcat instance
  tomcat::instance { 'tomcat':
    catalina_home => '/opt/tomcat',
  } ->

  # prepare for allowLinking configuration
  file { '/opt/tomcat/conf/context.xml':
    ensure => present,
  }

  # add allowLinking setting
  file_line { 'enable allowLinking':
    path    => '/opt/tomcat/conf/context.xml',
    line    => "<Context>\r\n<Resources allowLinking=\"true\"/>",
    match   => '^<(Context)>',
    require => File['/opt/tomcat/conf/context.xml'],
  }

  # content for tomcat init.d script
  $tomcat_initd_content = "#!/bin/bash
# description: Tomcat Start Stop Restart
# processname: tomcat
# chkconfig: 234 20 80
CATALINA_HOME=/opt/tomcat

case \$1 in
start)
sh \$CATALINA_HOME/bin/startup.sh
;;
stop)
sh \$CATALINA_HOME/bin/shutdown.sh
;;
restart)
sh \$CATALINA_HOME/bin/shutdown.sh
sh \$CATALINA_HOME/bin/startup.sh
;;
esac
exit 0
  "

  # create tomcat init.d script from $tomcat_initd_content
  file { '/etc/init.d/tomcat':
    ensure => present,
    content => $tomcat_initd_content,
    owner  => 'root',
    group  => 'root',
    mode   => '755',
  } ->

  service { 'tomcat':
    ensure => running,
    enable => true,
  }

  # create nabudev directories & set permissions/ownership
  $nabudev_directories = ['/datam', '/datam/nabudata', '/datam/nabudata/ngif', '/datam/nabudata/npdf', '/datam/nabudata/nxml']

  file { $nabudev_directories:
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '777',
  }

}
