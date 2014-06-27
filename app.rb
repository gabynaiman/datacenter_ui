require 'datacenter'
require 'cuba'
require 'cuba/render'

Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = :slim

module Helper
  def gb(mb)
    (mb / 1024).round(2)
  end
end

Cuba.plugin Helper

Cuba.define do

  on get, root do
    machines = File.read(File.expand_path('~/.ssh/config')).scan(/Host (.*)\n/).flatten.sort
    res.write view(:dashboard, machines: machines)
  end

  on get, 'machine/:name' do |name|
    config = Net::SSH::Config.for name
    Datacenter::Shell::Ssh.open(config[:host_name], config[:user]) do |shell|
      machine = Datacenter::Machine.new shell
      res.write view(:machine, machine: machine)
    end
  end

end