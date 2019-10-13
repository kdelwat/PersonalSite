build:
	dumbo content public

# https://stackoverflow.com/a/23734495
watch:
	while true; do \
		make build; \
		inotifywait -qre close_write .; \
	done

serve:
	cd public && python3 -m http.server 8080

deploy: build
	netlify deploy --dir public

deploy-prod: build
	netlify deploy --dir public --prod