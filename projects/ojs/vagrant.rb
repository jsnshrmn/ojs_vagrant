# See main Vagrantfile for default settings and provisioners

# Each container pulls in the completed hosts file and vagrant machine ssh keys.
# This ensures that containers can can communicate with each other via hostname.
# Provisioners run in loop order from the outside in, so this goes inside each
# machine definition so that it happens after all machines have written out
# their information to the shared hosts file.
# Docker is fast enough that we may be executing before vagrant share is up.
# Thus the sleep block.

config.vm.define "ojs" do |ojs|
    ojs.vm.hostname = "ojs.vagrant.localdomain"
    ojs.vm.provision "shell",
        inline: "while [ ! -f /vagrant/bin/fix-hosts.sh ]; do sleep 1; done; \
            sudo /vagrant/bin/fix-hosts.sh",
        keep_color: "True",
        run: "always"
end
