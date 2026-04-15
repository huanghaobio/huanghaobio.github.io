# Personal Academic Homepage

A Quarto-based personal academic homepage designed for GitHub Pages. The site emphasizes an individual academic identity, selected publications, talks, teaching, news, and the people you mentor or work with closely.

## What is included

- A Quarto website with a custom editorial-style visual design
- Structured data files for `publications`, `talks`, `teaching`, `news`, and `students`
- A Ruby pre-render script that turns those YAML files into reusable HTML partials
- A GitHub Actions workflow for automatic deployment to GitHub Pages
- Simple local commands for previewing and rebuilding the site

## Project structure

- `data/profile.yml`: profile metadata and quick links
- `data/publications.yml`: papers and scholarly outputs
- `data/talks.yml`: seminars, invited talks, tutorials
- `data/teaching.yml`: courses and teaching materials
- `data/news.yml`: lightweight updates instead of a full blog
- `data/students.yml`: students or researchers you mentor and work with closely
- `scripts/render_data.rb`: generates page partials before each Quarto render
- `content-templates/`: copyable starter entries for future updates

## Local development

1. Install Quarto.
2. Preview the site locally:

```bash
quarto preview
```

3. Build the site for deployment:

```bash
quarto render
```

Because `_quarto.yml` includes a `pre-render` step, Quarto will automatically run `ruby scripts/render_data.rb` before rendering.

## Update content

### Add a publication

1. Open `data/publications.yml`.
2. Copy the block from `content-templates/publication-template.yml`.
3. Paste it into the YAML list and fill in the fields.
4. Run `quarto preview` to verify the result.

### Add a person

1. Open `data/students.yml`.
2. Copy the block from `content-templates/student-template.yml`.
3. Add a portrait file under `assets/students/`.
4. Run `quarto preview`.

### Add news, talks, or teaching

Use the matching template from `content-templates/` and update the corresponding YAML file under `data/`.

## Publish on GitHub Pages

1. Create a GitHub repository.
2. If possible, name it `<your-github-username>.github.io` so the site is served at the root URL.
3. Push this project to the `main` branch.
4. In GitHub repository settings, set **Pages** to deploy from **GitHub Actions**.
5. In **Actions > General**, ensure workflow permissions allow read and write access.

The workflow in `.github/workflows/deploy.yml` will render the site and deploy the `_site/` output automatically.

## Personalization checklist

- Replace `Your Name`, placeholder biography text, and links
- Replace `assets/profile-placeholder.svg` with your portrait
- Replace the sample publications, talks, courses, news, and people entries
- Optionally add your CV PDF under `assets/cv/`
- Update `website.site-url` in `_quarto.yml`
