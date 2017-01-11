
node default {

  class { 'java':
    package => 'java-1.8.0-openjdk-devel',
  }

  tomcat::install { '/opt/tomcat':
    source_url => 'https://www-us.apache.org/dist/tomcat/tomcat-8/v8.0.39/bin/apache-tomcat-8.0.39.tar.gz',
  }

  tomcat::instance { 'default':
    catalina_home  => '/opt/tomcat',
  }

  tomcat::service { 'default':
    use_init       => true,
    service_enable => true,
    service_ensure => running,
    service_name   => 'tomcat',
  }

}