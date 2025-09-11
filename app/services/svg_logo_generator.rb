class SvgLogoGenerator
  LOGO_TEMPLATES = [
    # Template 1: Circle with initials
    lambda do |company_name|
      initials = company_name.split.map(&:first).join("").upcase[0, 2]
      color = ["#3B82F6", "#EF4444", "#10B981", "#F59E0B"].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <circle cx="32" cy="32" r="30" fill="#{color}" stroke="#ffffff" stroke-width="2"/>
          <text x="32" y="38" font-family="Arial, sans-serif" font-size="20" font-weight="bold" 
                text-anchor="middle" fill="white">#{initials}</text>
        </svg>
      SVG
    end,

    # Template 2: Square with geometric pattern
    lambda do |company_name|
      colors = [
        ["#6366F1", "#8B5CF6"],
        ["#EC4899", "#F43F5E"],
        ["#06B6D4", "#0EA5E9"],
        ["#84CC16", "#65A30D"]
      ].sample

      initials = company_name.split.map(&:first).join("").upcase[0, 2]

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" style="stop-color:#{colors[0]};stop-opacity:1" />
              <stop offset="100%" style="stop-color:#{colors[1]};stop-opacity:1" />
            </linearGradient>
          </defs>
          <rect width="64" height="64" rx="8" fill="url(#grad)"/>
          <text x="32" y="38" font-family="Arial, sans-serif" font-size="18" font-weight="bold" 
                text-anchor="middle" fill="white">#{initials}</text>
        </svg>
      SVG
    end,

    # Template 3: Hexagon with company initial
    lambda do |company_name|
      initial = company_name[0].upcase
      color = ["#7C3AED", "#DC2626", "#059669", "#D97706"].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <polygon points="32,4 52,16 52,48 32,60 12,48 12,16" fill="#{color}" stroke="#ffffff" stroke-width="2"/>
          <text x="32" y="38" font-family="Arial, sans-serif" font-size="24" font-weight="bold" 
                text-anchor="middle" fill="white">#{initial}</text>
        </svg>
      SVG
    end,

    # Template 4: Modern rounded square with dot pattern
    lambda do |company_name|
      initials = company_name.split.map(&:first).join("").upcase[0, 2]
      bg_color = ["#1E40AF", "#BE123C", "#047857", "#B45309"].sample
      dot_color = "#ffffff20"

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <rect width="64" height="64" rx="12" fill="#{bg_color}"/>
          <circle cx="16" cy="16" r="2" fill="#{dot_color}"/>
          <circle cx="48" cy="16" r="2" fill="#{dot_color}"/>
          <circle cx="16" cy="48" r="2" fill="#{dot_color}"/>
          <circle cx="48" cy="48" r="2" fill="#{dot_color}"/>
          <text x="32" y="38" font-family="Arial, sans-serif" font-size="18" font-weight="bold" 
                text-anchor="middle" fill="white">#{initials}</text>
        </svg>
      SVG
    end
  ].freeze

  def self.generate_random_logo(company_name)
    return nil if company_name.blank?

    template = LOGO_TEMPLATES.sample
    template.call(company_name).strip
  end
end
