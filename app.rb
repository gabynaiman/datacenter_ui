require 'datacenter'
require 'cuba'
require 'cuba/render'
require 'yaml'

Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = :slim

module Helper
  def gb(mb)
    (mb / 1024).round(2)
  end
end

config = YAML.load_file(File.expand_path('../config.yml', __FILE__))

Cuba.plugin Helper

Cuba.define do

  on get, root do
    res.write view(:dashboard, machines: config['servers'].keys)
  end

  on get, 'machine/:name' do |name|
    server = config['servers'][name]
    Datacenter::Shell::Ssh.open(server['host'], server['user'], port: server['port'] || 22) do |shell|
      machine = Datacenter::Machine.new shell
      res.write partial(:machine, machine: machine)
    end
  end

end