.PHONY: preview build render-data

preview:
	quarto preview

build:
	quarto render

render-data:
	ruby scripts/render_data.rb
