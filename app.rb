require 'datacenter'
require 'cuba'
require 'slim'
require 'cuba/render'
require 'yaml'

CONFIG = YAML.load_file(File.expand_path('../config.yml', __FILE__))

Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = :slim

module Helper
  def gb(mb)
    (mb / 1024).round(2)
  end
end
Cuba.plugin Helper

Cuba.use Rack::Static,
         urls: %w[/fonts /images /js /css /bower_components],
         root: File.expand_path('public', __dir__)

Cuba.define do

  on get, root do
    res.write view(:dashboard, machines: CONFIG['servers'].keys)
  end

  on get, 'machine/:name' do |name|
    server = CONFIG['servers'][name]
    Datacenter::Shell::Ssh.open(server['host'], server['user'], port: server['port'] || 22) do |shell|
      machine = Datacenter::Machine.new shell
      res.write partial(:machine, machine: machine)
    end
  end

end