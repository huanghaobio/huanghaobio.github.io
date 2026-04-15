#!/usr/bin/env ruby
require 'yaml'
require 'cgi'
require 'fileutils'
require 'date'

ROOT = File.expand_path('..', __dir__)
DATA_DIR = File.join(ROOT, 'data')
OUT_DIR = File.join(ROOT, '_includes', 'generated')
FileUtils.mkdir_p(OUT_DIR)


def load_yaml(name)
  YAML.safe_load(File.read(File.join(DATA_DIR, name)), permitted_classes: [Date], aliases: true) || []
end


def esc(text)
  CGI.escapeHTML(text.to_s)
end


def render_links(link_specs)
  valid = link_specs.compact.select { |label, url| url && !url.to_s.strip.empty? }
  return '' if valid.empty?

  items = valid.map do |label, url|
    %(<a class="inline-button" href="#{esc(url)}">#{esc(label)}</a>)
  end
  %(<div class="publication-links">#{items.join}</div>)
end


def empty_card(title, body, css_class = 'feature-card empty-state')
  <<~HTML
    <article class="#{css_class}">
      <h3>#{esc(title)}</h3>
      <p>#{esc(body)}</p>
    </article>
  HTML
end


def render_student_card(item)
  portrait = item['portrait'].to_s.strip.empty? ? 'assets/students/student-placeholder.svg' : item['portrait']
  meta_items = [item['relationship'], item['timeframe']].compact.map(&:to_s).map(&:strip).reject(&:empty?)
  focus = item['research_focus'].to_s.strip
  summary = item['summary'].to_s.strip

  meta_html = if meta_items.empty?
    ''
  else
    pills = meta_items.map { |value| %(<span class="pill">#{esc(value)}</span>) }.join
    %(<div class="student-meta">#{pills}</div>)
  end

  focus_html = focus.empty? ? '' : %(<p><strong>Focus:</strong> #{esc(focus)}</p>)
  summary_html = summary.empty? ? '' : %(<p>#{esc(summary)}</p>)

  <<~HTML
    <article class="student-card">
      <img src="#{esc(portrait)}" alt="Portrait of #{esc(item['name'])}" />
      <div class="student-role">#{esc(item['status'])}</div>
      <h3 class="student-name">#{esc(item['name'])}</h3>
      #{meta_html}
      #{focus_html}
      #{summary_html}
    </article>
  HTML
end


def render_teaching_card(item)
  meta_items = [item['term'], item['level']].compact.map(&:to_s).map(&:strip).reject(&:empty?)
  role = item['role'].to_s.strip
  description = item['description'].to_s.strip
  links = render_links([[item['materials_label'] || 'Materials', item['materials_url']]])

  topline_html = meta_items.empty? ? '' : %(<div class="card-topline">#{esc(meta_items.join(' · '))}</div>)
  role_html = role.empty? ? '' : %(<p><strong>Role:</strong> #{esc(role)}</p>)
  description_html = description.empty? ? '' : %(<p>#{esc(description)}</p>)

  <<~HTML
    <article class="teaching-card">
      #{topline_html}
      <h3 class="teaching-title">#{esc(item['course'])}</h3>
      #{role_html}
      #{description_html}
      #{links}
    </article>
  HTML
end


def write_partial(name, content)
  File.write(File.join(OUT_DIR, name), content)
end

profile = load_yaml('profile.yml')
publications = load_yaml('publications.yml').sort_by { |item| [-item['year'].to_i, item['title'].to_s] }
talks = load_yaml('talks.yml').sort_by { |item| item['date'].to_s }.reverse
teaching = load_yaml('teaching.yml').sort_by { |item| item['term'].to_s }.reverse
news = load_yaml('news.yml').sort_by { |item| item['date'].to_s }.reverse
students = load_yaml('students.yml')

social_link_buttons = (profile['social_links'] || []).map do |item|
  %(<a class="inline-button" href="#{esc(item['url'])}">#{esc(item['label'])}</a>)
end.join
write_partial('contact-links.html', %(<div class="contact-links">#{social_link_buttons}</div>))

home_hero = <<~HTML
  <section class="hero-grid">
    <div class="hero-copy">
      <span class="eyebrow">Academic Home Page</span>
      <h1>#{esc(profile['name'])}</h1>
      <p class="lead">#{esc(profile['intro_lead'])}</p>
      <p>#{esc(profile['intro_body'])}</p>
      <div class="hero-actions">
        <a class="button-primary" href="publications.html">View publications</a>
        <a class="button-secondary" href="people.html">Meet my people</a>
        <a class="button-secondary" href="contact.html">Get in touch</a>
      </div>
    </div>
    <aside class="hero-aside">
      <img class="hero-photo" src="#{esc(profile['portrait'])}" alt="Portrait of #{esc(profile['name'])}" />
      <div class="meta-stack">
        <div class="meta-item">
          <span class="meta-label">Position</span>
          <strong>#{esc(profile['title'])}</strong>
        </div>
        <div class="meta-item">
          <span class="meta-label">Focus</span>
          <strong>#{esc((profile['research_topics'] || []).join(', '))}</strong>
        </div>
        <div class="meta-item">
          <span class="meta-label">Location</span>
          <strong>#{esc(profile['location'])}</strong>
        </div>
      </div>
    </aside>
  </section>
HTML
write_partial('home-hero.html', home_hero)

highlights_html = (profile['highlights'] || []).map do |item|
  <<~HTML
    <article class="stat-card">
      <span class="stat-number">#{esc(item['value'])}</span>
      <span class="stat-label">#{esc(item['label'])}</span>
    </article>
  HTML
end.join
write_partial('home-stats.html', %(<div class="stats-row">#{highlights_html}</div>))

selected_publications = publications.select { |item| item['selected'] }
selected_publications = publications.first(3) if selected_publications.empty?
selected_cards = if selected_publications.empty?
  empty_card('Publications will appear here', 'Add entries in data/publications.yml to populate the home page and full publications page.')
else
  selected_publications.first(3).map do |item|
    <<~HTML
      <article class="publication-card featured">
        <div class="card-topline">#{esc(item['venue'])} · #{esc(item['year'])}</div>
        <h3 class="publication-title">#{esc(item['title'])}</h3>
        <p><strong>#{esc(item['authors'])}</strong></p>
        <p>#{esc(item['summary'])}</p>
        #{render_links([['PDF', item['pdf']], ['Code', item['code']], ['Project', item['project']]])}
      </article>
    HTML
  end.join
end
write_partial('home-publications.html', %(<div class="card-grid three-up">#{selected_cards}</div>))

news_cards = if news.empty?
  empty_card('News and updates will appear here', 'You can add grants, papers, awards, and other milestones in data/news.yml.')
else
  news.first(3).map do |item|
    <<~HTML
      <article class="news-card">
        <span class="news-date">#{esc(item['date'])}</span>
        <h3 class="news-title">#{esc(item['title'])}</h3>
        <p>#{esc(item['summary'])}</p>
      </article>
    HTML
  end.join
end
write_partial('home-news.html', %(<div class="news-list">#{news_cards}</div>))

student_cards = if students.empty?
  empty_card('People profiles will be added here', 'Student and collaborator profiles can be added later by editing data/students.yml and placing images under assets/students/.')
else
  students.first(4).map { |item| render_student_card(item) }.join
end
write_partial('home-students.html', %(<div class="student-gallery">#{student_cards}</div>))

spotlight_cards = if talks.empty?
  empty_card('Talks can be added here', 'Invited talks, seminars, and conference presentations can be added later in data/talks.yml.', 'talk-card empty-state')
else
  talks.first(2).map do |item|
    link_html = item['slides'] ? %(<a class="inline-button" href="#{esc(item['slides'])}">Slides</a>) : ''
    <<~HTML
      <article class="talk-card">
        <span class="item-date">#{esc(item['date'])}</span>
        <h3 class="talk-title">#{esc(item['title'])}</h3>
        <p><strong>#{esc(item['event'])}</strong> · #{esc(item['location'])}</p>
        <p>#{esc(item['description'])}</p>
        #{link_html}
      </article>
    HTML
  end.join
end

course_cards = if teaching.empty?
  empty_card('Teaching information can be added here', 'Course information and teaching materials can be added later in data/teaching.yml.', 'teaching-card empty-state')
else
  teaching.first(2).map { |item| render_teaching_card(item) }.join
end

write_partial('home-teaching-talks.html', <<~HTML)
  <div class="story-grid">
    <div class="timeline-list">#{spotlight_cards}</div>
    <div class="timeline-list">#{course_cards}</div>
  </div>
HTML

all_publications = if publications.empty?
  empty_card('No publications yet', 'Add items in data/publications.yml to build this page automatically.')
else
  publications.map do |item|
    <<~HTML
      <article class="publication-card#{item['selected'] ? ' featured' : ''}">
        <div class="card-topline">#{esc(item['status'])} · #{esc(item['venue'])} · #{esc(item['year'])}</div>
        <h3 class="publication-title">#{esc(item['title'])}</h3>
        <p><strong>#{esc(item['authors'])}</strong></p>
        <p>#{esc(item['summary'])}</p>
        #{render_links([['PDF', item['pdf']], ['Code', item['code']], ['Project', item['project']]])}
      </article>
    HTML
  end.join
end
write_partial('publications-all.html', %(<div class="news-list">#{all_publications}</div>))

all_talks = if talks.empty?
  empty_card('Talks will be listed here', 'Add talk entries in data/talks.yml when you want them to appear on the public site.', 'talk-card empty-state')
else
  talks.map do |item|
    links = render_links([['Slides', item['slides']]])
    <<~HTML
      <article class="talk-card">
        <span class="item-date">#{esc(item['date'])}</span>
        <h3 class="talk-title">#{esc(item['title'])}</h3>
        <p><strong>#{esc(item['event'])}</strong> · #{esc(item['location'])}</p>
        <p>#{esc(item['description'])}</p>
        #{links}
      </article>
    HTML
  end.join
end
write_partial('talks-all.html', %(<div class="timeline-list">#{all_talks}</div>))

all_teaching = if teaching.empty?
  empty_card('Teaching information will be listed here', 'Add courses and teaching materials in data/teaching.yml when ready.', 'teaching-card empty-state')
else
  teaching.map { |item| render_teaching_card(item) }.join
end
write_partial('teaching-all.html', %(<div class="timeline-list">#{all_teaching}</div>))

all_news = if news.empty?
  empty_card('News will be listed here', 'Add grants, papers, awards, or other milestones in data/news.yml.')
else
  news.map do |item|
    <<~HTML
      <article class="news-card">
        <span class="news-date">#{esc(item['date'])}</span>
        <h3 class="news-title">#{esc(item['title'])}</h3>
        <p>#{esc(item['summary'])}</p>
      </article>
    HTML
  end.join
end
write_partial('news-all.html', %(<div class="timeline-list">#{all_news}</div>))

all_students = if students.empty?
  empty_card('People profiles will be listed here', 'This page is ready for student and collaborator profiles once names, descriptions, and photos are prepared.')
else
  students.map { |item| render_student_card(item) }.join
end
write_partial('students-all.html', %(<div class="card-grid two-up">#{all_students}</div>))

contact_grid = <<~HTML
  <section class="contact-grid">
    <article class="contact-card">
      <h3>Email</h3>
      <p><a href="mailto:#{esc(profile['email'])}">#{esc(profile['email'])}</a></p>
      <p>#{esc(profile['contact_note'])}</p>
    </article>
    <article class="contact-card">
      <h3>Phone & address</h3>
      <p><strong>Phone</strong><br/>#{esc(profile['phone'])}</p>
      <p><strong>Address</strong><br/>#{esc(profile['address'])}</p>
    </article>
    <article class="contact-card">
      <h3>Profiles</h3>
      <div class="contact-links">#{social_link_buttons}</div>
    </article>
  </section>
HTML
write_partial('contact-grid.html', contact_grid)

cv_sidebar = <<~HTML
  <aside class="cv-side">
    <h3>Quick profile</h3>
    <p><strong>#{esc(profile['name'])}</strong><br/>#{esc(profile['title'])}<br/>#{esc(profile['affiliation'])}</p>
    <p><strong>Email</strong><br/>#{esc(profile['email'])}</p>
    <p><strong>Phone</strong><br/>#{esc(profile['phone'])}</p>
    <p><strong>Research areas</strong><br/>#{esc((profile['research_topics'] || []).join(', '))}</p>
    <p><a class="inline-button" href="assets/cv/README.txt">Add PDF later</a></p>
  </aside>
HTML
write_partial('cv-sidebar.html', cv_sidebar)
