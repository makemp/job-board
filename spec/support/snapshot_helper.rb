require "fileutils"
require "nokogiri"

def match_snapshot!(html_or_page, snapshot_name)
  if html_or_page.respond_to?(:has_selector?) # it's a Capybara page object
    page = html_or_page

    html = page.html
  else
    html = html_or_page
  end

  normalized_actual = normalize_html(html)
  snapshot_path = Rails.root.join("spec/snapshots/#{snapshot_name}.html")

  if !File.exist?(snapshot_path) || ENV["UPDATE_SNAPSHOTS"]
    FileUtils.mkdir_p(snapshot_path.dirname)
    File.write(snapshot_path, normalized_actual)
    warn "[snapshot created] #{snapshot_path}"
    return
  end

  expected_html = normalize_html(File.read(snapshot_path))

  expect(normalized_actual).to eq(expected_html), <<~MSG
    Snapshot mismatch for #{snapshot_name}
    --- Expected:
    #{expected_html}
    --- Got:
    #{normalized_actual}
  MSG
end

def normalize_html(html)
  doc = Nokogiri::HTML(html)

  doc.css("turbo-frame").each do |node|
    node.remove_attribute("complete")
    node.remove_attribute("busy")
    node.remove_attribute("aria-busy")
    # Add more rules here if needed
  end

  doc.css("[href], [src], [onclick]").each do |node|
    %w[href src onclick].each do |attr|
      next unless node[attr]

      value = node[attr]

      value.gsub!(%r{http://127.0.0.1:\d+}, "http://localhost:12345")

      # Normalize asset digests
      value.gsub!(%r{/assets/([^/]+)-[a-f0-9]{6,}\.(css|js|png|jpg|svg)}, '/assets/\1-[hash].\2')

      # Normalize ActiveStorage blob URLs
      value.gsub!(%r{/rails/active_storage/blobs/redirect/[^/]+/([^/]+\.(png|jpg|jpeg|svg))}, '/rails/active_storage/blobs/redirect/[blob-url]/\1')

      # Normalize ULIDs in paths or JS calls
      value.gsub!(/[0-7][0-9A-HJKMNP-TV-Z]{25}/i, "/[ulid]")

      node[attr] = value
    end
  end

  doc.css('link[rel="stylesheet"], script[src], img[src]').each do |node|
    attr = node["href"] || node["src"]
    next unless attr

    # Replace /assets/name-fingerprint.ext with /assets/name-[hash].ext
    normalized = attr.gsub(%r{/assets/([^/]+)-[a-f0-9]{6,}\.(css|js|png|jpg|svg)}, '/assets/\1-[hash].\2')
    normalized = normalized.gsub(%r{/rails/active_storage/blobs/redirect/[^/]+/([^/]+\.(png|jpg|jpeg|svg))}, '/rails/active_storage/blobs/redirect/[blob-url]/\1')

    node["href"] = normalized if node["href"]
    node["src"] = normalized if node["src"]
  end

  doc.to_html.strip
end
