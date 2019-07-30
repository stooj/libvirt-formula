# coding: utf-8
#
# python_version.rb -- Python version InSpec resources
# Author: Daniel Dehennin <daniel.dehennin@ac-dijon.fr>
# Copyright © 2019 Pôle de Compétences Logiciels Libres <eole@ac-dijon.fr>
#
class SaltMinionResource < Inspec.resource(1)
  name 'salt_minion'

  supports platform_name: 'debian'
  supports platform_name: 'ubuntu'
  supports platform_name: 'centos'
  supports platform_name: 'fedora'

  def initialize
    @salt_python_version = try_python_import_salt
    @version_string = get_version_string
  end

  def version
    @version_string
  end

  def is_python3?
    @version_string >= '3'
  end

  def is_python2?
    @version_string >= '2' && @version_string < '3'
  end

  def get_version_string
    cmd = inspec.command("python#{@salt_python_version} --version")

    if cmd.exit_status != 0
      raise Inspec::Exceptions::ResourceSkipped,
            "Error running 'python#{@salt_python_version} --version': #{cmd.stderr}"
    end

    if !cmd.stdout.empty?
      cmd.stdout.split[1]
    else
      cmd.stderr.split[1]
    end
  end

  def try_python_import_salt
    return 3 if try_python3_import_salt == 0
    return 2 if try_python2_import_salt == 0
    raise Inspec::Exceptions::ResourceSkipped, "Unable to import salt from python2 or python3"
  end

  def try_python3_import_salt
    inspec.command('python3 -c "import salt"').exit_status
  end

  def try_python2_import_salt
    inspec.command('python2 -c "import salt"').exit_status
  end

end
