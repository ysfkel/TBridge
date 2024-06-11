
# Define the target
.PHONY: deploy_local deploy_testnet

# Define commands to run the shell scripts
deploy_local:
	./deploy/dev.sh

deploy_testnet:
	./deploy/testnet.sh
