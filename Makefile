.PHONY: help generate serve

help:
	@echo "Available targets:"
	@echo "  make generate   Run ./generate.sh"
	@echo "  make serve      Run python3 ./serve.py 8000"

generate:
	./generate.sh

serve:
	python3 ./serve.py 8000
