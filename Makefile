build:
	dumbo content public

deploy: build
	netlify deploy --dir public

deploy-prod: build
	netlify deploy --dir public --prod