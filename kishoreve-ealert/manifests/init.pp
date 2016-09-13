# == Class: ealert
#
# Full description of class ealert here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { ealert:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#


#cwd => "$home_path",
#file { "${home_path}/elasticalert":
##    ensure => 'directory',
##  }->
#exec { 'webapp run':
##    command => "python ${base_path}/elastalert_ui/ESAlerter.py &",
##    path    => '/usr/bin/',
##     }->
#

#Tested successfully on RHEL 6.6 x86-64, python 2.6.6 (on a cloudstack instance running puppet 3.3.1) 09/2016

class ealert {
$home_path='/opt'
$base_path="${home_path}/elasticalert"
$pythondevenv = ['gcc', 'gcc-c++', 'python-devel', 'kernel-devel', 'git']


exec { 'yum_clean':
    command => "yum clean all",
    path    => '/usr/bin/',
      }->

package { $pythondevenv: ensure => 'installed' }->

exec {'upgrade pip':
 command => 'pip install --upgrade pip',
 path => '/usr/bin',
}->
exec { 'setup_tools_update':
    command => 'pip install -U setuptools',
    path    => '/usr/bin/',
      }->

      exec { 'utils update':
          command => 'pip install -U utils',
          path    => '/usr/bin/',
            }->
exec { 'flask':
    command => "pip install flask",
    path    => '/usr/bin/',
      }->
exec { 'clone elasticalert':
    command => "git clone https://github.com/blahgit/elasticalert.git",
    path    => '/usr/bin/',
    cwd => "$home_path",
            }->

            exec { 'install reqs':
              command => "pip install -r ${base_path}/elastalert/requirements.txt",
              path    => '/usr/bin/',
              cwd => "$base_path/elastalert",
                }->

      exec { 'install setup':
               command => "python ${base_path}/elastalert/setup.py install",
               path    => '/usr/bin/',
               #timeout => 0,
               cwd => "$base_path/elastalert",
                 }->

   file { "${base_path}/elastalert/config.yaml":
          ensure => 'present',
          source => "${base_path}/elastalert/config.yaml.example",
     }->

exec { 'edit config':
    command => "python ${base_path}/edit_ealert_config.py",
    path    => '/usr/bin/',
      }->

cron { 'cron job for module and webapp':
    ensure  => 'present',
    command => "/usr/bin/python ${base_path}/runner.py",
    #hour => [ 23, 5 ],
    #    #minute => '30',
     }

}

include ealert
