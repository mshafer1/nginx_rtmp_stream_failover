all: install

.PHONY: all install

install: ./inventory.yml objects/deps_installed
	ansible-playbook -i ./inventory.yml ./_ansible_configs/playbooks/multistream.yml

objects/deps_installed: objects/ install_requirements.sh
	bash ./install_requirements.sh
	touch $@

objects/:
	mkdir -p objects
